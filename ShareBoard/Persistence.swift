//
//  Persistence.swift
//  ShareBoard
//
//  Created by Jefry Gunawan on 10/08/23.
//

import CoreData
import CloudKit

struct PersistenceController {
    static let shared = PersistenceController()
    
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for _ in 0..<10 {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()
        }
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()
    
    let container: NSPersistentCloudKitContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "ShareBoard")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
    }
    
    func fetchAndSyncData(completion: @escaping (Bool) -> Void) {
        let container = CKContainer.default()
        let database = container.privateCloudDatabase // Use publicCloudDatabase for fetching data
        
        let query = CKQuery(recordType: "CD_Drawing", predicate: NSPredicate(value: true))
        
        database.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print("Error fetching data from CloudKit: \(error)")
                completion(false)
            } else if let records = records {
                DispatchQueue.main.async {
                    self.updateCoreData(with: records)
                    print("Record ce amel : \(records)")
                    completion(true)
                }
            }
        }
    }
    
    private func updateCoreData(with cloudKitRecords: [CKRecord]) {
//        let result = PersistenceController(inMemory: true)
        let viewContext = container.viewContext
        
        // Delete existing records from Core Data
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Drawing.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try viewContext.execute(deleteRequest)
        } catch {
            print("Error deleting existing Core Data records: \(error)")
        }
        
        for record in cloudKitRecords {
//            let newItem = Drawing(context: viewContext)
//            newItem.id = record["CD_id"] as? UUID
//            newItem.title = record["CD_title"] as? String
//            newItem.canvasData = record["CD_canvasData"] as? Data
        }
        do {
            try viewContext.save()
        } catch {
            print("Error saving Core Data changes: \(error)")
        }
    }
}
