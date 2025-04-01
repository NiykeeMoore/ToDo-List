//
//  MockTodosLoader.swift
//  ToDoList
//
//  Created by Niykee Moore on 31.03.2025.
//

@testable import ToDoList
import Foundation
import XCTest

final class MockTodosLoader: TodosLoading {
    var loadShouldReturn: Result<[Todo], Error>?
    var loadShouldReturnDTO: Result<[TodoItemDTO], Error> = .success([])
    
    var loadCalled = false
    var loadExpectation: XCTestExpectation?
    
    func load(handler: @escaping (Result<[TodoItemDTO], any Error>) -> Void) {
        loadCalled = true
        DispatchQueue.global().async {
            handler(self.loadShouldReturnDTO)
            self.loadExpectation?.fulfill()
        }
    }
}
