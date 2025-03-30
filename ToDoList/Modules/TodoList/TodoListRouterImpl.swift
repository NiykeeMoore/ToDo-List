//
//  TodoRouter.swift
//  ToDoList
//
//  Created by Niykee Moore on 29.03.2025.
//

import UIKit

protocol TodoListRouter: AnyObject {
    func navigateToTodoDetail()
}

final class TodoListRouterImpl: TodoListRouter {
    weak var viewController: UIViewController?
    
    func navigateToTodoDetail() {
        let detailViewController = TodoDetailModuleBuilder.createModule(with: nil)
        viewController?.navigationController?.pushViewController(detailViewController, animated: true)
    }
}
