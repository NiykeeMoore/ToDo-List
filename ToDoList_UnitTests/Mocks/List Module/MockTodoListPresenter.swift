//
//  MockTodoListPresenter.swift
//  ToDoList
//
//  Created by Niykee Moore on 31.03.2025.
//

@testable import ToDoList
import XCTest

final class MockTodoListPresenter: TodoInteractorOutput {
    var didFailToFetchTodosCalledWithError: Error?
    var frcFetchFailedCalledWithError: Error?
    
    var didFailExpectation: XCTestExpectation?
    var frcFailExpectation: XCTestExpectation?
    
    func didFailToFetchTodos(error: Error) {
        didFailToFetchTodosCalledWithError = error
        didFailExpectation?.fulfill()
    }
    
    func frcFetchFailed(error: Error) {
        frcFetchFailedCalledWithError = error
        frcFailExpectation?.fulfill()
    }
}
