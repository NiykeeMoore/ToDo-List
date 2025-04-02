//
//  CoreDataStoring.swift
//  ToDoList
//
//  Created by Niykee Moore on 31.03.2025.
//

import Foundation
import CoreData

protocol TodoStoring {
    func fetchTodos(completion: @escaping (Result<[Todo], Error>) -> Void)
    func saveTodo(_ todo: Todo, completion: @escaping (Result<Void, Error>) -> Void)
    func deleteTodo(id: String, completion: @escaping (Result<Void, Error>) -> Void)
    func batchInsertTodos(from todos: [Todo], completion: @escaping (Result<Void, Error>) -> Void)
}

final class CoreDataStore: TodoStoring {
    private let manager: CoreDataManaging
    
    init(manager: CoreDataManaging) {
        self.manager = manager
    }
    
    func fetchTodos(completion: @escaping (Result<[Todo], Error>) -> Void) {
        let context = manager.viewContext
        
        context.perform {
            let fetchRequest = NSFetchRequest<TodoEntity>(entityName: "TodoEntity")
            let sortDescriptor = NSSortDescriptor(keyPath: \TodoEntity.dateOfCreation, ascending: false)
            fetchRequest.sortDescriptors = [sortDescriptor]
            
            do {
                let entities = try context.fetch(fetchRequest)
                let todos = entities.compactMap { self.mapEntityToDomain($0) }
                completion(.success(todos))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    func saveTodo(_ todo: Todo, completion: @escaping (Result<Void, Error>) -> Void) {
        manager.performBackgroundTask { [weak self] context in
            guard let self = self else { return }
            
            let fetchRequest = NSFetchRequest<TodoEntity>(entityName: "TodoEntity")
            fetchRequest.predicate = NSPredicate(format: "id == %@", todo.id)
            fetchRequest.fetchLimit = 1
            
            do {
                let results = try context.fetch(fetchRequest)
                let entity: TodoEntity
                
                if let existingEntity = results.first { // обновление
                    entity = existingEntity
                } else { // создание
                    entity = TodoEntity(context: context)
                }
                
                self.updateEntity(entity, from: todo)
                
                try context.save()
                
                DispatchQueue.main.async {
                    completion(.success(()))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    func deleteTodo(id: String, completion: @escaping (Result<Void, Error>) -> Void) {
        manager.performBackgroundTask { context in
            let fetchRequest = NSFetchRequest<TodoEntity>(entityName: "TodoEntity")
            fetchRequest.predicate = NSPredicate(format: "id == %@", id)
            fetchRequest.fetchLimit = 1
            
            do {
                if let entityToDelete = try context.fetch(fetchRequest).first {
                    context.delete(entityToDelete)
                    try context.save()
                    DispatchQueue.main.async { completion(.success(())) }
                } else {
                    DispatchQueue.main.async { completion(.success(())) }
                }
            } catch {
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }
    }
    
    func batchInsertTodos(from dtos: [Todo], completion: @escaping (Result<Void, any Error>) -> Void) {
        guard !dtos.isEmpty else {
            DispatchQueue.main.async { completion(.success(())) }
            return
        }
        
        manager.performBackgroundTask { context in
            let batchInsert = NSBatchInsertRequest(entityName: "TodoEntity", objects: dtos.map { todo -> [String: Any] in
                return [
                    "id": String(todo.id),
                    "title": todo.title,
                    "todoDescription": todo.title,
                    "dateOfCreation": todo.dateOfCreation,
                    "isCompleted": todo.isCompleted
                ]
            })
            batchInsert.resultType = .statusOnly
            
            do {
                let result = try context.execute(batchInsert) as? NSBatchInsertResult
                
                if result?.result as? Bool == true {
                    print("batch insert success")
                    DispatchQueue.main.async { completion(.success(())) }
                } else {
                    let error = NSError(domain: "CoreDataStore", code: 1, userInfo: nil)
                    DispatchQueue.main.async { completion(.failure(error)) }
                    print("batch insert failed or returned unexpected result \(error)")
                }
            } catch {
                DispatchQueue.main.async { completion(.failure(error)) }
                print("batch insert failed with error \(error)")
            }
        }
    }
    
    private func mapEntityToDomain(_ entity: TodoEntity) -> Todo? {
        guard let id = entity.id,
              let title = entity.title,
              let date = entity.dateOfCreation else { return nil }
        
        return Todo(
            id: id,
            title: title,
            description: entity.todoDescription ?? "",
            dateOfCreation: date,
            isCompleted: entity.isCompleted
        )
    }
    
    private func updateEntity(_ entity: TodoEntity, from domain: Todo) {
        entity.id = domain.id
        entity.title = domain.title
        entity.todoDescription = domain.description
        entity.dateOfCreation = domain.dateOfCreation
        entity.isCompleted = domain.isCompleted
    }
}
