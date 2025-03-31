//
//  TodoListViewController.swift
//  ToDoList
//
//  Created by Niykee Moore on 29.03.2025.
//

import UIKit

protocol TodoListViewInput: AnyObject {
    func reloadData(todoCount: Int)
    func displayError(error: Error)
    func reloadRow(at index: Int, todoCount: Int)
    func deleteRow(at index: Int, todoCount: Int)
    func showShare(for todo: Todo)
}

final class TodoListViewController: UIViewController,
                                    UITableViewDelegate, UITableViewDataSource,
                                    UISearchResultsUpdating,
                                    TodoListViewInput,
                                    CustomTabBarDelegate {
    // MARK: - Dependencies
    private let presenter: TodoPresenterInput
    
    // MARK: - UI Elements
    private lazy var todoListTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(TodoListCell.self, forCellReuseIdentifier: TodoListCell.reuseIdentifier)
        tableView.separatorColor = .appStroke
        tableView.separatorInset = .init(top: 0, left: 20, bottom: 0, right: 20)
        tableView.allowsSelection = false
        return tableView
    }()
    
    private let customTabBar = CustomTabBar()
    
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.autocapitalizationType = .none
        searchController.searchBar.tintColor = .appWhite
        return searchController
    }()
    
    //MARK: - Initialization
    init(presenter: TodoPresenterInput) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .appBlack
        
        presenter.viewDidLoad()
        
        configureUI()
        configureConstraints()
        
        customTabBar.delegate = self
    }
    
    // MARK: - UI Setup
    private func configureUI() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Задачи"
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchBar.searchTextField.textColor = .appWhite
        
        [todoListTableView, customTabBar].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    // MARK: - Constraints
    private func configureConstraints() {
        NSLayoutConstraint.activate([
            todoListTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            todoListTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            todoListTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            todoListTableView.bottomAnchor.constraint(equalTo: customTabBar.topAnchor),
            
            customTabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customTabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customTabBar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            customTabBar.heightAnchor.constraint(equalToConstant: 85),
            
        ])
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.numberOfRows()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TodoListCell.reuseIdentifier, for: indexPath) as? TodoListCell,
              let todo = presenter.getTodo(at: indexPath.row)
        else { return UITableViewCell() }
        
        cell.configureCell(
            title: todo.title,
            description: todo.description,
            date: todo.dateOfCreation.formattedDisplayString,
            state: todo.isCompleted
        )
        
        cell.checkBox.didCheckBoxTapped = { [weak self] in
            guard let self else { return }
            self.presenter.checkboxDidTapped(at: indexPath.row)
        }
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func tableView(
        _ tableView: UITableView,
        contextMenuConfigurationForRowAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: indexPath as NSCopying, previewProvider: nil) { _ in
            let editAction = UIAction(
                title: ContextMenu.edit.rawValue,
                image: .iconContextMenuEdit) { [weak self] _ in
                    guard let self else { return }
                    self.presenter.didTappedEditMenuOption(option: .edit, at: indexPath.row)
                }
            
            let shareAction = UIAction(
                title: ContextMenu.share.rawValue,
                image: .iconContextMenuShare) { [weak self] _ in
                    guard let self else { return }
                    self.presenter.didTappedEditMenuOption(option: .share, at: indexPath.row)
                }
            
            let deleteAction = UIAction(
                title: ContextMenu.delete.rawValue,
                image: .iconContextMenuDelete,
                attributes: .destructive) { [weak self] _ in
                    guard let self else { return }
                    self.presenter.didTappedEditMenuOption(option: .delete, at: indexPath.row)
                }
            
            return UIMenu(title: "", children: [editAction, shareAction, deleteAction])
        }
    }
    
    func tableView(
        _ tableView: UITableView,
        previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration
    ) -> UITargetedPreview? {
        return makeTargetedPreview(for: configuration)
    }
    
    func tableView(
        _ tableView: UITableView,
        previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration
    ) -> UITargetedPreview? {
        return makeTargetedPreview(for: configuration)
    }
    
    private func makeTargetedPreview(for configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        guard
            let indexPath = configuration.identifier as? IndexPath,
            let cell = todoListTableView.cellForRow(at: indexPath) as? TodoListCell else { return nil }
        
        let parameters = UIPreviewParameters()
        parameters.backgroundColor = .appGray
        
        let enlargedRect = cell.textDataStackView.bounds.insetBy(dx: -16, dy: -12)
        parameters.visiblePath = UIBezierPath(roundedRect: enlargedRect, cornerRadius: 12)
        
        return UITargetedPreview(view: cell.textDataStackView, parameters: parameters)
    }
    
    // MARK: - UISearchController
    func updateSearchResults(for searchController: UISearchController) {
        
    }
    
    // MARK: - TodoListViewInput
    func reloadData(todoCount: Int) {
        todoListTableView.reloadData()
        customTabBar.updateTodoCounterLabel(todoCount)
    }
    
    func displayError(error: any Error) {
        let alert = UIAlertController(title: "Ошибка",
                                      message: error.localizedDescription,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func reloadRow(at index: Int, todoCount: Int) {
        let indexPath = IndexPath(row: index, section: 0)
        if todoListTableView.indexPathsForVisibleRows?.contains(indexPath) ?? false {
            todoListTableView.reloadRows(at: [indexPath], with: .automatic)
        }
        customTabBar.updateTodoCounterLabel(todoCount)
    }
    
    func deleteRow(at index: Int, todoCount: Int) {
        let indexPath = IndexPath(row: index, section: 0)
        
        todoListTableView.performBatchUpdates({
            todoListTableView.deleteRows(at: [indexPath], with: .automatic)
        }, completion: { [weak self] _ in
            guard let self else { return }
            self.customTabBar.updateTodoCounterLabel(todoCount)
        })
    }
    
    func showShare(for todo: Todo) {
        var sourceViewForPopover: UIView? = nil
        if let index = presenter.getIndex(for: todo.id) {
            let indexPath = IndexPath(row: index, section: 0)
            sourceViewForPopover = todoListTableView.cellForRow(at: indexPath)
        }
        
        presenter.router?.showShareScreen(
            with: todo.title,
            sourceView: sourceViewForPopover,
            sourceRect: sourceViewForPopover?.bounds
        )
        // Давай сделаем так: Presenter должен иметь метод для вызова share роутера.

        // --- ПЕРЕДЕЛЫВАЕМ ЛОГИКУ SHARE ЕЩЕ РАЗ ---

        // 1. Убираем showShare из ViewInput
        // protocol TodoListViewInput: AnyObject {
        //     ...
        //     // func showShare(for todo: Todo) // УБИРАЕМ
        // }
        // final class TodoListViewController: /*...*/ {
        //     // func showShare(for todo: Todo) { ... } // УБИРАЕМ
        // }

        // 2. Возвращаем вызов interactor.shareTodo/prepareToShare? Нет, это не даст нам sourceView.

        // 3. Добавляем метод в Presenter Input, который принимает sourceView/Rect
         // protocol TodoPresenterInput: AnyObject {
         //    ...
         //    func shareTodo(_ todo: Todo, sourceView: UIView?, sourceRect: CGRect?)
         //    ...
         // }

        // 4. Presenter вызывает Router
         // final class TodoListPresenter: TodoPresenterInput /*...*/ {
         //    func shareTodo(_ todo: Todo, sourceView: UIView?, sourceRect: CGRect?) {
         //        router?.showShareScreen(with: todo.title, sourceView: sourceView, sourceRect: sourceRect)
         //    }
         // }

        // 5. View вызывает этот новый метод Presenter'а из context menu action
         // В TodoListViewController, в обработчике shareAction контекстного меню:
         // let shareAction = UIAction(...) { [weak self] _ in
         //     guard let self, let todo = self.presenter.getTodo(at: indexPath.row) else { return }
         //     // Находим sourceView/Rect для popover'а
         //     let cell = self.todoListTableView.cellForRow(at: indexPath)
         //     self.presenter.shareTodo(todo, sourceView: cell, sourceRect: cell?.bounds)
         // }
    }
        
    // MARK: - CustomTabBarDelegate
    func didTapCreateTodoButton() {
        presenter.didTappedCreateTodoButton()
    }
}
