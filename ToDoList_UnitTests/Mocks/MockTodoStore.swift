//
//  MockTodoStore.swift
//  ToDoList
//
//  Created by Niykee Moore on 31.03.2025.
//

@testable import ToDoList
import XCTest

final class MockTodoStore: TodoStoring {
    var fetchShouldReturn: Result<[Todo], Error> = .success([])
    var saveShouldReturn: Result<Void, Error> = .success(())
    var deleteShouldReturn: Result<Void, Error> = .success(())
    var batchInsertShouldReturn: Result<Void, Error> = .success(())
    
    var batchInsertTodosCalledWithTodos: [Todo]?
    var batchInsertCalled = false
    
    var fetchTodosCalled = false
    var saveTodoCalledWithTodo: Todo?
    var deleteTodoCalledWithId: String?
    var saveTodoCallCount = 0
    
    var saveExpectation: XCTestExpectation?
    var deleteExpectation: XCTestExpectation?
    var fetchExpectation: XCTestExpectation?
    var batchInsertExpectation: XCTestExpectation?
    
    func fetchTodos(completion: @escaping (Result<[Todo], Error>) -> Void) {
        fetchTodosCalled = true
        
        DispatchQueue.global().async {
            completion(self.fetchShouldReturn)
            self.fetchExpectation?.fulfill()
        }
    }
    
    func saveTodo(_ todo: Todo, completion: @escaping (Result<Void, Error>) -> Void) {
        saveTodoCalledWithTodo = todo
        saveTodoCallCount += 1
        
        DispatchQueue.global().async {
            completion(self.saveShouldReturn)
            self.saveExpectation?.fulfill()
        }
    }
    
    func deleteTodo(id: String, completion: @escaping (Result<Void, Error>) -> Void) {
        deleteTodoCalledWithId = id
        
        DispatchQueue.global().async {
            completion(self.deleteShouldReturn)
            self.deleteExpectation?.fulfill()
        }
    }
    
    func batchInsertTodos(from todos: [ToDoList.Todo], completion: @escaping (Result<Void, any Error>) -> Void) {
        batchInsertCalled = true
        batchInsertTodosCalledWithTodos = todos
        
        DispatchQueue.global().async {
            completion(self.batchInsertShouldReturn)
            self.batchInsertExpectation?.fulfill()
        }
    }
    
}

// MARK: - Test Error Enum
enum TestError: Error, LocalizedError {
    case generic
    case networkError
    case databaseError
    
    var errorDescription: String? {
        switch self {
        case .generic: return "Generic Test Error"
        case .networkError: return "Network Test Error"
        case .databaseError: return "Database Test Error"
        }
    }
}
