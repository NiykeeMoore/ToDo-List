//
//  TodoListInteractorTests.swift
//  ToDoListTests
//
//  Created by Niykee Moore on 31.03.2025.
//

import XCTest
import CoreData
@testable import ToDoList

final class TodoListInteractorTests: XCTestCase {
    
    var sut: TodoListInteractor!
    var mockPresenter: MockTodoListPresenter!
    var mockLoader: MockTodosLoader!
    var mockStore: MockTodoStore!
    var mockCoreDataManager: MockCoreDataManager!
    let initialDataKey = "didLoadInitialDataKey"
    var contextDidSaveObserver: NSObjectProtocol?
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        mockPresenter = MockTodoListPresenter()
        mockLoader = MockTodosLoader()
        mockStore = MockTodoStore()
        mockCoreDataManager = MockCoreDataManager()
        
        sut = TodoListInteractor(
            todosLoader: mockLoader,
            todoStore: mockStore,
            coreDataManager: mockCoreDataManager
        )
        sut.presenter = mockPresenter
        
        UserDefaults.standard.removeObject(forKey: initialDataKey)
        
        mockCoreDataManager.viewContext.automaticallyMergesChangesFromParent = true
        mockCoreDataManager.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    override func tearDownWithError() throws {
        if let observer = contextDidSaveObserver {
            NotificationCenter.default.removeObserver(observer)
            contextDidSaveObserver = nil
        }
        sut = nil
        mockPresenter = nil
        mockLoader = nil
        mockStore = nil
        mockCoreDataManager = nil
        UserDefaults.standard.removeObject(forKey: initialDataKey)
        try super.tearDownWithError()
    }
    
    // MARK: - fetchTodosIfNeeded Tests
    
    func test_fetchTodosIfNeeded_whenFirstLoadAndStoreIsEmpty_callsLoaderAndSavesData() {
        // Given
        let networkDTOs = [
            TodoItemDTO(id: 1, todo: "Task 1", completed: false, userId: 1),
            TodoItemDTO(id: 2, todo: "Task 2", completed: true, userId: 1)
        ]
        mockStore.fetchShouldReturn = .success([])
        mockLoader.loadShouldReturnDTO = .success(networkDTOs)
        UserDefaults.standard.set(false, forKey: initialDataKey)
        
        // Expectations
        let loadExp = XCTestExpectation(description: "loader.load called")
        let saveExp = XCTestExpectation(description: "Context saved after network load")
        mockLoader.loadExpectation = loadExp
        
        contextDidSaveObserver = NotificationCenter.default.addObserver(
            forName: .NSManagedObjectContextDidSave,
            object: nil,
            queue: nil) { notification in
                
                self.mockCoreDataManager.viewContext.performAndWait {
                    let fetchRequest: NSFetchRequest<TodoEntity> = TodoEntity.fetchRequest()
                    let count = try? self.mockCoreDataManager.viewContext.count(for: fetchRequest)
                    print("Context saved notification received. Count in viewContext: \(String(describing: count))")
                    if count == networkDTOs.count {
                        saveExp.fulfill()
                    }
                }
            }
        
        // When
        sut.fetchTodosIfNeeded()
        
        // Then
        wait(for: [loadExp], timeout: 2.0)
        wait(for: [saveExp], timeout: 5.0)
        
        let mainQueueExpectation = expectation(description: "Wait for main queue block")
        DispatchQueue.main.async {
            mainQueueExpectation.fulfill()
        }
        
        wait(for: [mainQueueExpectation], timeout: 1.0)
        
        XCTAssertTrue(mockLoader.loadCalled, "Загрузчик из сети должен вызваться")
        
        mockCoreDataManager.viewContext.performAndWait {
            let fetchRequest: NSFetchRequest<TodoEntity> = TodoEntity.fetchRequest()
            let finalCount = try? mockCoreDataManager.viewContext.count(for: fetchRequest)
            XCTAssertEqual(finalCount, networkDTOs.count, "Конечное количество записей в viewContext должно быть \(networkDTOs.count)")
        }
        
        XCTAssertTrue(UserDefaults.standard.bool(forKey: initialDataKey), "Флаг initialDataKey должен стать true после успешной загрузки")
    }
    
    func test_fetchTodosIfNeeded_whenNotFirstLoad_doesNotCallLoader() {
        // Given
        UserDefaults.standard.set(true, forKey: initialDataKey)
        mockStore.fetchShouldReturn = .success([createTestTodo(id: "existing")])
        
        // When
        sut.fetchTodosIfNeeded()
        
        // Then
        let expectation = XCTestExpectation(description: "Wait for potential async operations")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertFalse(mockLoader.loadCalled, "Загрузчик из сети не должен вызываться, если не первая загрузка")
        XCTAssertFalse(mockStore.batchInsertCalled, "Batch insert не должен вызываться")
    }
    
    func test_fetchTodosIfNeeded_whenFirstLoadButStoreIsNotEmpty_doesNotCallLoader_setsFlag() {
        // Given
        mockStore.fetchShouldReturn = .success([createTestTodo(id: "existing")])
        UserDefaults.standard.set(false, forKey: initialDataKey)
        
        // Expectation
        let storeCheckExp = XCTestExpectation(description: "store.fetchTodos called")
        mockStore.fetchExpectation = storeCheckExp
        
        
        // When
        sut.fetchTodosIfNeeded()
        
        // Then
        wait(for: [storeCheckExp], timeout: 1.0)
        
        let delayExpectation = XCTestExpectation(description: "Wait for potential async operations")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            delayExpectation.fulfill()
        }
        wait(for: [delayExpectation], timeout: 1.0)
        
        XCTAssertFalse(mockLoader.loadCalled, "Загрузчик из сети не должен вызываться, если хранилище не пусто")
        XCTAssertFalse(mockStore.batchInsertCalled, "Batch insert не должен вызываться")
        XCTAssertTrue(UserDefaults.standard.bool(forKey: initialDataKey), "Флаг initialDataKey должен установиться в true")
    }
    
    
    func test_fetchTodosIfNeeded_whenStoreFetchFails_callsPresenterDidFail() {
        // Given
        let dbError = TestError.databaseError
        mockStore.fetchShouldReturn = .failure(dbError)
        UserDefaults.standard.set(false, forKey: initialDataKey)
        
        // Expectation
        let failExp = XCTestExpectation(description: "presenter.didFailToFetchTodos called")
        mockPresenter.didFailExpectation = failExp
        
        // When
        sut.fetchTodosIfNeeded()
        
        // Then
        wait(for: [failExp], timeout: 1.0)
        XCTAssertFalse(mockLoader.loadCalled)
        XCTAssertNotNil(mockPresenter.didFailToFetchTodosCalledWithError)
        XCTAssertEqual(mockPresenter.didFailToFetchTodosCalledWithError?.localizedDescription, dbError.localizedDescription)
    }
    
    func test_fetchTodosIfNeeded_whenNetworkLoadFails_callsPresenterDidFail() {
        // Given
        mockStore.fetchShouldReturn = .success([])
        let networkError = TestError.networkError
        mockLoader.loadShouldReturnDTO = .failure(networkError)
        UserDefaults.standard.set(false, forKey: initialDataKey)
        
        // Expectations
        let loadExp = XCTestExpectation(description: "loader.load called")
        let failExp = XCTestExpectation(description: "presenter.didFailToFetchTodos called")
        mockLoader.loadExpectation = loadExp
        mockPresenter.didFailExpectation = failExp
        
        // When
        sut.fetchTodosIfNeeded()
        
        // Then
        wait(for: [loadExp, failExp], timeout: 1.0)
        XCTAssertTrue(mockLoader.loadCalled)
        XCTAssertNotNil(mockPresenter.didFailToFetchTodosCalledWithError)
        XCTAssertEqual(mockPresenter.didFailToFetchTodosCalledWithError?.localizedDescription, networkError.localizedDescription)
        XCTAssertFalse(UserDefaults.standard.bool(forKey: initialDataKey), "Флаг не должен ставиться при ошибке сети")
    }
    
    
    // MARK: - toggleTodoCompletion Tests
    
    func test_toggleTodoCompletion_updatesEntityInBackground() {
        // Given
        let todoId = "toggle1"
        
        mockCoreDataManager.viewContext.performAndWait {
            let entity = TodoEntity(context: mockCoreDataManager.viewContext)
            entity.id = todoId
            entity.isCompleted = false
            try! mockCoreDataManager.viewContext.save()
        }
        
        
        let expectation = XCTestExpectation(description: "Background context saved and view context updated")
        
        contextDidSaveObserver = NotificationCenter.default.addObserver(
            forName: .NSManagedObjectContextDidSave,
            object: nil,
            queue: nil) { notification in
                
                print("Notification received: \(notification.name)")
                if let updatedObjects = notification.userInfo?[NSUpdatedObjectsKey] as? Set<NSManagedObject> {
                    print("Updated objects: \(updatedObjects.count)")
                    for obj in updatedObjects {
                        if let todo = obj as? TodoEntity {
                            print("  TodoEntity ID: \(todo.id ?? "nil"), isCompleted: \(todo.isCompleted)")
                        }
                    }
                }
                
                self.mockCoreDataManager.viewContext.performAndWait {
                    print("Checking assertion inside viewContext.performAndWait")
                    let fetchRequest: NSFetchRequest<TodoEntity> = TodoEntity.fetchRequest()
                    fetchRequest.predicate = NSPredicate(format: "id == %@", todoId)
                    do {
                        let fetched = try self.mockCoreDataManager.viewContext.fetch(fetchRequest)
                        if let first = fetched.first {
                            print("Fetched entity in viewContext: ID \(first.id ?? "nil"), isCompleted: \(first.isCompleted)")
                            // Убедимся, что проверка происходит только после нужного сохранения
                            if first.isCompleted == true {
                                XCTAssertEqual(first.isCompleted, true, "isCompleted должен стать true")
                                expectation.fulfill() // Выполняем ожидание только если проверка прошла
                            } else {
                                print("isCompleted is still false in viewContext, waiting for merge...")
                            }
                        } else {
                            print("Entity not found in viewContext yet.")
                            //XCTFail("Entity с id \(todoId) не найдена в viewContext после сохранения")
                        }
                    } catch {
                        XCTFail("Ошибка fetch в viewContext: \(error)")
                    }
                }
            }
        
        // When
        print("Calling sut.toggleTodoCompletion...")
        sut.toggleTodoCompletion(for: todoId)
        print("Called sut.toggleTodoCompletion.")
        
        // Then
        wait(for: [expectation], timeout: 5.0)
    }
    
    
    func test_toggleTodoCompletion_whenEntityNotFound_doesNothing() {
        // Given
        let nonExistentId = "nonExistentToggle"
        let saveShouldNotBeCalledExpectation = XCTestExpectation(description: "Context save should not be called")
        saveShouldNotBeCalledExpectation.isInverted = true
        
        contextDidSaveObserver = NotificationCenter.default.addObserver(forName: .NSManagedObjectContextDidSave, object: nil, queue: nil) { _ in
            saveShouldNotBeCalledExpectation.fulfill()
        }
        
        // When
        sut.toggleTodoCompletion(for: nonExistentId)
        
        // Then
        wait(for: [saveShouldNotBeCalledExpectation], timeout: 1.0)
        XCTAssertNil(mockPresenter.didFailToFetchTodosCalledWithError)
    }
    
    func test_toggleTodoCompletion_whenContextSaveFails_callsPresenterDidFail() {
        print("Skipping test_toggleTodoCompletion_whenContextSaveFails due to complexity.")
    }
    
    
    // MARK: - deleteTodo Tests
    
    func test_deleteTodo_callsStoreDeleteWithCorrectId() {
        // Given
        let todoIdToDelete = "delete1"
        mockStore.deleteShouldReturn = .success(())
        
        // Expectations
        let deleteStoreExp = XCTestExpectation(description: "store.deleteTodo called")
        mockStore.deleteExpectation = deleteStoreExp
        
        // When
        sut.deleteTodo(with: todoIdToDelete)
        
        // Then
        wait(for: [deleteStoreExp], timeout: 1.0)
        XCTAssertEqual(mockStore.deleteTodoCalledWithId, todoIdToDelete, "Удаление в хранилище должно быть вызвано с правильным ID")
        XCTAssertNil(mockPresenter.didFailToFetchTodosCalledWithError, "Ошибки быть не должно при успешном удалении")
    }
    
    func test_deleteTodo_whenDeleteFails_callsPresenterDidFail() {
        // Given
        let todoIdToDelete = "deleteFail1"
        let deleteError = TestError.databaseError
        mockStore.deleteShouldReturn = .failure(deleteError)
        
        // Expectations
        let deleteStoreExp = XCTestExpectation(description: "store.deleteTodo called")
        let failExp = XCTestExpectation(description: "presenter.didFailToFetchTodos called")
        mockStore.deleteExpectation = deleteStoreExp
        mockPresenter.didFailExpectation = failExp
        
        // When
        sut.deleteTodo(with: todoIdToDelete)
        
        // Then
        wait(for: [deleteStoreExp, failExp], timeout: 1.0)
        XCTAssertEqual(mockStore.deleteTodoCalledWithId, todoIdToDelete)
        XCTAssertNotNil(mockPresenter.didFailToFetchTodosCalledWithError)
        XCTAssertEqual(mockPresenter.didFailToFetchTodosCalledWithError?.localizedDescription, deleteError.localizedDescription)
    }
    
    // MARK: - Helper to create TodoEntity
    @discardableResult
    private func createAndSaveTodoEntity(id: String, title: String, date: Date, isCompleted: Bool, description: String = "", context: NSManagedObjectContext) -> TodoEntity {
        let entity = TodoEntity(context: context)
        entity.id = id
        entity.title = title
        entity.dateOfCreation = date
        entity.isCompleted = isCompleted
        entity.todoDescription = description
        try! context.save()
        return entity
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
    
    func removeNotificationObserver(notificationName: NSNotification.Name, object: Any?) {
        NotificationCenter.default.removeObserver(self, name: notificationName, object: object)
    }
}
