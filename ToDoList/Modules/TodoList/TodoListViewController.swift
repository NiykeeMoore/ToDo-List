//
//  TodoListViewController.swift
//  ToDoList
//
//  Created by Niykee Moore on 29.03.2025.
//

import UIKit

protocol TodoListViewInput: AnyObject {
    func displayError(error: Error)
    func showShare(for todo: Todo)
    func updateTodoCounter(_ count: Int)
}

final class TodoListViewController: UIViewController,
                                    UITableViewDelegate, UITableViewDataSource,
                                    UISearchResultsUpdating,
                                    TodoListViewInput,
                                    CustomTabBarDelegate,
                                    DataProviderDelegate {
    // MARK: - Dependencies
    private let presenter: TodoPresenterInput
    private let dataProvider: TodoListDataProviderProtocol
    
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
    init(presenter: TodoPresenterInput, dataProvider: TodoListDataProviderProtocol) {
        self.presenter = presenter
        self.dataProvider = dataProvider
        super.init(nibName: nil, bundle: nil)
        self.dataProvider.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .appBlack
        
        do {
            try dataProvider.performFetch()
        } catch {
            presenter.frcFetchFailed(error: error)
        }
        
        presenter.viewDidLoad()
        
        configureUI()
        configureConstraints()
        
        customTabBar.delegate = self
        updateTodoCounterFromProvider()
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
        return dataProvider.numberOfRows(in: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TodoListCell.reuseIdentifier, for: indexPath) as? TodoListCell else { return UITableViewCell() }
        
        if let todoEntity = dataProvider.object(at: indexPath) {
            cell.configureCell(
                title: todoEntity.title ?? "",
                description: todoEntity.todoDescription ?? "",
                date: todoEntity.dateOfCreation?.formattedDisplayString ?? "",
                state: todoEntity.isCompleted
            )
        }
        
        cell.checkBox.didCheckBoxTapped = { [weak self] in
            guard let self else { return }
            self.presenter.checkboxDidTapped(at: indexPath)
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
        let config = UIContextMenuConfiguration(identifier: indexPath as NSCopying, previewProvider: nil) { [weak self] _ in
            guard let self else { return nil }
            return self.presenter.getContextMenu(for: indexPath)
        }
        return config
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
        presenter.searchTextChanged(to: searchController.searchBar.text ?? "")
    }
    
    // MARK: - TodoListViewInput
    func displayError(error: any Error) {
        let alert = UIAlertController(title: "Ошибка",
                                      message: error.localizedDescription,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func showShare(for todo: Todo) {
        var sourceViewForPopover: UIView?
        
        if let visibleIndexPaths = todoListTableView.indexPathsForVisibleRows {
            for indexPath in visibleIndexPaths {
                if let entity = dataProvider.object(at: indexPath), entity.id == todo.id {
                    sourceViewForPopover = todoListTableView.cellForRow(at: indexPath)
                    break
                }
            }
        }
        
        presenter.router?.showShareScreen(
            with: todo.title,
            sourceView: sourceViewForPopover,
            sourceRect: sourceViewForPopover?.bounds
        )
    }
    
    // MARK: - CustomTabBarDelegate
    func didTapCreateTodoButton() {
        presenter.didTappedCreateTodoButton()
    }
    
    // MARK: - DataProviderDelegate
    func dataProviderWillChangeContent() {
        todoListTableView.beginUpdates()
    }
    
    func dataProviderDidChangeContent() {
        todoListTableView.endUpdates()
        todoListTableView.reloadData()
        updateTodoCounterFromProvider()
    }
    
    func dataProviderDidInsertObject(at indexPath: IndexPath) {
        todoListTableView.insertRows(at: [indexPath], with: .automatic)
    }
    
    func dataProviderDidDeleteObject(at indexPath: IndexPath) {
        todoListTableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
    func dataProviderDidUpdateObject(at indexPath: IndexPath) {
        todoListTableView.reloadRows(at: [indexPath], with: .none)
    }
    
    func dataProviderDidMoveObject(from oldIndexPath: IndexPath, to newIndexPath: IndexPath) {
        todoListTableView.deleteRows(at: [oldIndexPath], with: .automatic)
        todoListTableView.insertRows(at: [newIndexPath], with: .automatic)
    }
    
    func updateTodoCounter(_ count: Int) {
        customTabBar.updateTodoCounterLabel(count)
    }
    
    private func updateTodoCounterFromProvider() {
        let count = dataProvider.numberOfRows(in: 0)
        updateTodoCounter(count)
    }
}
