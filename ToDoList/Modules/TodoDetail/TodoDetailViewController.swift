//
//  TodoDetailViewController.swift
//  ToDoList
//
//  Created by Niykee Moore on 30.03.2025.
//

import UIKit

protocol TodoDetailViewInput: AnyObject {
    func todoLoaded(_ todo: Todo?)
    func displaySaveError(_ error: Error)
}

final class TodoDetailViewController: UIViewController, TodoDetailViewInput {
    // MARK: - Dependencies
    var presenter: TodoDetailPresenterInput?
    
    // MARK: - UI Elements
    private lazy var titleTextField: UITextField = {
        let textField = UITextField()
        textField.font = .boldSystemFont(ofSize: 34)
        textField.textColor = .appWhite
        textField.placeholder = "Тема todo"
        return textField
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .appWhiteHalfOpacity
        return label
    }()
    
    private lazy var descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .clear
        textView.textColor = .appWhite
        textView.font = .systemFont(ofSize: 16)
        return textView
    }()
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .appBlack
        presenter?.viewDidLoad()
        
        setupUI()
        setupConstraints()
    }
    
    //MARK: - UI Setup
    func setupUI() {
        [titleTextField, dateLabel, descriptionTextView].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        configureNavigationBar()
    }
    
    private func configureNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = false
        
        let backButton = UIButton(type: .system)
        if let chevronImage = UIImage(systemName: "chevron.left") {
            backButton.setImage(chevronImage, for: .normal)
        }
        
        backButton.setTitle(" Назад", for: .normal)
        backButton.sizeToFit()
        backButton.tintColor = .appYellow
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        
        let barButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem = barButtonItem
    }
    
    //MARK: - Constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            titleTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            titleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            dateLabel.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 8),
            dateLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            
            descriptionTextView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 16),
            descriptionTextView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            descriptionTextView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            descriptionTextView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    //MARK: - TodoDetailViewInput
    func todoLoaded(_ todo: Todo?) {
        titleTextField.text = todo?.title
        descriptionTextView.text = todo?.description
        dateLabel.text = todo?.dateOfCreation.formattedDisplayString
    }
    
    func displaySaveError(_ error: Error) {
        let alert = UIAlertController(
            title: "Ошибка сохранения",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func backButtonTapped() {
        presenter?.buttonBackPressed(currentTitle: titleTextField.text, currentDescription: descriptionTextView.text)
    }
}
