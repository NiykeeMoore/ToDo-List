//
//  MockTodoDetailPresenter.swift
//  ToDoListTests
//
//  Created by Niykee Moore on 31.03.2025.
//

import XCTest
@testable import ToDoList

final class MockTodoDetailPresenter: TodoDetailInteractorOutput {

    var didSaveTodoSuccessfullyCalled = false
    var didFailToSaveTodoCalledWithError: Error?

    var didSaveSuccessExpectation: XCTestExpectation?
    var didFailSaveExpectation: XCTestExpectation?

    func didSaveTodoSuccessfully() {
        didSaveTodoSuccessfullyCalled = true
        didSaveSuccessExpectation?.fulfill()
    }

    func didFailToSaveTodo(error: Error) {
        didFailToSaveTodoCalledWithError = error
        didFailSaveExpectation?.fulfill()
    }
}
