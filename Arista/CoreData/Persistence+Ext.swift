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
        switch error.code {
        case NSPersistentStoreIncompatibleVersionHashError:
            print(String(localized: "error.migrationDescription"))
        case NSFileReadNoPermissionError, NSFileWriteNoPermissionError:
            print(String(localized: "error.permissionDescription"))
        case NSFileReadNoSuchFileError:
            print(String(localized: "error.missingFileDescription"))
        case NSPersistentStoreOpenError:
            print(String(localized: "error.openStoreDescription"))
        default:
            print(String(localized: "error.unknownDescription"))
        }
    }

    /// Count the number of occurency of a given Type
    func count<T: NSManagedObject>(for type: T.Type) -> Int {
        let request = NSFetchRequest<T>(entityName: String(describing: type))
        do {
            return try container.viewContext.count(for: request)
        } catch {
            print(String.localizedStringWithFormat(NSLocalizedString("error.countMessage", comment: ""),
                                                   error as CVarArg))
            return -1
        }
    }
}
