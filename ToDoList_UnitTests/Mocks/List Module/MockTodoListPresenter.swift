//
//  MockTodoListPresenter.swift
//  ToDoList
//
//  Created by Niykee Moore on 31.03.2025.
//

@testable import ToDoList
import XCTest

final class MockTodoListPresenter: TodoInteractorOutput {
    var didFetchTodosCalledWithTodos: [Todo]?
    var didFailToFetchTodosCalledWithError: Error?
    var didUpdateTodoCalledAtIndexAndTodo: (index: Int, todo: Todo)?
    var didDeleteTodoCalledAtIndex: Int?

    var didFetchExpectation: XCTestExpectation?
    var didFailExpectation: XCTestExpectation?
    var didUpdateExpectation: XCTestExpectation?
    var didDeleteExpectation: XCTestExpectation?

    func didFetchTodos(todos: [Todo]) {
        didFetchTodosCalledWithTodos = todos
        didFetchExpectation?.fulfill()
    }

    func didFailToFetchTodos(error: Error) {
        didFailToFetchTodosCalledWithError = error
        didFailExpectation?.fulfill()
    }

    func didUpdateTodo(at index: Int, with todo: Todo) {
        didUpdateTodoCalledAtIndexAndTodo = (index, todo)
        didUpdateExpectation?.fulfill()
    }

    func didDeleteTodo(at index: Int) {
        didDeleteTodoCalledAtIndex = index
        didDeleteExpectation?.fulfill()
    }
}
