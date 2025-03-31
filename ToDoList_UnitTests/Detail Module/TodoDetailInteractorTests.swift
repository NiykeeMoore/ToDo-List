//
//  TodoDetailInteractorTests.swift
//  ToDoListTests
//
//  Created by Niykee Moore on 31.03.2025.
//

import XCTest
@testable import ToDoList

final class TodoDetailInteractorTests: XCTestCase {
    
    var sut: TodoDetailInteractor!
    var mockPresenter: MockTodoDetailPresenter!
    var mockStore: MockTodoStore!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        mockPresenter = MockTodoDetailPresenter()
        mockStore = MockTodoStore()
        
        sut = TodoDetailInteractor(todoStore: mockStore)
        sut.presenter = mockPresenter
    }
    
    override func tearDownWithError() throws {
        sut = nil
        mockPresenter = nil
        mockStore = nil
        try super.tearDownWithError()
    }
    
    // MARK: - Tests for saveTodo
    
    func test_saveTodo_callsStoreSaveWithCorrectTodo() {
        // Given
        let todoToSave = createTestTodo(id: "save1", title: "Task to Save")
        let saveStoreExp = XCTestExpectation(description: "mockStore.saveTodo called")
        
        mockStore.saveExpectation = saveStoreExp
        mockStore.saveShouldReturn = .success(())
        
        // When
        sut.saveTodo(todo: todoToSave)
        
        // Then
        wait(for: [saveStoreExp], timeout: 1.0)
        XCTAssertNotNil(mockStore.saveTodoCalledWithTodo, "Метод saveTodo у хранилища должен быть вызван")
        XCTAssertEqual(mockStore.saveTodoCalledWithTodo?.id, todoToSave.id, "ID сохраняемого todo должен совпадать")
        XCTAssertEqual(mockStore.saveTodoCalledWithTodo?.title, todoToSave.title, "Title сохраняемого todo должен совпадать")
    }
    
    func test_saveTodo_whenStoreSaveSucceeds_callsPresenterDidSaveSuccessfully() {
        // Given
        let todoToSave = createTestTodo(id: "saveSuccess")
        mockStore.saveShouldReturn = .success(())
        
        let savePresenterExp = XCTestExpectation(description: "presenter.didSaveTodoSuccessfully called")
        mockPresenter.didSaveSuccessExpectation = savePresenterExp
        
        // When
        sut.saveTodo(todo: todoToSave)
        
        // Then
        wait(for: [savePresenterExp], timeout: 1.0)
        XCTAssertTrue(mockPresenter.didSaveTodoSuccessfullyCalled, "Презентер должен быть уведомлен об успехе")
        XCTAssertNil(mockPresenter.didFailToSaveTodoCalledWithError, "Ошибка не должна приходить при успехе")
    }
    
    func test_saveTodo_whenStoreSaveFails_callsPresenterDidFailToSave() {
        // Given
        let todoToSave = createTestTodo(id: "saveFail")
        let saveError = TestError.databaseError
        mockStore.saveShouldReturn = .failure(saveError)
        
        let failPresenterExp = XCTestExpectation(description: "presenter.didFailToSaveTodo called")
        mockPresenter.didFailSaveExpectation = failPresenterExp
        
        // When
        sut.saveTodo(todo: todoToSave)
        
        // Then
        wait(for: [failPresenterExp], timeout: 1.0)
        XCTAssertFalse(mockPresenter.didSaveTodoSuccessfullyCalled, "Успех не должен приходить при ошибке")
        XCTAssertNotNil(mockPresenter.didFailToSaveTodoCalledWithError, "Презентер должен быть уведомлен об ошибке")
        XCTAssertEqual(mockPresenter.didFailToSaveTodoCalledWithError?.localizedDescription, saveError.localizedDescription, "Тип ошибки должен совпадать")
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
