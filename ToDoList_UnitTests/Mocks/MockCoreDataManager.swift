//
//  MockCoreDataManager.swift
//  ToDoList
//
//  Created by Niykee Moore on 31.03.2025.
//

@testable import ToDoList
import CoreData

final class MockCoreDataManager: CoreDataManaging {
    let persistentContainer: NSPersistentContainer
    
    init() {
        persistentContainer = NSPersistentContainer(name: "TodoListModel")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        description.shouldAddStoreAsynchronously = false
        
        persistentContainer.persistentStoreDescriptions = [description]
        
        persistentContainer.loadPersistentStores { desc, error in
            
            precondition(desc.type == NSInMemoryStoreType, "Не удалось загрузить in-memory хранилище")
            if let error = error as NSError? {
                fatalError("Не удалось загрузить in-memory Core Data стек: \(error), \(error.userInfo)")
            }
        }
    }
    
    var viewContext: NSManagedObjectContext {
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
        
        context.performAndWait {
            if context.hasChanges {
                do {
                    try context.save()
                    print("MockCoreDataManager viewContext saved successfully.")
                } catch {
                    print("Ошибка сохранения MockCoreDataManager viewContext: \(error)")
                }
            }
        }
    }
}
