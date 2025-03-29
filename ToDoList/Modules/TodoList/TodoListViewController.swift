//
//  TodoListViewController.swift
//  ToDoList
//
//  Created by Niykee Moore on 29.03.2025.
//

import UIKit

final class TodoListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating {
    // MARK: - UI Elements
    private lazy var todoListTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(TodoListCell.self, forCellReuseIdentifier: TodoListCell.reuseIdentifier)
        tableView.separatorColor = .appStroke
        tableView.separatorInset = .init(top: 0, left: 20, bottom: 0, right: 20)
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
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .appBlack
        
        configureUI()
        configureConstraints()
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
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 106
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TodoListCell.reuseIdentifier) as? TodoListCell else { return UITableViewCell() }
        cell.configureCell(title: "test", description: "sdfka;slkf;lsakgl;ksdfkgs\n ;lskdfgks;dlfkg;skd;fgks;dkfggfdkgjdjfgjdhfjghdfg;ldkfggsjdhfgjshdgkjshdjfkghsdg", date: "ssdf.d.sdf.")
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
                title: "Редактировать",
                image: .iconContextMenuEdit) { _ in
                    // todo edit
                }
            
            let shareAction = UIAction(
                title: "Поделиться",
                image: .iconContextMenuShare) { _ in
                    // todo share
                }
            
            let deleteAction = UIAction(
                title: "Удалить",
                image: .iconContextMenuDelete,
                attributes: .destructive) { _ in
                    // todo delete
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
}
