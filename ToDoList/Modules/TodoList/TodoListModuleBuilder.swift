//
//  TodoListModuleBuilder.swift
//  ToDoList
//
//  Created by Niykee Moore on 30.03.2025.
//

import UIKit

enum TodoListModuleBuilder {
    static func createModule() -> UIViewController {
        let networkClient = NetworkClient()
        let todosLoader = TodosLoader(networkClient: networkClient)
        
        let interactor = TodoListInteractor(todosLoader: todosLoader)
        let presesenter = TodoListPresenter(interactor: interactor)
        let view = TodoListViewController(presenter: presesenter)
        let router = TodoListRouterImpl()
        
        presesenter.viewController = view
        presesenter.router = router
        interactor.presenter = presesenter
        router.viewController = view
        return view
    }
}
