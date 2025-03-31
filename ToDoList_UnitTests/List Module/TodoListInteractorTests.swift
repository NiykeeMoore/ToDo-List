//
//  TodoListInteractorTests.swift
//  ToDoListTests
//
//  Created by Niykee Moore on 31.03.2025.
//

import XCTest
@testable import ToDoList

final class TodoListInteractorTests: XCTestCase {
    
    var sut: TodoListInteractor!
    var mockPresenter: MockTodoListPresenter!
    var mockLoader: MockTodosLoader!
    var mockStore: MockTodoStore!
    let initialDataKey = "didLoadInitialDataKey"
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        mockPresenter = MockTodoListPresenter()
        mockLoader = MockTodosLoader()
        mockStore = MockTodoStore()
        
        sut = TodoListInteractor(todosLoader: mockLoader, todoStore: mockStore)
        sut.presenter = mockPresenter
        
        UserDefaults.standard.removeObject(forKey: initialDataKey)
    }
    
    override func tearDownWithError() throws {
        sut = nil
        mockPresenter = nil
        mockLoader = nil
        mockStore = nil
        UserDefaults.standard.removeObject(forKey: initialDataKey)
        try super.tearDownWithError()
    }
    
    // MARK: - fetchTodos Tests
    
    func test_fetchTodos_whenStoreIsNotEmpty_callsPresenterDidFetchWithStoredTodos() {
        // Given
        let storedTodos = [createTestTodo(id: "stored1")]
        mockStore.fetchShouldReturn = .success(storedTodos)
        UserDefaults.standard.set(true, forKey: initialDataKey)
        
        // Expectation
        let expectation = XCTestExpectation(description: "presenter.didFetchTodos called")
        mockPresenter.didFetchExpectation = expectation
        
        // When
        sut.fetchTodos()
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertFalse(mockLoader.loadCalled, "Загрузчик из сети не должен вызываться")
        XCTAssertNotNil(mockPresenter.didFetchTodosCalledWithTodos)
        XCTAssertEqual(mockPresenter.didFetchTodosCalledWithTodos?.count, 1)
        XCTAssertEqual(mockPresenter.didFetchTodosCalledWithTodos?.first?.id, "stored1")
    }
    
    func test_fetchTodos_whenStoreIsEmptyButNotFirstLoad_callsPresenterDidFetchWithEmptyArray() {
        // Given
        mockStore.fetchShouldReturn = .success([])
        UserDefaults.standard.set(true, forKey: initialDataKey)
        
        // Expectation
        let expectation = XCTestExpectation(description: "presenter.didFetchTodos called")
        mockPresenter.didFetchExpectation = expectation
        
        // When
        sut.fetchTodos()
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertFalse(mockLoader.loadCalled, "Загрузчик из сети не должен вызываться")
        XCTAssertNotNil(mockPresenter.didFetchTodosCalledWithTodos, "Презентер должен быть вызван")
        XCTAssertTrue(mockPresenter.didFetchTodosCalledWithTodos?.isEmpty ?? false, "Массив todos должен быть пустым")
    }
    
    func test_fetchTodos_whenStoreFetchFails_callsPresenterDidFail() {
        // Given
        let dbError = TestError.databaseError
        mockStore.fetchShouldReturn = .failure(dbError)
        
        // Expectation
        let expectation = XCTestExpectation(description: "presenter.didFailToFetchTodos called")
        mockPresenter.didFailExpectation = expectation
        
        // When
        sut.fetchTodos()
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertFalse(mockLoader.loadCalled)
        XCTAssertNotNil(mockPresenter.didFailToFetchTodosCalledWithError)
        XCTAssertEqual(mockPresenter.didFailToFetchTodosCalledWithError?.localizedDescription, dbError.localizedDescription)
    }
    
    // MARK: - toggleTodoComplition Tests
    
    func test_toggleTodoComplition_callsStoreSaveWithUpdatedTodo_callsPresenterDidUpdate() {
        // Given
        let todo = createTestTodo(id: "toggle1", isCompleted: false)
        mockStore.fetchShouldReturn = .success([todo])
        let fetchExp = XCTestExpectation(description: "Initial fetch completed")
        mockPresenter.didFetchExpectation = fetchExp
        sut.fetchTodos()
        wait(for: [fetchExp], timeout: 1.0)
        
        mockStore.saveShouldReturn = .success(())
        
        // Expectations
        let saveExp = XCTestExpectation(description: "store.saveTodo called")
        let updateExp = XCTestExpectation(description: "presenter.didUpdateTodo called")
        mockStore.saveExpectation = saveExp
        mockPresenter.didUpdateExpectation = updateExp
        
        // When
        sut.toggleTodoComplition(at: 0)
        
        // Then
        wait(for: [saveExp, updateExp], timeout: 1.0)
        XCTAssertNotNil(mockStore.saveTodoCalledWithTodo, "Метод сохранения должен быть вызван")
        XCTAssertEqual(mockStore.saveTodoCalledWithTodo?.id, "toggle1")
        XCTAssertEqual(mockStore.saveTodoCalledWithTodo?.isCompleted, true, "Статус isCompleted должен измениться на true")
        XCTAssertNotNil(mockPresenter.didUpdateTodoCalledAtIndexAndTodo, "Презентер должен получить обновление")
        XCTAssertEqual(mockPresenter.didUpdateTodoCalledAtIndexAndTodo?.index, 0)
        XCTAssertEqual(mockPresenter.didUpdateTodoCalledAtIndexAndTodo?.todo.isCompleted, true)
    }
    
    func test_toggleTodoComplition_whenSaveFails_callsPresenterDidFail() {
        // Given
        let todo = createTestTodo(id: "toggleFail", isCompleted: false)
        mockStore.fetchShouldReturn = .success([todo])
        let fetchExp = XCTestExpectation(description: "Initial fetch completed")
        mockPresenter.didFetchExpectation = fetchExp
        sut.fetchTodos()
        wait(for: [fetchExp], timeout: 1.0)
        
        let saveError = TestError.databaseError
        mockStore.saveShouldReturn = .failure(saveError)
        
        // Expectations
        let saveExp = XCTestExpectation(description: "store.saveTodo called")
        let failExp = XCTestExpectation(description: "presenter.didFailToFetchTodos called")
        mockStore.saveExpectation = saveExp
        mockPresenter.didFailExpectation = failExp
        
        // When
        sut.toggleTodoComplition(at: 0)
        
        // Then
        wait(for: [saveExp, failExp], timeout: 1.0)
        XCTAssertNotNil(mockStore.saveTodoCalledWithTodo)
        XCTAssertNil(mockPresenter.didUpdateTodoCalledAtIndexAndTodo, "Обновление не должно дойти до презентера при ошибке сохранения")
        XCTAssertNotNil(mockPresenter.didFailToFetchTodosCalledWithError)
        XCTAssertEqual(mockPresenter.didFailToFetchTodosCalledWithError?.localizedDescription, saveError.localizedDescription)
    }
    
    // MARK: - deleteTodo Tests
    
    func test_deleteTodo_callsStoreDeleteWithCorrectId_callsPresenterDidDelete() {
        // Given
        let todo1 = createTestTodo(id: "delete1")
        let todo2 = createTestTodo(id: "delete2")
        mockStore.fetchShouldReturn = .success([todo1, todo2])
        let fetchExp = XCTestExpectation(description: "Initial fetch completed")
        mockPresenter.didFetchExpectation = fetchExp
        sut.fetchTodos()
        wait(for: [fetchExp], timeout: 1.0)
        
        mockStore.deleteShouldReturn = .success(())
        
        // Expectations
        let deleteStoreExp = XCTestExpectation(description: "store.deleteTodo called")
        let deletePresenterExp = XCTestExpectation(description: "presenter.didDeleteTodo called")
        mockStore.deleteExpectation = deleteStoreExp
        mockPresenter.didDeleteExpectation = deletePresenterExp
        
        // When
        sut.deleteTodo(at: 0)
        
        // Then
        wait(for: [deleteStoreExp, deletePresenterExp], timeout: 1.0)
        XCTAssertEqual(mockStore.deleteTodoCalledWithId, "delete1", "Удаление должно быть вызвано с правильным ID")
        XCTAssertEqual(mockPresenter.didDeleteTodoCalledAtIndex, 0, "Презентер должен получить правильный индекс для удаления")
    }
    
    func test_deleteTodo_whenDeleteFails_callsPresenterDidFail() {
        // Given
        let todo1 = createTestTodo(id: "deleteFail1")
        mockStore.fetchShouldReturn = .success([todo1])
        let fetchExp = XCTestExpectation(description: "Initial fetch completed")
        mockPresenter.didFetchExpectation = fetchExp
        sut.fetchTodos()
        wait(for: [fetchExp], timeout: 1.0)
        
        let deleteError = TestError.databaseError
        mockStore.deleteShouldReturn = .failure(deleteError)
        
        // Expectations
        let deleteStoreExp = XCTestExpectation(description: "store.deleteTodo called")
        let failExp = XCTestExpectation(description: "presenter.didFailToFetchTodos called")
        mockStore.deleteExpectation = deleteStoreExp
        mockPresenter.didFailExpectation = failExp
        
        // When
        sut.deleteTodo(at: 0)
        
        // Then
        wait(for: [deleteStoreExp, failExp], timeout: 1.0)
        XCTAssertEqual(mockStore.deleteTodoCalledWithId, "deleteFail1")
        XCTAssertNil(mockPresenter.didDeleteTodoCalledAtIndex, "Удаление не должно дойти до презентера при ошибке")
        XCTAssertNotNil(mockPresenter.didFailToFetchTodosCalledWithError)
        XCTAssertEqual(mockPresenter.didFailToFetchTodosCalledWithError?.localizedDescription, deleteError.localizedDescription)
    }
    
    // MARK: - Helpers method
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
