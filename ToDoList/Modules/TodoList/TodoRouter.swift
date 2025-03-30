//
//  TodoRouter.swift
//  ToDoList
//
//  Created by Niykee Moore on 29.03.2025.
//

import UIKit

final class TodoRouter {
    static func createModule() -> UIViewController {
        let interactor = TodoInteractor(
            todosLoader: TodosLoader(networkClient: NetworkClient())
        )
        let presenter = TodoPresenter(interactor: interactor)
        let viewController = TodoListViewController(presenter: presenter)
        
        presenter.viewController = viewController
        interactor.presenter = presenter
        
        return viewController
    }
}
