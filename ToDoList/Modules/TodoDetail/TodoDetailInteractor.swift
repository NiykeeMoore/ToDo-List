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
        todoStore.saveTodo(todo) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                print("Interactor: Сохранили todo с id \(todo.id)")
                self.presenter?.didSaveTodoSuccessfully()
            case .failure(let error):
                // Произошла ошибка, сообщаем презентеру
                print("Interactor: Ошибка сохранения todo с id \(todo.id). Ошибка: \(error)")
                self.presenter?.didFailToSaveTodo(error: error)
            }
        }
    }
}
