//
//  RealmManager.swift
//  Biologer
//
//  Created by Nikola Popovic on 9.10.21..
//

import Foundation
import RealmSwift

final class RealmManager {
    // MARK: - Functions

    static func realmConfig() -> Realm.Configuration {
        Realm.Configuration(schemaVersion: 4, migrationBlock: { migration, oldSchemaVersion in
            if oldSchemaVersion < 4 {
                migration.enumerateObjects(ofType: DBFindingIndividual.className()) {
                    _, newObject in
                    newObject?["isUploaded"] = false
                }
            }
        })
    }
    
    private static func realmInstance() -> Realm {
        do {
            let newRealm = try Realm(configuration: realmConfig())
            return newRealm
        } catch {
            print(error)
            fatalError("Unable to create an instance of Realm")
        }
    }
}

extension RealmManager {
    private static func write(_ block: @escaping (Realm) -> Void) {
        DispatchQueue(label: "realm").sync {
            autoreleasepool {
                let currentRealm = realmInstance()

                if currentRealm.isInWriteTransaction {
                    return
                }

                do {
                    try currentRealm.write {
                        block(currentRealm)
                    }
                } catch {
                    return
                }
            }
        }
    }

    // MARK: - Add

    static func add(_ object: Object) {
        Self.write { realmInstance in
            realmInstance.add(object, update: .all)
        }
    }

    // MARK: - Get

    static func get<R: Object>(fromEntity entity: R.Type) -> Results<R> {
        realmInstance().objects(entity)
    }

    // MARK: - Delete

    static func delete(fromEntity entity: Object.Type) {
        Self.write { realmInstance in
            realmInstance.delete(realmInstance.objects(entity))
        }
    }
}
