//
//  Fetchable.swift
//  Toronto311
//
//  Created by Daniel Krofchick on 2018-11-14.
//  Copyright © 2018 Daniel Krofchick. All rights reserved.
//

import CoreData

// Adapted from: https://gist.github.com/capttaco/adb38e0d37fbaf9c004e

protocol Fetchable
{
    associatedtype FetchableType: NSManagedObject
    
    static var entityName: String {get}
    static func fetchRequest(
        context: NSManagedObjectContext,
        predicate: NSPredicate?,
        sortedBy: String?,
        ascending: Bool)
        -> NSFetchRequest<NSFetchRequestResult>
    static func objects(
        context: NSManagedObjectContext,
        predicate: NSPredicate?,
        sortedBy: String?,
        ascending: Bool)
        throws -> [FetchableType]
    static func objectCount(
        context: NSManagedObjectContext,
        predicate: NSPredicate?)
        -> Int
}

extension Fetchable //where Self: NSManagedObject, FetchableType == Self
{
    static func fetchRequest(
        context: NSManagedObjectContext,
        predicate: NSPredicate? = nil,
        sortedBy: String? = nil,
        ascending: Bool = false)
        -> NSFetchRequest<NSFetchRequestResult>
    {
        let request = NSFetchRequest<NSFetchRequestResult>()
        
        request.entity = .entity(forEntityName: entityName, in: context)
        request.predicate = predicate
        
        if let sortedBy = sortedBy {
            request.sortDescriptors = [NSSortDescriptor(key: sortedBy, ascending: ascending)]
        }
        
        return request
    }
    
    static func objects(
        context: NSManagedObjectContext,
        predicate: NSPredicate? = nil,
        sortedBy: String? = nil,
        ascending: Bool = false)
        throws -> [FetchableType]
    {
        var result = [FetchableType]()
        
        context.performAndWait {
            do {
                let request = fetchRequest(context: context, predicate: predicate, sortedBy: sortedBy, ascending: ascending)
                let fetched = try context.fetch(request) as? [FetchableType] ?? []
                result.append(contentsOf: fetched)
            } catch {
                fatalError("error fetching \(entityName): \(error)")
            }
        }
        
        return result
    }
    
    static func objectCount(
        context: NSManagedObjectContext,
        predicate: NSPredicate? = nil)
        -> Int
    {
        var result: Int = 0
        
        context.performAndWait {
            do {
                result = try context.count(for: fetchRequest(context: context, predicate: predicate))
            } catch {
                print("error fetching objectCount for \(entityName): \(error)")
            }
        }
        
        return result
    }
}
