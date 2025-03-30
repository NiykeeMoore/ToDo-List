//
//  TodoInteractor.swift
//  ToDoList
//
//  Created by Niykee Moore on 29.03.2025.
//

import Foundation

protocol TodoInteractorInput {
    func fetchTodos()
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
}
