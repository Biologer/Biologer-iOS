//
//  ListOfFindingsMapper.swift
//  Biologer
//
//  Created by Nikola Popovic on 9.10.21..
//

import Foundation
import RealmSwift

public final class ListOfFindingsMapper {
    
    public static func getFinding(dbFindings: Results<DBFinding>) -> [Finding]? {
        if dbFindings.isEmpty {
            return nil
        }
        return dbFindings.map({ Finding(id: $0.id,
                                        taxon: $0.taxon?.name ?? "",
                                        image: UIImage(data: $0.images.first?.image ?? Data()),
                                        developmentStage: $0.devStage?.name ?? "",
                                        isUploaded: $0.isUploaded)})
    }
}
