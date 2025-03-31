//
//  TodoListPresenterTests.swift
//  ToDoList
//
//  Created by Niykee Moore on 31.03.2025.
//

import XCTest
@testable import ToDoList

final class TodoListPresenterTests: XCTestCase {
    
    var systemUnderTest: TodoListPresenter!
    var mockInteractor: MockTodoInteractor!
    var mockView: MockTodoListView!
    var mockRouter: MockTodoListRouter!
    var mockCoreDataManager: MockCoreDataManager!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        mockInteractor = MockTodoInteractor()
        mockView = MockTodoListView()
        mockRouter = MockTodoListRouter()
        mockCoreDataManager = MockCoreDataManager()
        
        systemUnderTest = TodoListPresenter(interactor: mockInteractor, coreDataManager: mockCoreDataManager)
        systemUnderTest.viewController = mockView
        systemUnderTest.router = mockRouter
        mockInteractor.presenter = systemUnderTest
    }
    
    override func tearDownWithError() throws {
        systemUnderTest = nil
        mockInteractor = nil
        mockView = nil
        mockRouter = nil
        mockCoreDataManager = nil
        try super.tearDownWithError()
    }
    
    // MARK: - Тесты
    
    func test_viewDidLoad_callsInteractorFetchTodos() {
        // When
        systemUnderTest.viewDidLoad()
        
        // Then
        XCTAssertTrue(mockInteractor.fetchTodosCalled, "viewDidLoad() должен вызывать interactor.fetchTodos()")
    }
    
    func test_didFetchTodos_updatesTodosAndReloadsView() {
        // Given
        let todos = [createTestTodo(id: "1"), createTestTodo(id: "2")]
        
        // When
        systemUnderTest.didFetchTodos(todos: todos)
        
        // Then
        XCTAssertEqual(systemUnderTest.numberOfRows(), 2, "Количество строк должно обновиться")
        XCTAssertTrue(mockView.reloadDataCalled, "View должен перезагрузить данные")
        XCTAssertEqual(mockView.reloadDataTodoCount, 2, "Количество задач при перезагрузке должно быть 2")
        
        
        XCTAssertEqual(systemUnderTest.getTodo(at: 0)?.id, "1")
        XCTAssertEqual(systemUnderTest.getTodo(at: 1)?.id, "2")
    }
    
    func test_didFailToFetchTodos_callsViewDisplayError() {
        // Given
        enum TestError: Error { case generic }
        let error = TestError.generic
        
        // When
        systemUnderTest.didFailToFetchTodos(error: error)
        
        // Then
        XCTAssertNotNil(mockView.displayErrorCalledWithError, "View должен показать ошибку")
        XCTAssertTrue(mockView.displayErrorCalledWithError is TestError, "Тип ошибки должен совпадать")
    }
    
    func test_checkboxDidTapped_callsInteractorToggleCompletion() {
        // Given
        let todos = [createTestTodo(id: "1", title: "Task 1"), createTestTodo(id: "2", title: "Task 2")]
        systemUnderTest.didFetchTodos(todos: todos)
        
        // When
        systemUnderTest.checkboxDidTapped(at: 1)
        
        // Then
        XCTAssertEqual(mockInteractor.toggleTodoComplitionCalledWithIndex, 1, "Interactor должен получить правильный индекс для переключения")
    }
    
    func test_checkboxDidTapped_whenSearching_callsInteractorWithCorrectOriginalIndex() {
        // Given
        let todos = [
            createTestTodo(id: "1", title: "Apple"),
            createTestTodo(id: "2", title: "Banana"),
            createTestTodo(id: "3", title: "Avocado")
        ]
        systemUnderTest.didFetchTodos(todos: todos)
        systemUnderTest.searchTextChanged(to: "Avo")
        
        // When
        systemUnderTest.checkboxDidTapped(at: 0)
        
        // Then
        XCTAssertEqual(mockInteractor.toggleTodoComplitionCalledWithIndex, 2, "Interactor должен получить оригинальный индекс (2) для 'Avocado'")
    }
    
    func test_didTappedCreateTodoButton_callsRouterNavigateToDetailWithNil() {
        // When
        systemUnderTest.didTappedCreateTodoButton()
        
        // Then
        XCTAssertTrue(mockRouter.navigateToTodoDetailCalled, "Роутер должен быть вызван для навигации")
        XCTAssertNil(mockRouter.navigateToTodoDetailCalledWithTodo, "При создании новой задачи todo должен быть nil")
        XCTAssertTrue(mockRouter.coreDataManagerPassed is MockCoreDataManager, "Должен быть передан CoreDataManager")
    }
    
    func test_didTappedEditMenuOptionEdit_callsRouterNavigateToDetailWithTodo() {
        // Given
        let todo1 = createTestTodo(id: "1")
        let todo2 = createTestTodo(id: "2")
        systemUnderTest.didFetchTodos(todos: [todo1, todo2])
        
        // When
        systemUnderTest.didTappedEditMenuOption(option: .edit, at: 1)
        
        // Then
        XCTAssertTrue(mockRouter.navigateToTodoDetailCalled, "Роутер должен быть вызван для навигации")
        XCTAssertEqual(mockRouter.navigateToTodoDetailCalledWithTodo?.id, "2", "Роутер должен получить правильное todo для редактирования")
        XCTAssertTrue(mockRouter.coreDataManagerPassed is MockCoreDataManager, "Должен быть передан CoreDataManager")
    }
    
    func test_didTappedEditMenuOptionShare_callsViewShowShare() {
        // Given
        let todo1 = createTestTodo(id: "1")
        let todo2 = createTestTodo(id: "2")
        systemUnderTest.didFetchTodos(todos: [todo1, todo2])
        
        // When
        systemUnderTest.didTappedEditMenuOption(option: .share, at: 0)
        
        // Then
        XCTAssertEqual(mockView.showShareCalledWithTodo?.id, "1", "View должен получить правильное todo для шаринга")
        XCTAssertFalse(mockRouter.showShareScreenCalled, "Метод роутера showShareScreen не должен вызываться напрямую из этой опции презентера")
    }
    
    func test_didTappedEditMenuOptionDelete_callsInteractorDeleteTodo() {
        // Given
        let todo1 = createTestTodo(id: "1")
        let todo2 = createTestTodo(id: "2")
        systemUnderTest.didFetchTodos(todos: [todo1, todo2])
        
        // When
        systemUnderTest.didTappedEditMenuOption(option: .delete, at: 0)
        
        // Then
        XCTAssertEqual(mockInteractor.deleteTodoCalledWithIndex, 0, "Interactor должен получить правильный индекс для удаления")
    }
    
    func test_didTappedEditMenuOptionDelete_whenSearching_callsInteractorWithCorrectOriginalIndex() {
        // Given
        let todos = [
            createTestTodo(id: "1", title: "Apple"),
            createTestTodo(id: "2", title: "Banana"),
            createTestTodo(id: "3", title: "Avocado")
        ]
        systemUnderTest.didFetchTodos(todos: todos)
        systemUnderTest.searchTextChanged(to: "bana")
        
        // When
        systemUnderTest.didTappedEditMenuOption(option: .delete, at: 0)
        
        // Then
        XCTAssertEqual(mockInteractor.deleteTodoCalledWithIndex, 1, "Interactor должен получить оригинальный индекс (1) для 'Banana'")
    }
    
    
    // MARK: - Тесты на обновление/удаление
    
    func test_didUpdateTodo_updatesInternalStateAndReloadsRow() {
        // Given
        let initialTodos = [createTestTodo(id: "1", isCompleted: false), createTestTodo(id: "2")]
        systemUnderTest.didFetchTodos(todos: initialTodos)
        let updatedTodo = createTestTodo(id: "1", isCompleted: true)
        
        // When
        systemUnderTest.didUpdateTodo(at: 0, with: updatedTodo)
        
        // Then
        XCTAssertEqual(systemUnderTest.getTodo(at: 0)?.isCompleted, true, "Состояние todo должно обновиться")
        XCTAssertEqual(mockView.reloadRowCalledAtIndex, 0, "View должен обновить строку по правильному индексу")
        XCTAssertEqual(mockView.reloadRowTodoCount, 2, "Количество задач при обновлении строки должно быть 2")
    }
    
    func test_didDeleteTodo_updatesInternalStateAndDeletesRow() {
        // Given
        let initialTodos = [createTestTodo(id: "1"), createTestTodo(id: "2")]
        systemUnderTest.didFetchTodos(todos: initialTodos)
        
        // When
        systemUnderTest.didDeleteTodo(at: 0)
        
        // Then
        XCTAssertEqual(systemUnderTest.numberOfRows(), 1, "Количество todo должно уменьшиться")
        XCTAssertEqual(systemUnderTest.getTodo(at: 0)?.id, "2", "Оставшийся todo должен быть правильным")
        XCTAssertEqual(mockView.deleteRowCalledAtIndex, 0, "View должен удалить строку по правильному индексу")
        XCTAssertEqual(mockView.deleteRowTodoCount, 1, "Количество задач при удалении строки должно быть 1")
    }
    
    // MARK: - Тесты поиска
    
    func test_searchTextChanged_toEmpty_showsAllTodos() {
        // Given
        let todos = [createTestTodo(id: "1"), createTestTodo(id: "2")]
        systemUnderTest.didFetchTodos(todos: todos)
        systemUnderTest.searchTextChanged(to: "some search")
        
        // When
        systemUnderTest.searchTextChanged(to: "")
        
        // Then
        XCTAssertEqual(systemUnderTest.numberOfRows(), 2, "Должны отображаться все задачи")
        XCTAssertEqual(mockView.reloadDataTodoCount, 2, "Количество задач при перезагрузке должно быть 2")
        XCTAssertTrue(mockView.reloadDataCalled)
    }
    
    func test_searchTextChanged_filtersByTitle() {
        // Given
        let todos = [createTestTodo(title: "Find Me"), createTestTodo(title: "Another")]
        systemUnderTest.didFetchTodos(todos: todos)
        
        // When
        systemUnderTest.searchTextChanged(to: "find")
        
        // Then
        XCTAssertEqual(systemUnderTest.numberOfRows(), 1, "Должна остаться одна задача")
        XCTAssertEqual(systemUnderTest.getTodo(at: 0)?.title, "Find Me", "Оставшаяся задача должна быть правильной")
        XCTAssertEqual(mockView.reloadDataTodoCount, 1)
        XCTAssertTrue(mockView.reloadDataCalled)
    }
    
    func test_searchTextChanged_noResults() {
        // Given
        let todos = [createTestTodo(title: "One"), createTestTodo(title: "Two")]
        systemUnderTest.didFetchTodos(todos: todos)
        
        // When
        systemUnderTest.searchTextChanged(to: "Three")
        
        // Then
        XCTAssertEqual(systemUnderTest.numberOfRows(), 0, "Не должно быть найденных задач")
        XCTAssertEqual(mockView.reloadDataTodoCount, 0)
        XCTAssertTrue(mockView.reloadDataCalled)
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
