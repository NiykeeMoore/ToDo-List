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
            let sortDescriptor = NSSortDescriptor(keyPath: \TodoEntity.dateOfCreation, ascending: true)
            fetchRequest.sortDescriptors = [sortDescriptor]

            do {
                let entities = try context.fetch(fetchRequest)
                let todos = entities.compactMap { self.mapEntityToDomain($0) }
                 completion(.success(todos))
                 print("Fetched \(todos.count) todos from CoreData.")
            } catch {
                print("Failed to fetch todos: \(error)")
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
                    print("Updating existing TodoEntity with id: \(todo.id)")
                } else { // создание
                    entity = TodoEntity(context: context)
                    print("Creating new TodoEntity with id: \(todo.id)")
                }
                
                self.updateEntity(entity, from: todo)
                
                try context.save()
                print("Background context saved for id: \(todo.id)")

                DispatchQueue.main.async {
                    completion(.success(()))
                }
            } catch {
                print("Failed to save todo (id: \(todo.id)): \(error)")
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
                    print("Deleting TodoEntity with id: \(id)")
                    try context.save()
                     print("Background context saved after deletion of id: \(id)")
                    DispatchQueue.main.async { completion(.success(())) }
                } else {
                    print("TodoEntity with id \(id) not found for deletion.")
                     DispatchQueue.main.async { completion(.success(())) }
                }
            } catch {
                 print("Failed to delete todo (id: \(id)): \(error)")
                 DispatchQueue.main.async { completion(.failure(error)) }
            }
        }
    }

    private func mapEntityToDomain(_ entity: TodoEntity) -> Todo? {
        guard let id = entity.id,
              let title = entity.title,
              let date = entity.dateOfCreation else {
            print("Warning: Skipping entity due to missing mandatory fields.")
            return nil
        }

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
