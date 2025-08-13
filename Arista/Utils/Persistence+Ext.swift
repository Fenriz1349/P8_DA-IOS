//
//  Persistence+Ext.swift
//  Arista
//
//  Created by Julien Cotte on 13/08/2025.
//

import Foundation
import CoreData

extension PersistenceController {
    
    
    /// Create an unique PersistenceController for each test
    static func createTestContainer() -> PersistenceController {
        return PersistenceController(inMemory: true)
    }
    
    /// Erase All data, used for tests
    func clearAllData() {
        let entities = container.managedObjectModel.entities
        
        for entity in entities {
            guard let entityName = entity.name else { continue }
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            do {
                try container.viewContext.execute(deleteRequest)
            } catch {
                print("Erreur lors du nettoyage de \(entityName): \(error)")
            }
        }
        
        do {
            try container.viewContext.save()
        } catch {
            print("Erreur lors de la sauvegarde après nettoyage: \(error)")
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
