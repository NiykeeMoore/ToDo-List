//
//  MockTodoListRouter.swift
//  ToDoList
//
//  Created by Niykee Moore on 31.03.2025.
//

@testable import ToDoList
import UIKit

final class MockTodoListRouter: TodoListRouter {
    var viewController: UIViewController? // Не используется в тестах презентера напрямую

    var navigateToTodoDetailCalledWithTodo: Todo?
    var navigateToTodoDetailCalled = false // для случая с nil
    var coreDataManagerPassed: CoreDataManaging?
    var showShareScreenCalled = false

    func navigateToTodoDetail(with todo: Todo?, coreDataManager: CoreDataManaging) {
        navigateToTodoDetailCalled = true
        navigateToTodoDetailCalledWithTodo = todo
        coreDataManagerPassed = coreDataManager
    }

    func showShareScreen(with content: String, sourceView: UIView?, sourceRect: CGRect?) {
         showShareScreenCalled = true
         
    }
}
