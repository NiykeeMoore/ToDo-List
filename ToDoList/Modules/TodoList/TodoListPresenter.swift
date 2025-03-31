//
//  TodoPresenter.swift
//  ToDoList
//
//  Created by Niykee Moore on 29.03.2025.
//

import Foundation

protocol TodoPresenterInput {
    var router: TodoListRouter? { get }
    func viewDidLoad()
    func checkboxDidTapped(at index: Int)
    func didTappedCreateTodoButton()
    func didTappedEditMenuOption(option: ContextMenu, at index: Int)
    func numberOfRows() -> Int
    func getTodo(at index: Int) -> Todo?
    func getIndex(for todoId: String) -> Int?
    func searchTextChanged(to searchText: String)
}

final class TodoListPresenter: TodoPresenterInput, TodoInteractorOutput {
    // MARK: - Dependencies
    weak var viewController: TodoListViewInput?
    var interactor: TodoInteractorInput
    var router: TodoListRouter?
    private let coreDataManager: CoreDataManaging
    
    // MARK: - Properties
    private var todos: [Todo] = []
    private var filteredTodos: [Todo] = []
    private var currentSearchText: String = ""
    
    // MARK: - Initialization
    init(interactor: TodoInteractorInput, coreDataManager: CoreDataManaging) {
        self.interactor = interactor
        self.coreDataManager = coreDataManager
    }
    
    // MARK: - TodoInteractorInput
    func viewDidLoad() {
        currentSearchText = ""
        interactor.fetchTodos()
    }
    
    func checkboxDidTapped(at index: Int) {
        let todoToToggle = isSearching() ? filteredTodos[index] : todos[index]
        if let originalIndex = todos.firstIndex(where: { $0.id == todoToToggle.id }) {
            interactor.toggleTodoComplition(at: originalIndex)
        }
    }
    
    func didTappedCreateTodoButton() {
        router?.navigateToTodoDetail(with: nil, coreDataManager: coreDataManager)
    }
    
    func didTappedEditMenuOption(option: ContextMenu, at index: Int) {
        guard let todo = getTodo(at: index) else {
            assertionFailure("didTappedEditMenuOption: bad index for todo")
            return
        }
        
        let selectedTodo = isSearching() ? filteredTodos[index] : todos[index]
        
        switch option {
        case .edit:
            router?.navigateToTodoDetail(with: todo, coreDataManager: coreDataManager)
            
        case .share:
            viewController?.showShare(for: todo)
            
        case .delete:
            if let originalIndex = todos.firstIndex(where: { $0.id == selectedTodo.id }) {
                interactor.deleteTodo(at: originalIndex)
            }
        }
    }
    
    func numberOfRows() -> Int {
        return isSearching() ? filteredTodos.count : todos.count
    }
    
    func getTodo(at index: Int) -> Todo? {
        let array = isSearching() ? filteredTodos : todos
        guard array.indices.contains(index) else {
            print("getTodo: bad index")
            return nil
        }
        return array[index]
    }
    
    func getIndex(for todoId: String) -> Int? {
        let array = isSearching() ? filteredTodos : todos
        return array.firstIndex(where: { $0.id == todoId })
    }
    
    func searchTextChanged(to searchText: String) {
        currentSearchText = searchText.lowercased()
        
        if currentSearchText.isEmpty {
            filteredTodos = todos
        } else {
            filteredTodos = todos.filter { todo in
                let titleMatch = todo.title.lowercased().contains(currentSearchText)
                let descriptionMatch = todo.description.lowercased().contains(currentSearchText)
                return titleMatch || descriptionMatch
            }
        }
        viewController?.reloadData(todoCount: numberOfRows())
    }
    
    // MARK: - TodoInteractorOutput
    func didFetchTodos(todos: [Todo]) {
        self.todos = todos
        searchTextChanged(to: currentSearchText)
    }
    
    func didFailToFetchTodos(error: Error) {
        viewController?.displayError(error: error)
    }
    
    func didUpdateTodo(at index: Int, with todo: Todo) {
        guard todos.indices.contains(index) else { return }
        self.todos[index] = todo
        
        if isSearching() {
            if let filteredIndex = filteredTodos.firstIndex(where: { $0.id == todo.id }) {
                if (todo.title.lowercased().contains(currentSearchText) || todo.description.lowercased().contains(currentSearchText)) {
                    filteredTodos[filteredIndex] = todo
                    viewController?.reloadRow(at: filteredIndex, todoCount: self.filteredTodos.count)
                } else {
                    filteredTodos.remove(at: filteredIndex)
                    viewController?.reloadData(todoCount: self.filteredTodos.count)
                }
                
            } else {
                if (todo.title.lowercased().contains(currentSearchText) || todo.description.lowercased().contains(currentSearchText)) {
                    searchTextChanged(to: currentSearchText)
                }
            }
        } else {
            viewController?.reloadRow(at: index, todoCount: self.todos.count)
        }
    }
    
    func didDeleteTodo(at index: Int) {
        guard todos.indices.contains(index) else { return }
        let deletedTodoId = todos[index].id
        
        self.todos.remove(at: index)
        
        if isSearching() {
            if let filteredIndex = filteredTodos.firstIndex(where: { $0.id == deletedTodoId }) {
                filteredTodos.remove(at: filteredIndex)
                viewController?.deleteRow(at: filteredIndex, todoCount: self.filteredTodos.count)
            }
        } else {
            viewController?.deleteRow(at: index, todoCount: self.todos.count)
        }
    }
    
    // MARK: - Helpers
    private func isSearching() -> Bool {
        return !currentSearchText.isEmpty
    }
}
