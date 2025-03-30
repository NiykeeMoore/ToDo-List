//
//  CheckBox.swift
//  ToDoList
//
//  Created by Niykee Moore on 30.03.2025.
//

import UIKit

protocol CheckBoxDelegate: AnyObject {
    func checkBoxDidTapped(checkBox: CheckBox)
}

final class CheckBox: UIButton {
    // MARK: - Properties
    weak var delegate: CheckBoxDelegate?
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        tintColor = .appYellow
        addTarget(self, action: #selector(checkboxTapped), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public methods
    func setState(_ checked: Bool) {
        let imageName = checked ? "checkmark.circle" : "circle"
        setImage(UIImage(systemName: imageName), for: .normal)
    }
    
    // MARK: - Action
    @objc private func checkboxTapped() {
        delegate?.checkBoxDidTapped(checkBox: self)
    }
}
