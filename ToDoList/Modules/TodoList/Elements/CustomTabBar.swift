//
//  CustomTabBar.swift
//  ToDoList
//
//  Created by Niykee Moore on 29.03.2025.
//

import UIKit

protocol CustomTabBarDelegate: AnyObject {
    func didTapCreateTodoButton()
}

final class CustomTabBar: UIView {
    weak var delegate: CustomTabBarDelegate?
    
    // MARK: - UI Elements
    private lazy var todosCounterLabel: UILabel = {
        let label = UILabel()
        label.text = "7 Задач"
        label.textColor = .appWhite
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 11)
        return label
    }()
    
    private lazy var createTodoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "square.and.pencil"), for: .normal)
        button.tintColor = .appYellow
        button.addTarget(self, action: #selector(createTodoButtonTapped), for: .touchUpInside)
        return button
    }()
    
    //MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .appGray
        
        [todosCounterLabel, createTodoButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            todosCounterLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            todosCounterLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -14),
            
            createTodoButton.centerYAnchor.constraint(equalTo: todosCounterLabel.centerYAnchor),
            createTodoButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            createTodoButton.widthAnchor.constraint(equalToConstant: 68),
            createTodoButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Actions
    @objc func createTodoButtonTapped() {
        delegate?.didTapCreateTodoButton()
    }
}
