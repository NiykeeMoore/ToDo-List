//
//  TodoPresenter.swift
//  ToDoList
//
//  Created by Niykee Moore on 29.03.2025.
//

import UIKit

protocol TodoPresenterInput {
    func viewDidLoad()
    func checkboxDidTapped(at index: Int)
    func didTappedCreateTodoButton()
    func didTappedEditMenuOption(option: ContextMenu, at index: Int)
    func numberOfRows() -> Int
    func getTodo(at index: Int) -> Todo
}

final class TodoListPresenter: TodoPresenterInput, TodoInteractorOutput {
    // MARK: - Dependencies
    weak var viewController: TodoListViewInput?
    var interactor: TodoInteractorInput
    var router: TodoListRouter?
    
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
    
    func didTappedCreateTodoButton() {
        router?.navigateToTodoDetail(with: nil)
    }
    
    func didTappedEditMenuOption(option: ContextMenu, at index: Int) {
        switch option {
        case .edit:
            router?.navigateToTodoDetail(with: todos[index])
            
        case .share:
            interactor.shareTodo(todo: todos[index])
            
        case .delete:
            interactor.deleteTodo(at: index)
        }
    }
    
    func numberOfRows() -> Int {
        return todos.count
    }
    
    func getTodo(at index: Int) -> Todo {
        return todos[index]
    }
    
    // MARK: - TodoInteractorOutput
    func didFetchTodos(todos: [Todo]) {
        self.todos = todos
        viewController?.reloadData(todoCount: todos.count)
    }
    
    func didFailToFetchTodos(error: Error) {
        viewController?.displayError(error: error)
    }
    
    func prepareToShare(todo: Todo) {
        router?.showShareScreen(with: todo.title)
    }
    
    func didUpdateTodo(at index: Int, with todo: Todo) {
        guard todos.indices.contains(index) else { return }
        self.todos[index] = todo
        
        viewController?.reloadRow(at: index, todoCount: self.todos.count)
    }

    func didDeleteTodo(at index: Int) {
        self.todos.remove(at: index)
        viewController?.deleteRow(at: index, todoCount: self.todos.count)
    }
}
