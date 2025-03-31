//
//  MockTodosLoader.swift
//  ToDoList
//
//  Created by Niykee Moore on 31.03.2025.
//

@testable import ToDoList
import Foundation

final class MockTodosLoader: TodosLoading {
    var loadShouldReturn: Result<[Todo], Error>?
    var loadCalled = false

    func load(handler: @escaping (Result<[Todo], Error>) -> Void) {
        loadCalled = true
        if let result = loadShouldReturn {
            DispatchQueue.global().async {
                handler(result)
            }
        } else {
             fatalError("loadShouldReturn не установлен в MockTodosLoader")
        }
    }
}
