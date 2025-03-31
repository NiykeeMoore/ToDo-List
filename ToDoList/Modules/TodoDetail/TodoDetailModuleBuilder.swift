//
//  TodoDetailModuleBuilder.swift
//  ToDoList
//
//  Created by Niykee Moore on 30.03.2025.
//

import UIKit

enum TodoDetailModuleBuilder {
    static func createModule(with todo: Todo?) -> UIViewController {
        let viewController = TodoDetailViewController()
        
        let interactor: TodoDetailInteractorInput = TodoDetailInteractor(todo: todo)
        let presenter: TodoDetailPresenterInput & TodoDetailInteractorOutput = TodoDetailPresenter(interactor: interactor, todo: todo)
        let router: TodoDetailRouterInput = TodoDetailRouter()
        
        viewController.presenter = presenter
        presenter.viewController = viewController
        presenter.router = router
        presenter.interactor = interactor
        interactor.presenter = presenter
        router.view = viewController
        
        return viewController
    }
}
