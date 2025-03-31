//
//  TodosLoaderTests.swift
//  ToDoListTests
//
//  Created by Niykee Moore on 31.03.2025.
//

import XCTest
@testable import ToDoList

final class TodosLoaderTests: XCTestCase {
    
    var sut: TodosLoader!
    var mockNetworkClient: MockNetworkClient!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        mockNetworkClient = MockNetworkClient()
        sut = TodosLoader(networkClient: mockNetworkClient)
    }
    
    override func tearDownWithError() throws {
        sut = nil
        mockNetworkClient = nil
        try super.tearDownWithError()
    }
    
    // MARK: - Helper for Valid JSON Data
    private func createValidTodosJSONData() -> Data {
        let jsonString = """
        {
          "todos": [
            {
              "id": 1,
              "todo": "Do something nice for someone I care about",
              "completed": true,
              "userId": 26
            },
            {
              "id": 2,
              "todo": "Memorize the fifty states and their capitals",
              "completed": false,
              "userId": 48
            }
          ],
          "total": 150,
          "skip": 0,
          "limit": 2
        }
        """
        return jsonString.data(using: .utf8)!
    }
    
    // MARK: - Tests
    
    func test_load_whenNetworkSuccessAndValidData_callsHandlerWithSuccessAndMappedTodos() {
        // Given
        let validData = createValidTodosJSONData()
        mockNetworkClient.fetchHandlerResult = .success(validData)
        let expectation = XCTestExpectation(description: "Load completion handler called")
        var capturedResult: Result<[Todo], Error>?
        
        // When
        sut.load { result in
            capturedResult = result
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        
        // Проверяем результат
        guard case .success(let todos) = capturedResult else {
            XCTFail("Ожидался успех, но получена ошибка или nil")
            return
        }
        
        XCTAssertEqual(todos.count, 2, "Должно быть загружено 2 задачи")
        XCTAssertEqual(todos[0].id, "1")
        XCTAssertEqual(todos[0].title, "Do something nice for someone I care about")
        XCTAssertEqual(todos[0].isCompleted, true)
        
        XCTAssertFalse(todos[0].description.isEmpty)
        XCTAssertFalse(todos[0].description.contains("Ошибка в определении описания"))
        
        XCTAssertEqual(todos[1].id, "2")
        XCTAssertEqual(todos[1].title, "Memorize the fifty states and their capitals")
        XCTAssertEqual(todos[1].isCompleted, false)
        XCTAssertFalse(todos[1].description.isEmpty)
        XCTAssertFalse(todos[1].description.contains("Ошибка в определении описания"))
        
        XCTAssertNotNil(todos[0].dateOfCreation)
        XCTAssertNotNil(todos[1].dateOfCreation)
    }
    
    func test_load_whenNetworkSuccessButInvalidData_callsHandlerWithFailureDecodingError() {
        // Given
        let invalidData = "{\"invalid\": \"json\"}".data(using: .utf8)! // Не соответствует TodosResponse
        mockNetworkClient.fetchHandlerResult = .success(invalidData)
        let expectation = XCTestExpectation(description: "Load completion handler called")
        var capturedResult: Result<[Todo], Error>?
        
        // When
        sut.load { result in
            capturedResult = result
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        
        // Проверяем результат
        guard case .failure(let error) = capturedResult else {
            XCTFail("Ожидалась ошибка, но получен успех или nil")
            return
        }
        
        XCTAssertTrue(error is DecodingError, "Тип ошибки должен быть DecodingError")
    }
    
    func test_load_whenNetworkFails_callsHandlerWithFailureNetworkError() {
        // Given
        let networkError = TestError.networkError
        mockNetworkClient.fetchHandlerResult = .failure(networkError)
        let expectation = XCTestExpectation(description: "Load completion handler called")
        var capturedResult: Result<[Todo], Error>?
        
        // When
        sut.load { result in
            capturedResult = result
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        guard case .failure(let error) = capturedResult else {
            XCTFail("Ожидалась ошибка, но получен успех или nil")
            return
        }
        
        XCTAssertEqual(error.localizedDescription, networkError.localizedDescription, "Должна вернуться исходная сетевая ошибка")
    }
}
