//
//  Persistence+Ext.swift
//  Arista
//
//  Created by Julien Cotte on 13/08/2025.
//

import Foundation
import CoreData

extension PersistenceController {

    func handlePersistentStoreError(_ error: NSError) {
        print("Erreur CoreData: \(error.localizedDescription)")
        switch error.code {
        case NSPersistentStoreIncompatibleVersionHashError:
            print("Migration nécessaire")
        case NSFileReadNoPermissionError, NSFileWriteNoPermissionError:
            print("Permission refusée")
        case NSFileReadNoSuchFileError:
            print("Fichier manquant")
        case NSPersistentStoreOpenError:
            print("Erreur stockage / ouverture")
        default:
            print("Erreur inconnue")
        }
    }

    /// Create an unique PersistenceController for each test
    static func createTestContainer() -> PersistenceController {
        return PersistenceController(inMemory: true)
    }

    /// Erase All data, used for tests
    func clearAllData() {
           let request: NSFetchRequest<NSFetchRequestResult> = User.fetchRequest()
           let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)

           do {
               try container.viewContext.execute(deleteRequest)
               try container.viewContext.save()
           } catch {
               print("Erreur lors du nettoyage: \(error)")
           }
       }

    /// Count the number of occurency of a given Type
    func count<T: NSManagedObject>(for type: T.Type) -> Int {
        let request = NSFetchRequest<T>(entityName: String(describing: type))
        do {
            return try container.viewContext.count(for: request)
        } catch {
            print("Erreur lors du comptage: \(error)")
            return 0
        }
    }
}
