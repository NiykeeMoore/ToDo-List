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

    func load(handler: @escaping (Result<[TodoItemDTO], any Error>) -> Void) {
        loadCalled = true
        if let _ = loadShouldReturn {
            DispatchQueue.global().async {
                handler(.success([]))
            }
        } else {
             fatalError("loadShouldReturn не установлен в MockTodosLoader")
        }
    }
}
