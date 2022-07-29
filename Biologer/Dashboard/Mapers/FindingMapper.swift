//
//  FindingMapper.swift
//  Biologer
//
//  Created by Nikola Popovic on 10.11.21..
//

import Foundation

public final class FindingMapper {
    public static func map(finding: FindingViewModel,
                           images: [FindingPhotoRequestBody]?,
                           dataLicense: Int,
                           projectName: String) -> FindingRequestBody {
        
        let findingBody = FindingRequestBody(atlasCode: finding.taxonInfoViewModel.taxon?.selectedAltasCode?.id ?? 0,
                                             accuracy: Int(finding.locationViewModel.taxonLocation?.accuracy ?? 0),
                                             data_license: String(dataLicense),
                                             day: String(Date().get(.day)),
                                             elevation: Int(finding.locationViewModel.taxonLocation?.altitude ?? 0),
                                             found_dead: finding.taxonInfoViewModel.isFoundDead ? 1 : 0,
                                             found_dead_note: finding.taxonInfoViewModel.fountDeadTextField.text,
                                             found_on: finding.taxonInfoViewModel.foundOnTextField.text,
                                             habitat: finding.taxonInfoViewModel.habitatTextField.text,
                                             latitude: finding.locationViewModel.taxonLocation?.latitude ?? 0.0,
                                             longitude: finding.locationViewModel.taxonLocation?.longitute ?? 0.0,
                                             location: "",
                                             month: String(Date().get(.month)),
                                             note: finding.taxonInfoViewModel.commentsTextField.text,
                                             number: finding.taxonInfoViewModel.getGenderIndividuals(),
                                             observation_types_ids: finding.getSelectedObservations(),
                                             photos: images,
                                             project: projectName,
                                             sex: finding.taxonInfoViewModel.getGender(),
                                             stage_id: finding.taxonInfoViewModel.taxon?.selectedDevStage?.id ?? nil,
                                             taxon_id: finding.taxonInfoViewModel.taxon?.id ?? nil,
                                             taxon_suggestion: finding.taxonInfoViewModel.taxon?.name ?? "",
                                             time: Date().getHoursAndMuntes(),
                                             year: String(Date().get(.year)))
        print(findingBody)
        return findingBody
    }
}
