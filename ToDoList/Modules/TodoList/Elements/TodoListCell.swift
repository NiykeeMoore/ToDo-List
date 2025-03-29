//
//  TodoListCell.swift
//  ToDoList
//
//  Created by Niykee Moore on 29.03.2025.
//

import UIKit

final class TodoListCell: UITableViewCell {
    // MARK: - Properties
    static let reuseIdentifier = String(describing: TodoListCell.self)
    
    // MARK: - UI Elements
    private lazy var checkBox: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "checkmark.circle"))
        imageView.tintColor = .appYellow
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 16)
        label.textColor = .appWhite
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .appWhite
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private lazy var dateOfCreationLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .appWhiteHalfOpacity
        return label
    }()
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - prepareForReuse
    override func prepareForReuse() {
        titleLabel.text = nil
        descriptionLabel.text = nil
        dateOfCreationLabel.text = nil
        checkBox.image = nil
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        [checkBox, titleLabel, descriptionLabel, dateOfCreationLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
    }
    
    // MARK: - Constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            checkBox.widthAnchor.constraint(equalToConstant: 24),
            checkBox.heightAnchor.constraint(equalToConstant: 24),
            checkBox.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            checkBox.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: checkBox.trailingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            dateOfCreationLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 6),
            dateOfCreationLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            dateOfCreationLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
    }
    
    // MARK: - Helper methods
    func configureCell(title: String, description: String, date: String) {
        titleLabel.text = title
        descriptionLabel.text = description
        dateOfCreationLabel.text = date
        checkBox.image = UIImage(systemName: "checkmark.circle")
    }
}
