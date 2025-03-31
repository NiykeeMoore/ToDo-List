//
//  TodoDetailModuleBuilder.swift
//  ToDoList
//
//  Created by Niykee Moore on 30.03.2025.
//

import UIKit

enum TodoDetailModuleBuilder {
    static func createModule(with todo: Todo?, coreDataManager: CoreDataManaging) -> UIViewController {
        let todoStore: TodoStoring = CoreDataStore(manager: coreDataManager)
        
        let interactor: TodoDetailInteractorInput = TodoDetailInteractor(todoStore: todoStore)
        let presenter: TodoDetailPresenterInput & TodoDetailInteractorOutput = TodoDetailPresenter(interactor: interactor, todo: todo)
        let router: TodoDetailRouterInput = TodoDetailRouter()
        let viewController = TodoDetailViewController()
        
        viewController.presenter = presenter
        presenter.viewController = viewController
        presenter.router = router
        presenter.interactor = interactor
        interactor.presenter = presenter
        router.view = viewController
        
        return viewController
    }
}
