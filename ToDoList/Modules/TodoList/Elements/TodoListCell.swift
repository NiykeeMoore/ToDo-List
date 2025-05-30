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
    lazy var checkBox = CheckBox()
    
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
    
    lazy var textDataStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            titleLabel,
            descriptionLabel,
            dateOfCreationLabel
        ])
        stack.axis = .vertical
        stack.spacing = 6
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
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
        super.prepareForReuse()
        let defaultAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.appWhite,
            .strikethroughStyle: NSNumber(value: 0)
        ]
        titleLabel.attributedText = NSAttributedString(string: "", attributes: defaultAttributes)
        
        titleLabel.text = nil
        titleLabel.attributedText = nil
        descriptionLabel.text = nil
        dateOfCreationLabel.text = nil
        checkBox.setState(false)
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        
        [checkBox, textDataStackView].forEach {
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
            
            textDataStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            textDataStackView.leadingAnchor.constraint(equalTo: checkBox.trailingAnchor, constant: 8),
            textDataStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            textDataStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    // MARK: - Helper methods
    func configureCell(
        title: String,
        description: String,
        date: String,
        isCompleted: Bool
    ) {
        descriptionLabel.text = description
        dateOfCreationLabel.text = date
        checkBox.setState(isCompleted)
        
        if isCompleted {
            titleLabel.textColor = .appWhiteHalfOpacity
            descriptionLabel.textColor = .appWhiteHalfOpacity
            
            let attributedTitle = NSAttributedString(
                string: title,
                attributes: [.strikethroughStyle: NSUnderlineStyle.single.rawValue]
            )
            titleLabel.attributedText = attributedTitle
            
        } else {
            titleLabel.textColor = .appWhite
            descriptionLabel.textColor = .appWhite
            titleLabel.text = title
        }
    }
}
