//
//  CoreDataManager.swift
//  ToDoList
//
//  Created by Niykee Moore on 31.03.2025.
//

import Foundation
import CoreData

protocol CoreDataManaging {
    var viewContext: NSManagedObjectContext { get }
    func newBackgroundContext() -> NSManagedObjectContext
    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void)
    func saveViewContext()
}

final class CoreDataManager: CoreDataManaging {
    // MARK: - Properties
    let persistentContainer: NSPersistentContainer
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // MARK: - Initialization
    
    init() {
        persistentContainer = NSPersistentContainer(name: "TodoListModel")
        persistentContainer.loadPersistentStores { storeDescription, error in
            if let error = error {
                print("CoreData Store Load Error: \(error)")
            } else {
                print("CoreData store loaded: \(storeDescription)")
            }
        }
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    // MARK: - Context
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func newBackgroundContext() -> NSManagedObjectContext {
        return persistentContainer.newBackgroundContext()
    }
    
    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        persistentContainer.performBackgroundTask(block)
    }
    
    func saveViewContext() {
        let context = viewContext
        context.perform {
            if context.hasChanges {
                do {
                    try context.save()
                    print("CoreData viewContext saved successfully.")
                } catch {
                    print("Error saving CoreData viewContext: \(error)")
                }
            }
        }
    }
}
