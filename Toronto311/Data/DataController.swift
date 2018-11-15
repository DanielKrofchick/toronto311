//
//  DataController.swift
//  Toronto311
//
//  Created by Daniel Krofchick on 2018-11-06.
//  Copyright © 2018 Daniel Krofchick. All rights reserved.
//

import Foundation
import CoreData
import UIKit

extension DataController {
    static let shared = DataController()
}

public extension CodingUserInfoKey {
    static let context = CodingUserInfoKey(rawValue: "context")!
}

extension NSNotification.Name {
    static let coreDataDidLoad = NSNotification.Name(rawValue: "coreDataDidLoad")
}

struct NSEntityDescriptionName {
}

class DataController: NSObject {
    let container = NSPersistentContainer(name: "Model")
    var context: NSManagedObjectContext {
        return container.viewContext
    }
    
    var isLoaded = false
    
    func load(_ completion: @escaping () -> ()) {
        container.loadPersistentStores { [weak self] (_, error) in
            if let error = error {
                fatalError("failed to load Core Data stack: \(error)")
            }
            self?.isLoaded = true
            NotificationCenter.default.post(name: .coreDataDidLoad, object: nil)
            completion()
        }
    }
    
    func save() {
        context.performAndWait {
            do {
                try context.save()
            } catch {
                print("failed to save context (\(context)): \(error)")
            }
        }
    }
    
    func deleteAll() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Ward")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try container.viewContext.execute(deleteRequest)
        } catch let error as NSError {
            print(error)
        }
    }
}
