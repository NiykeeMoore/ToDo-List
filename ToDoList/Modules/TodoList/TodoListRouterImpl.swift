//
//  TodoRouter.swift
//  ToDoList
//
//  Created by Niykee Moore on 29.03.2025.
//

import UIKit

protocol TodoListRouter: AnyObject {
    var viewController: UIViewController? { get set }
    func navigateToTodoDetail(with todo: Todo?)
    func showShareScreen(with content: String, sourceView: UIView?, sourceRect: CGRect?)
}

final class TodoListRouterImpl: TodoListRouter {
    weak var viewController: UIViewController?
    
    func navigateToTodoDetail(with todo: Todo?) {
        let detailViewController = TodoDetailModuleBuilder.createModule(with: todo)
        viewController?.navigationController?.pushViewController(detailViewController, animated: true)
    }
    
    func showShareScreen(with content: String, sourceView: UIView?, sourceRect: CGRect?) {
        let activityViewController = UIActivityViewController(activityItems: [content], applicationActivities: nil)
        
        if let popoverController = activityViewController.popoverPresentationController {
            if let sourceView = sourceView, let sourceRect = sourceRect {
                popoverController.sourceView = sourceView
                popoverController.sourceRect = sourceRect
                popoverController.permittedArrowDirections = .any
            } else {
                popoverController.sourceView = viewController?.view
                popoverController.sourceRect = CGRect(x: viewController?.view.bounds.midX ?? 0,
                                                      y: viewController?.view.bounds.midY ?? 0,
                                                      width: 0, height: 0)
                popoverController.permittedArrowDirections = []
            }
        }
        viewController?.present(activityViewController, animated: true, completion: nil)
    }
}
