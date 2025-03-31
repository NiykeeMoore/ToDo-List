//
//  TodoDetailInteractor.swift
//  ToDoList
//
//  Created by Niykee Moore on 30.03.2025.
//

import Foundation

protocol TodoDetailInteractorInput: AnyObject {
    func saveTodo(todo: Todo)
    var presenter: TodoDetailInteractorOutput? { get set }
}

protocol TodoDetailInteractorOutput: AnyObject {
    func didSaveTodoSuccessfully()
    func didFailToSaveTodo(error: Error)
}

final class TodoDetailInteractor: TodoDetailInteractorInput {
    // MARK: - Dependencies
    weak var presenter: TodoDetailInteractorOutput?
    private let todoStore: TodoStoring
    
    // MARK: - Initialization
    init(todoStore: TodoStoring) {
        self.todoStore = todoStore
    }
    
    // MARK: - TodoDetailInteractorInput
    func saveTodo(todo: Todo) {
        print("SAVED TODO: \(todo)")
    }
}
