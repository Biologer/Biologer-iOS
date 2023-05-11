//
//  DBFindingMapper.swift
//  Biologer
//
//  Created by Nikola Popovic on 19.10.21..
//

import Foundation
import RealmSwift

public final class DBFindingMapper {
    
    // MARK: - Public Funcgions
    public static func mapToUpdateDB(findingViewModel: FindingViewModel,
                                     dbFinding: DBFinding) {
        let dbLocation = DBFindingLocation(latitude: findingViewModel.locationViewModel.taxonLocation!.latitude,
                                           longitude: findingViewModel.locationViewModel.taxonLocation!.longitute,
                                           altitude: findingViewModel.locationViewModel.taxonLocation!.altitude,
                                           accuracy: findingViewModel.locationViewModel.taxonLocation!.accuracy)
        
        let dbFindingImages = List<DBFindingImage>()
        
        findingViewModel.imageViewModel.choosenImages.forEach({ dbFindingImages.append(DBFindingImage(name: "",
                                                                                     image: $0.image.jpegData(compressionQuality: 1.0)!,
                                                                                     url: nil))})
        
        let dbIndividuals = mapIndividuals(male: findingViewModel.taxonInfoViewModel.maleIndividual,
                                           female: findingViewModel.taxonInfoViewModel.femaleIndividual,
                                           all: findingViewModel.taxonInfoViewModel.allIndividual)
        
        let dbObservations = List<DBFindingObservation>()
        
        findingViewModel.taxonInfoViewModel.observations.forEach({
            dbObservations.append(DBFindingObservation(id: $0.id, title: $0.name, isSelected: $0.isSelected))
        })
        
        var dbTaxon = DBFindingTaxon()
        let translation = List<DBTaxonTranslations>()
        let devStages = List<DBTaxonDevStage>()
        
        if let taxon = findingViewModel.taxonInfoViewModel.taxon, let taxonId = taxon.id { // Selected tax from DB
            taxon.translations?.forEach({ translation.append(DBTaxonTranslations(id: $0.id,
                                                                                 taxonId: $0.taxonId,
                                                                                 locale: $0.locale,
                                                                                 nativeName: $0.nativName,
                                                                                 descriptionName: $0.descriptionName))})
            taxon.devStages?.forEach({ devStages.append(DBTaxonDevStage(id: $0.id,
                                                                        name: $0.name,
                                                                        taxonId: taxonId)) })
            
            dbTaxon = DBFindingTaxon(apiId: taxonId,
                              name: taxon.name,
                              isAtlasCode: taxon.isAtlasCode,
                              translation: translation,
                              devStage: devStages)
        } else { // Tax with only text
            dbTaxon = DBFindingTaxon(apiId: nil,
                              name: findingViewModel.taxonInfoViewModel.taxonNameTextField.text,
                              isAtlasCode: false,
                              translation: translation,
                              devStage: devStages)
        }
        
        dbFinding.location = dbLocation
        dbFinding.images = dbFindingImages
        dbFinding.atlasCode = findingViewModel.taxonInfoViewModel.taxon!.selectedAltasCode != nil ? DBAtlasCode(id: findingViewModel.taxonInfoViewModel.taxon!.selectedAltasCode!.id,
                                                                                                                      name: findingViewModel.taxonInfoViewModel.taxon!.selectedAltasCode!.name) : nil
        dbFinding.devStage = findingViewModel.taxonInfoViewModel.taxon!.selectedDevStage != nil ? DBTaxonDevStage(id: findingViewModel.taxonInfoViewModel.taxon!.selectedDevStage!.id, name: findingViewModel.taxonInfoViewModel.taxon!.selectedDevStage!.name,taxonId: 0) : nil
        dbFinding.taxon = dbTaxon
        dbFinding.individuals = dbIndividuals
        dbFinding.observations = dbObservations
        dbFinding.comment = findingViewModel.taxonInfoViewModel.commentsTextField.text
        dbFinding.habitat = findingViewModel.taxonInfoViewModel.habitatTextField.text
        dbFinding.foundOn = findingViewModel.taxonInfoViewModel.foundOnTextField.text
        dbFinding.foundDead = findingViewModel.taxonInfoViewModel.fountDeadTextField.text
        dbFinding.isUploaded = findingViewModel.isUploaded
    }
    
    public static func mapFromDB(dbFinding: DBFinding,
                                 location: LocationManager,
                                 settingsStorage: SettingsStorage) -> FindingViewModel {
        
        let taxonLocation = TaxonLocation(latitude: dbFinding.location?.latitude ?? 0.0,
                                          longitute: dbFinding.location?.longitude ?? 0.0,
                                          accuracy: dbFinding.location?.accuracy ?? 0.0,
                                          altitude: dbFinding.location?.altitude ?? 0.0)
        let locationViewModel = NewTaxonLocationViewModel(location: location,
                                                          taxonLocation: taxonLocation)
        
        var taxonImages = [TaxonImage]()
         dbFinding.images.forEach({
            if let image = UIImage(data: $0.image) {
                taxonImages.append(TaxonImage(image: image))
            }
         })
         
        let imageViewModel = NewTaxonImageViewModel(choosenImages: taxonImages)
        var devStages = [DevStageViewModel]()
        dbFinding.taxon?.devStage.forEach({
            devStages.append(DevStageViewModel(id: $0.id,
                                               name: $0.name))
        })
        
        var selectedDevStage: DevStageViewModel? = nil
        var selectedAtlasCode: NestingAtlasCodeItem? = nil
        
        if let devStage = dbFinding.devStage {
            selectedDevStage = DevStageViewModel(id: devStage.id,
                                                     name: devStage.name)
        }
        
        if let atlasCode = dbFinding.atlasCode {
            selectedAtlasCode = NestingAtlasCodeItem(id: atlasCode.id,
                                                         name: atlasCode.name)
        }
        
        var taxonTranslation = [TaxonTranslationViewModel]()
        
        dbFinding.taxon?.translation.forEach({
            taxonTranslation.append(TaxonTranslationViewModel(id: $0.id,
                                                              taxonId: $0.taxonId,
                                                              locale: $0.locale,
                                                              nativName: $0.nativeName,
                                                              descriptionName: $0.descriptionName))
        })
        
        let taxonViewModel = TaxonViewModel(id: dbFinding.taxon?.apiId,
                                            name: dbFinding.taxon?.name ?? "",
                                            isAtlasCode: dbFinding.taxon?.isAtlasCode ?? false,
                                            devStages: devStages,
                                            selectedDevStage: selectedDevStage,
                                            selectedAltasCode: selectedAtlasCode,
                                            translations: taxonTranslation)
        
        var observations = [Observation]()
        
        dbFinding.observations.forEach({
            observations.append(Observation(id: $0.id,name: $0.title, isSelected: $0.isSelected))
        })
        
        let maleIndividual = TaxonIndividual(number: dbFinding.individuals?.male?.value ?? 0, isSelected: dbFinding.individuals?.male?.isSelected ?? false)
        let femaleIndividual = TaxonIndividual(number: dbFinding.individuals?.female?.value ?? 0, isSelected: dbFinding.individuals?.female?.isSelected ?? false)
        let allIndividual = TaxonIndividual(number: dbFinding.individuals?.all?.value ?? 0, isSelected: dbFinding.individuals?.all?.isSelected ?? false)
         
         let taxonInfoViewModel = NewTaxonInfoViewModel(observations: observations,
                                                        settingsStorage: settingsStorage,
                                                        taxon: taxonViewModel,
                                                        comments: dbFinding.comment,
                                                        maleIndividual: maleIndividual,
                                                        femaleIndividual: femaleIndividual,
                                                        allIndividual: allIndividual,
                                                        habitat: dbFinding.habitat,
                                                        foundOn: dbFinding.foundOn,
                                                        foundDead: dbFinding.foundDead)
         
        let findingViewModel = FindingViewModel(id: dbFinding.id,
                                                findingMode: .edit,
                                                locationViewModel: locationViewModel,
                                                imageViewModel: imageViewModel,
                                                taxonInfoViewModel: taxonInfoViewModel,
                                                isUploaded: dbFinding.isUploaded,
                                                dateOfCreation: dbFinding.dateOfCreation)
        return findingViewModel
    }
    
    public static func mapToDB(findingViewModel: FindingViewModel, dbModelToUpdate: DBFinding? = nil) -> DBFinding {
        let dbFindingLocation = DBFindingLocation(latitude: findingViewModel.locationViewModel.taxonLocation!.latitude,
                                                  longitude: findingViewModel.locationViewModel.taxonLocation!.longitute,
                                                  altitude: findingViewModel.locationViewModel.taxonLocation!.altitude,
                                                  accuracy: findingViewModel.locationViewModel.taxonLocation!.accuracy)
        
        let dbFindingImages = List<DBFindingImage>()
        
        findingViewModel.imageViewModel.choosenImages.forEach({ dbFindingImages.append(DBFindingImage(name: "",
                                                                                     image: $0.image.jpegData(compressionQuality: 1.0)!,
                                                                                     url: nil))})
        var dbTaxon = DBFindingTaxon()
        let translation = List<DBTaxonTranslations>()
        let devStages = List<DBTaxonDevStage>()
        
        if let taxon = findingViewModel.taxonInfoViewModel.taxon, let taxonId = taxon.id { // Selected tax from DB
            taxon.translations?.forEach({ translation.append(DBTaxonTranslations(id: $0.id,
                                                                                 taxonId: $0.taxonId,
                                                                                 locale: $0.locale,
                                                                                 nativeName: $0.nativName,
                                                                                 descriptionName: $0.descriptionName))})
            taxon.devStages?.forEach({ devStages.append(DBTaxonDevStage(id: $0.id,
                                                                        name: $0.name,
                                                                        taxonId: taxonId)) })
            
            dbTaxon = DBFindingTaxon(apiId: taxonId,
                              name: taxon.name,
                              isAtlasCode: taxon.isAtlasCode,
                              translation: translation,
                              devStage: devStages)
        } else { // Tax with only text
            dbTaxon = DBFindingTaxon(apiId: nil,
                              name: findingViewModel.taxonInfoViewModel.taxonNameTextField.text,
                              isAtlasCode: false,
                              translation: translation,
                              devStage: devStages)
        }
        
        let dbIndividuals = mapIndividuals(male: findingViewModel.taxonInfoViewModel.maleIndividual,
                                           female: findingViewModel.taxonInfoViewModel.femaleIndividual,
                                           all: findingViewModel.taxonInfoViewModel.allIndividual)
        
        let dbObservations = List<DBFindingObservation>()
        
        findingViewModel.taxonInfoViewModel.observations.forEach({
            dbObservations.append(DBFindingObservation(id: $0.id, title: $0.name, isSelected: $0.isSelected))
        })
        
        var dbFinding = DBFinding()
        if let dbModelToUpdate = dbModelToUpdate {
            dbModelToUpdate.location = dbFindingLocation
            dbModelToUpdate.images = dbFindingImages
            dbModelToUpdate.atlasCode = findingViewModel.taxonInfoViewModel.taxon!.selectedAltasCode != nil ? DBAtlasCode(id: findingViewModel.taxonInfoViewModel.taxon!.selectedAltasCode!.id,
                                                                                                                          name: findingViewModel.taxonInfoViewModel.taxon!.selectedAltasCode!.name) : nil
            dbModelToUpdate.devStage = findingViewModel.taxonInfoViewModel.taxon!.selectedDevStage != nil ? DBTaxonDevStage(id: findingViewModel.taxonInfoViewModel.taxon!.selectedDevStage!.id, name: findingViewModel.taxonInfoViewModel.taxon!.selectedDevStage!.name,taxonId: 0) : nil
            dbModelToUpdate.individuals = dbIndividuals
            dbModelToUpdate.observations = dbObservations
            dbModelToUpdate.comment = findingViewModel.taxonInfoViewModel.commentsTextField.text
            dbModelToUpdate.habitat = findingViewModel.taxonInfoViewModel.habitatTextField.text
            dbModelToUpdate.foundOn = findingViewModel.taxonInfoViewModel.foundOnTextField.text
            dbModelToUpdate.foundDead = findingViewModel.taxonInfoViewModel.fountDeadTextField.text
            dbFinding = dbModelToUpdate
        }
        dbFinding = DBFinding(location: dbFindingLocation,
                              images: dbFindingImages,
                              taxon: dbTaxon,
                              atlasCode: findingViewModel.taxonInfoViewModel.taxon!.selectedAltasCode != nil ? DBAtlasCode(id: findingViewModel.taxonInfoViewModel.taxon!.selectedAltasCode!.id,
                                                                                                                           name: findingViewModel.taxonInfoViewModel.taxon!.selectedAltasCode!.name) : nil,
                              devStage: findingViewModel.taxonInfoViewModel.taxon!.selectedDevStage != nil ? DBTaxonDevStage(id: findingViewModel.taxonInfoViewModel.taxon!.selectedDevStage!.id,
                                                                                                                             name: findingViewModel.taxonInfoViewModel.taxon!.selectedDevStage!.name,
                                                                                                                             taxonId: 0) : nil,
                              individuals: dbIndividuals,
                              observations: dbObservations,
                              comment: findingViewModel.taxonInfoViewModel.commentsTextField.text,
                              habitat: findingViewModel.taxonInfoViewModel.habitatTextField.text,
                              foundOn: findingViewModel.taxonInfoViewModel.foundOnTextField.text,
                              foundDead: findingViewModel.taxonInfoViewModel.fountDeadTextField.text,
                              isUploaded: findingViewModel.isUploaded,
                              dateOfCreation: findingViewModel.dateOfCreation)
        return dbFinding
    }
    
    
    // MARK: - Private Functions
    private static func mapIndividuals(male: TaxonIndividual,
                                female: TaxonIndividual,
                                all: TaxonIndividual) -> DBFindingIndividuals {
        if all.number > 0 {
            return DBFindingIndividuals(male: nil,
                                        female: nil,
                                        all: DBFindingIndividual(value: male.number, isSelected: male.isSelected))
        } else if male.number > 0 && female.number > 0 {
            return DBFindingIndividuals(male: DBFindingIndividual(value: male.number, isSelected: male.isSelected),
                                        female: DBFindingIndividual(value: female.number, isSelected: female.isSelected),
                                        all: nil)
        } else if male.number > 0 {
            return DBFindingIndividuals(male: DBFindingIndividual(value: male.number, isSelected: male.isSelected),
                                        female: nil,
                                        all: nil)
        } else if female.number > 0 {
            return DBFindingIndividuals(male: nil,
                                        female: DBFindingIndividual(value: female.number, isSelected: female.isSelected),
                                        all: nil)
        }
        return DBFindingIndividuals()
    }
}
