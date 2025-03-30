//
//  TodoRouter.swift
//  ToDoList
//
//  Created by Niykee Moore on 29.03.2025.
//

import UIKit

protocol TodoListRouter: AnyObject {
    func navigateToTodoDetail(from viewController: UIViewController)
}

final class TodoListRouterImpl: TodoListRouter {
    func navigateToTodoDetail(from viewController: UIViewController) {
        let detailViewController = TodoDetailModuleBuilder.createModule(with: nil)
        viewController.navigationController?.pushViewController(detailViewController, animated: true)
    }
}
