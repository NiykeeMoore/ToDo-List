//
//  TodoDetailModuleBuilder.swift
//  ToDoList
//
//  Created by Niykee Moore on 30.03.2025.
//

import UIKit

enum TodoDetailModuleBuilder {
    static func createModule(with todo: Todo?) -> UIViewController {
        let interactor = TodoDetailInteractor(todo: todo)
        let presenter = TodoDetailPresenter(interactor: interactor, todo: todo)
        let viewController = TodoDetailViewController()
        let router = TodoDetailRouter()
        viewController.presenter = presenter
        
        presenter.viewController = viewController
        presenter.router = router
        interactor.presenter = presenter
        router.view = viewController
        
        return viewController
    }
}
