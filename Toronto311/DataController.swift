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

class DataController: NSObject {
    let container = NSPersistentContainer(name: "Model")
    var context: NSManagedObjectContext {
        return container.viewContext
    }
    
    func load(completion: @escaping () -> ()) {
        container.loadPersistentStores { (_, error) in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
            completion()
        }
    }
    
    func read() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: EntityName.user.rawValue)
        //        request.predicate = NSPredicate(format: "location = %@", "123")
        request.returnsObjectsAsFaults = false
        
        do {
            if
                let result = try context.fetch(request) as? [UserCD],
                result.count > 0
            {
                for data in result {
                    print(data.name ?? "")
                }
            } else {
                print("request returned no data (\(request))")
            }
        } catch {
            print("failed to fetch request (\(request)) from context (\(context))")
        }
    }
    
    func write() {
        if
            let entity = NSEntityDescription.entity(forEntityName: EntityName.user.rawValue, in: context),
            let object = NSManagedObject(entity: entity, insertInto: context) as? UserCD
        {
            object.name = "this is my name"
            save()
        }
    }
    
    func decode() {
        if let user: User = [
            "name": "this is an apple"
            ].decodeDecodable(userInfo: [.context: context]) {
            context.insert(user)
        }
        if let user: User = [
            "name": "two person red"
            ].decodeDecodable(userInfo: [.context: context]) {
            context.insert(user)
        }
        if let user: User = [
            "name": "one person blue"
            ].decodeDecodable(userInfo: [.context: context]) {
            context.insert(user)
        }
        save()
    }
    
    func save() {
        do {
            try context.save()
        } catch {
            print("failed saving")
        }
    }
}

enum EntityName: String {
    case user = "UserCD"
}

public extension CodingUserInfoKey {
    static let context = CodingUserInfoKey(rawValue: "context")!
}

class User: UserCD, Codable {
    enum CodingKeys: String, CodingKey {
        case name
    }

    required convenience init(from decoder: Decoder) throws {
        guard
            let context = decoder.userInfo[.context] as? NSManagedObjectContext,
            let entity = NSEntityDescription.entity(forEntityName: EntityName.user.rawValue, in: context)
            else {fatalError("Failed to decode \(EntityName.user.rawValue)")}
        
        self.init(entity: entity, insertInto: nil)

        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decode(String.self, forKey: .name)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
    }
}
