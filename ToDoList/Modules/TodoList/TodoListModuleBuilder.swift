//
//  TodoListModuleBuilder.swift
//  ToDoList
//
//  Created by Niykee Moore on 30.03.2025.
//

import UIKit
import CoreData // <-- Добавить

enum TodoListModuleBuilder {
    static func createModule(coreDataManager: CoreDataManaging) -> UIViewController {
        let networkClient: NetworkRouting = NetworkClient()
        let todosLoader: TodosLoading = TodosLoader(networkClient: networkClient)
        let todoStore: TodoStoring = CoreDataStore(manager: coreDataManager)
        
        // Создаем DataProvider
        let dataProvider: TodoListDataProviderProtocol = FetchedResultsDataProvider(
            context: coreDataManager.viewContext
        )
        
        var interactor: TodoInteractorInput = TodoListInteractor(
            todosLoader: todosLoader,
            todoStore: todoStore,
            coreDataManager: coreDataManager
        )
        
        let router: TodoListRouter = TodoListRouterImpl()
        
        let presenter: TodoListPresenter & TodoInteractorOutput = TodoListPresenter(
            interactor: interactor,
            router: router,
            dataProvider: dataProvider,
            coreDataManager: coreDataManager
        )
        
        let view = TodoListViewController(
            presenter: presenter,
            dataProvider: dataProvider
        )
        
        presenter.viewController = view
        interactor.presenter = presenter
        router.viewController = view
        
        return view
    }
}
