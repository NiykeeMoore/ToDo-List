//
//  CoreDataStoreTests.swift
//  ToDoListTests
//
//  Created by Niykee Moore on 31.03.2025.
//

import XCTest
import CoreData
@testable import ToDoList

final class CoreDataStoreTests: XCTestCase {
    
    var sut: CoreDataStore!
    var mockCoreDataManager: MockCoreDataManager!
    var context: NSManagedObjectContext!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        mockCoreDataManager = MockCoreDataManager()
        context = mockCoreDataManager.viewContext
        sut = CoreDataStore(manager: mockCoreDataManager)
    }
    
    override func tearDownWithError() throws {
        sut = nil
        context = nil
        mockCoreDataManager = nil
        try super.tearDownWithError()
    }
    
    // MARK: - Helper
    @discardableResult
    private func createAndSaveTodoEntity(id: String, title: String, date: Date, isCompleted: Bool, description: String = "") -> TodoEntity {
        let entity = TodoEntity(context: context)
        entity.id = id
        entity.title = title
        entity.dateOfCreation = date
        entity.isCompleted = isCompleted
        entity.todoDescription = description
        try! context.save()
        return entity
    }
    
    // MARK: - Helper
    private func fetchTodoEntity(withId id: String) -> TodoEntity? {
        let fetchRequest = NSFetchRequest<TodoEntity>(entityName: "TodoEntity")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        fetchRequest.fetchLimit = 1
        let results = try? context.fetch(fetchRequest)
        return results?.first
    }
    
    // MARK: - fetchTodos Tests
    
    func test_fetchTodos_whenStoreIsEmpty_returnsSuccessWithEmptyArray() {
        // Given
        let expectation = XCTestExpectation(description: "fetchTodos completion called")
        var capturedResult: Result<[Todo], Error>?
        
        // When
        sut.fetchTodos { result in
            capturedResult = result
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        guard case .success(let todos) = capturedResult else {
            XCTFail("Expected success, got failure or nil")
            return
        }
        XCTAssertTrue(todos.isEmpty, "Массив должен быть пустым")
    }
    
    func test_fetchTodos_whenStoreHasData_returnsSuccessWithMappedAndSortedTodos() {
        // Given
        let date1 = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let date2 = Date() // Newer date
        createAndSaveTodoEntity(id: "1", title: "Older Task", date: date1, isCompleted: false)
        createAndSaveTodoEntity(id: "2", title: "Newer Task", date: date2, isCompleted: true)
        
        let expectation = XCTestExpectation(description: "fetchTodos completion called")
        var capturedResult: Result<[Todo], Error>?
        
        // When
        sut.fetchTodos { result in
            capturedResult = result
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        guard case .success(let todos) = capturedResult else {
            XCTFail("Expected success, got failure or nil")
            return
        }
        XCTAssertEqual(todos.count, 2, "Должно быть 2 задачи")
        
        XCTAssertEqual(todos[0].id, "2", "Первой должна быть более новая задача")
        XCTAssertEqual(todos[0].title, "Newer Task")
        XCTAssertEqual(todos[0].isCompleted, true)
        XCTAssertEqual(todos[0].dateOfCreation, date2)
        
        XCTAssertEqual(todos[1].id, "1", "Второй должна быть более старая задача")
        XCTAssertEqual(todos[1].title, "Older Task")
        XCTAssertEqual(todos[1].isCompleted, false)
        XCTAssertEqual(todos[1].dateOfCreation, date1)
    }
    
    // MARK: - saveTodo (Create) Tests
    
    func test_saveTodo_whenCreatingNew_insertsAndSavesEntity_callsCompletionWithSuccess() {
        // Given
        let newTodo = Todo(id: "new1", title: "New Task", description: "Desc", dateOfCreation: Date(), isCompleted: false)
        let expectation = XCTestExpectation(description: "saveTodo completion called")
        var capturedResult: Result<Void, Error>?
        
        // When
        sut.saveTodo(newTodo) { result in
            capturedResult = result
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 2.0)
        guard case .success = capturedResult else {
            XCTFail("Expected success, got failure or nil. Error: \(String(describing: capturedResult))")
            return
        }
        
        context.performAndWait {
            let fetchedEntity = fetchTodoEntity(withId: "new1")
            XCTAssertNotNil(fetchedEntity, "Entity должен быть создан в контексте")
            XCTAssertEqual(fetchedEntity?.title, "New Task")
            XCTAssertEqual(fetchedEntity?.todoDescription, "Desc")
            XCTAssertEqual(fetchedEntity?.isCompleted, false)
            XCTAssertEqual(fetchedEntity?.dateOfCreation, newTodo.dateOfCreation)
        }
    }
    
    // MARK: - saveTodo (Update) Tests
    
    func test_saveTodo_whenUpdatingExisting_updatesAndSavesEntity_callsCompletionWithSuccess() {
        // Given
        let initialDate = Calendar.current.date(byAdding: .day, value: -2, to: Date())!
        createAndSaveTodoEntity(id: "update1", title: "Initial Title", date: initialDate, isCompleted: false, description: "Old Desc")
        
        let updatedTodo = Todo(id: "update1", title: "Updated Title", description: "New Desc", dateOfCreation: initialDate, isCompleted: true)
        let expectation = XCTestExpectation(description: "saveTodo completion called")
        var capturedResult: Result<Void, Error>?
        
        // When
        sut.saveTodo(updatedTodo) { result in
            capturedResult = result
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 2.0)
        guard case .success = capturedResult else {
            XCTFail("Expected success, got failure or nil. Error: \(String(describing: capturedResult))")
            return
        }
        
        context.performAndWait {
            let fetchedEntity = fetchTodoEntity(withId: "update1")
            XCTAssertNotNil(fetchedEntity, "Entity должен существовать")
            XCTAssertEqual(fetchedEntity?.title, "Updated Title", "Title должен обновиться")
            XCTAssertEqual(fetchedEntity?.todoDescription, "New Desc", "Description должен обновиться")
            XCTAssertEqual(fetchedEntity?.isCompleted, true, "isCompleted должен обновиться")
            XCTAssertEqual(fetchedEntity?.dateOfCreation, initialDate)
            
            let fetchRequest = NSFetchRequest<TodoEntity>(entityName: "TodoEntity")
            fetchRequest.predicate = NSPredicate(format: "id == %@", "update1")
            let count = try? context.count(for: fetchRequest)
            XCTAssertEqual(count, 1, "Должна быть только одна запись с этим ID")
        }
    }
    
    // MARK: - deleteTodo Tests
    
    func test_deleteTodo_whenEntityExists_deletesEntity_callsCompletionWithSuccess() {
        // Given
        createAndSaveTodoEntity(id: "delete1", title: "To Delete", date: Date(), isCompleted: false)
        XCTAssertNotNil(fetchTodoEntity(withId: "delete1"), "Entity должна существовать перед удалением")
        
        let expectation = XCTestExpectation(description: "deleteTodo completion called")
        var capturedResult: Result<Void, Error>?
        
        // When
        sut.deleteTodo(id: "delete1") { result in
            capturedResult = result
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 2.0)
        guard case .success = capturedResult else {
            XCTFail("Expected success, got failure or nil. Error: \(String(describing: capturedResult))")
            return
        }
        
        context.performAndWait {
            let fetchedEntity = fetchTodoEntity(withId: "delete1")
            XCTAssertNil(fetchedEntity, "Entity должна быть удалена из контекста")
        }
    }
    
    func test_deleteTodo_whenEntityDoesNotExist_callsCompletionWithSuccess() {
        // Given
        let expectation = XCTestExpectation(description: "deleteTodo completion called")
        var capturedResult: Result<Void, Error>?
        
        // When
        sut.deleteTodo(id: "nonExistent") { result in
            capturedResult = result
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        guard case .success = capturedResult else {
            XCTFail("Expected success even if entity doesn't exist, got failure or nil. Error: \(String(describing: capturedResult))")
            return
        }
    }
    
    // MARK: - Helpers
    func createTestTodo(id: String = UUID().uuidString, title: String = "Test", description: String = "Desc", isCompleted: Bool = false) -> Todo {
        return Todo(
            id: id,
            title: title,
            description: description,
            dateOfCreation: Date(),
            isCompleted: isCompleted
        )
    }
}
