//
//  MockTodoDetailRouter.swift
//  ToDoList
//
//  Created by Niykee Moore on 31.03.2025.
//

@testable import ToDoList
import UIKit

final class MockTodoDetailRouter: TodoDetailRouterInput {
    var view: UIViewController? // Не используется напрямую в тестах презентера

    var navigateBackCalled = false

    func navigateBack() {
        navigateBackCalled = true
    }
}
