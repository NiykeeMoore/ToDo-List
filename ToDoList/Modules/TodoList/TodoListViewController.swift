//
//  TodoListViewController.swift
//  ToDoList
//
//  Created by Niykee Moore on 29.03.2025.
//

import UIKit

final class TodoListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
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
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .appBlack
        
        configureUI()
        configureConstraints()
    }
    
    // MARK: - UI Setup
    private func configureUI() {
        [todoListTableView].forEach {
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
            todoListTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
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
}
