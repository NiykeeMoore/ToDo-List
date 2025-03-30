//
//  TodoPresenter.swift
//  ToDoList
//
//  Created by Niykee Moore on 29.03.2025.
//

import Foundation

protocol TodoPresenterInput {
    func viewDidLoad()
    func checkboxDidTapped(at index: Int)
}

final class TodoPresenter: TodoPresenterInput, TodoInteractorOutput {
    // MARK: - Dependencies
    weak var viewController: TodoListViewInput?
    var interactor: TodoInteractorInput
    
    // MARK: - Properties
    private var todos: [Todo] = []
    
    // MARK: - Initialization
    init(interactor: TodoInteractorInput) {
        self.interactor = interactor
    }
    
    // MARK: - TodoInteractorInput
    func viewDidLoad() {
        interactor.fetchTodos()
    }
    
    func checkboxDidTapped(at index: Int) {
        interactor.toggleTodoComplition(at: index)
    }
    
    // MARK: - TodoInteractorOutput
    func didFetchTodos(todos: [Todo]) {
        self.todos = todos
        viewController?.todosLoaded(todos: todos)
    }
    
    func didFailToFetchTodos(error: Error) {
        viewController?.displayError(error: error)
    }
}
