//
//  TodoPresenter.swift
//  ToDoList
//
//  Created by Niykee Moore on 29.03.2025.
//

import UIKit

protocol TodoPresenterInput {
    var router: TodoListRouter? { get }
    func viewDidLoad()
    func checkboxDidTapped(at indexPath: IndexPath)
    func didTappedCreateTodoButton()
    func didTappedEditMenuOption(option: ContextMenu, at indexPath: IndexPath)
    func searchTextChanged(to searchText: String)
    func getContextMenu(for indexPath: IndexPath) -> UIMenu?
    func frcFetchFailed(error: Error)
}

final class TodoListPresenter: TodoPresenterInput, TodoInteractorOutput {
    // MARK: - Dependencies
    weak var viewController: TodoListViewInput?
    var interactor: TodoInteractorInput
    var router: TodoListRouter?
    private let dataProvider: TodoListDataProviderProtocol
    private let coreDataManager: CoreDataManaging
    
    // MARK: - Properties
    private var todos: [Todo] = []
    private var filteredTodos: [Todo] = []
    private var currentSearchText: String = ""
    
    // MARK: - Initialization
    init(
        interactor: TodoInteractorInput,
        router: TodoListRouter?,
        dataProvider: TodoListDataProviderProtocol,
        coreDataManager: CoreDataManaging
    ) {
        self.interactor = interactor
        self.router = router
        self.dataProvider = dataProvider
        self.coreDataManager = coreDataManager
    }
    
    // MARK: - TodoInteractorInput
    func viewDidLoad() {
        interactor.fetchTodosIfNeeded()
    }
    
    func frcFetchFailed(error: Error) {
        viewController?.displayError(error: error)
    }
    
    func checkboxDidTapped(at indexPath: IndexPath) {
        guard
            let entity = dataProvider.object(at: indexPath),
            let todoId = entity.id else { return }
        interactor.toggleTodoCompletion(for: todoId)
    }
    
    
    func didTappedCreateTodoButton() {
        router?.navigateToTodoDetail(with: nil, coreDataManager: coreDataManager)
    }
    
    func didTappedEditMenuOption(option: ContextMenu, at indexPath: IndexPath) {
        guard
            let entity = dataProvider.object(at: indexPath),
            let todoId = entity.id else { return }
        
        switch option {
        case .edit:
            let todo = mapEntityToDomain(entity)
            router?.navigateToTodoDetail(with: todo, coreDataManager: coreDataManager)
        case .share:
            if let todo = mapEntityToDomain(entity) {
                viewController?.showShare(for: todo)
            }
        case .delete:
            interactor.deleteTodo(with: todoId)
        }
    }
    
    func getContextMenu(for indexPath: IndexPath) -> UIMenu? {
        let editAction = UIAction(
            title: ContextMenu.edit.rawValue,
            image: .iconContextMenuEdit) { [weak self] _ in
                guard let self else { return }
                self.didTappedEditMenuOption(option: .edit, at: indexPath)
            }
        
        let shareAction = UIAction(
            title: ContextMenu.share.rawValue,
            image: .iconContextMenuShare) { [weak self] _ in
                guard let self else { return }
                self.didTappedEditMenuOption(option: .share, at: indexPath)
            }
        
        let deleteAction = UIAction(
            title: ContextMenu.delete.rawValue,
            image: .iconContextMenuDelete) { [weak self] _ in
                guard let self else { return }
                self.didTappedEditMenuOption(option: .delete, at: indexPath)
            }
        
        return UIMenu(title: "", children: [editAction, shareAction, deleteAction])
    }
    
    func searchTextChanged(to searchText: String) {
        dataProvider.updatePredicate(for: searchText)
    }
    
    // MARK: - TodoInteractorOutput
    
    func didFailToFetchTodos(error: Error) {
        viewController?.displayError(error: error)
    }
    
    // MARK: - Helpers
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
}
