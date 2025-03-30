//
//  TodoInteractor.swift
//  ToDoList
//
//  Created by Niykee Moore on 29.03.2025.
//

import Foundation

protocol TodoInteractorInput {
    func fetchTodos()
    func toggleTodoComplition(at index: Int)
}

protocol TodoInteractorOutput: AnyObject {
    func didFetchTodos(todos: [Todo])
    func didFailToFetchTodos(error: Error)
}

final class TodoInteractor: TodoInteractorInput {
    // MARK: - Dependencies
    weak var presenter: TodoInteractorOutput?
    private let todosLoader: TodosLoader
    
    // MARK: - Properties
    private var todos: [Todo] = []
    
    // MARK: - Initialization
    init(todosLoader: TodosLoader) {
        self.todosLoader = todosLoader
    }
    
    //MARK: - TodoInteractorInput
    func fetchTodos() {
        todosLoader.load { [weak self] result in
            guard let self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let fetchedTodos):
                    self.todos = fetchedTodos
                    self.presenter?.didFetchTodos(todos: self.todos)
                case .failure(let error):
                    self.presenter?.didFailToFetchTodos(error: error)
                }
            }
        }
    }
    
    func toggleTodoComplition(at index: Int) {
        let updatedTask = todos[index].withUpdatedComplition(isCompleted: !todos[index].isCompleted)
        todos[index] = updatedTask
        
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.presenter?.didFetchTodos(todos: self.todos)
        }
    }
}
