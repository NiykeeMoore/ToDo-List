//
//  TodoRouter.swift
//  ToDoList
//
//  Created by Niykee Moore on 29.03.2025.
//

import UIKit

protocol TodoListRouter: AnyObject {
    func navigateToTodoDetail(with todo: Todo?)
    func showShareScreen(with content: String)
}

final class TodoListRouterImpl: TodoListRouter {
    weak var viewController: UIViewController?
    
    func navigateToTodoDetail(with todo: Todo?) {
        let detailViewController = TodoDetailModuleBuilder.createModule(with: todo)
        viewController?.navigationController?.pushViewController(detailViewController, animated: true)
    }
    
    func showShareScreen(with content: String) {
        let activityViewController = UIActivityViewController(activityItems: [content], applicationActivities: nil)
        
        if let popoverController = viewController?.popoverPresentationController {
            popoverController.sourceView = viewController?.view
            popoverController.sourceRect = CGRect(
                x: 150,
                y: 150,
                width: 0,
                height: 0
            )
            popoverController.permittedArrowDirections = []
        }
        viewController?.present(activityViewController, animated: true, completion: nil)
    }
}
