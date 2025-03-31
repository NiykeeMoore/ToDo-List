//
//  TodoDetailRouter.swift
//  ToDoList
//
//  Created by Niykee Moore on 30.03.2025.
//

import UIKit

protocol TodoDetailRouterInput: AnyObject {
    var view: UIViewController? { get set }
    func navigateBack()
}

final class TodoDetailRouter: TodoDetailRouterInput {
    weak var view: UIViewController?
    
    func navigateBack() {
        self.view?.navigationController?.popViewController(animated: true)
    }
}
