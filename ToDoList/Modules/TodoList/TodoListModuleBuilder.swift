//
//  TodoListModuleBuilder.swift
//  ToDoList
//
//  Created by Niykee Moore on 30.03.2025.
//

import UIKit

enum TodoListModuleBuilder {
    static func createModule(coreDataManager: CoreDataManaging) -> UIViewController {
        let networkClient: NetworkRouting = NetworkClient()
        let todosLoader: TodosLoading = TodosLoader(networkClient: networkClient)

        var interactor: TodoInteractorInput = TodoListInteractor(todosLoader: todosLoader)
        let presenter: TodoListPresenter & TodoInteractorOutput = TodoListPresenter(interactor: interactor)
        let view = TodoListViewController(presenter: presenter)
        let router: TodoListRouter = TodoListRouterImpl()

        presenter.viewController = view
        presenter.router = router
        interactor.presenter = presenter
        router.viewController = view

        return view
    }
}
