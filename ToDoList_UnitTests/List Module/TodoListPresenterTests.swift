//
//  TodoListPresenterTests.swift
//  ToDoList
//
//  Created by Niykee Moore on 31.03.2025.
//

import XCTest
import CoreData
@testable import ToDoList

final class TodoListPresenterTests: XCTestCase {
    
    var systemUnderTest: TodoListPresenter!
    var mockInteractor: MockTodoListInteractor!
    var mockView: MockTodoListView!
    var mockRouter: MockTodoListRouter!
    var mockDataProvider: MockTodoListDataProvider!
    var mockCoreDataManager: MockCoreDataManager!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        mockInteractor = MockTodoListInteractor()
        mockView = MockTodoListView()
        mockRouter = MockTodoListRouter()
        mockDataProvider = MockTodoListDataProvider()
        mockCoreDataManager = MockCoreDataManager()
        
        systemUnderTest = TodoListPresenter(
            interactor: mockInteractor,
            router: mockRouter,
            dataProvider: mockDataProvider,
            coreDataManager: mockCoreDataManager
        )
        systemUnderTest.viewController = mockView
        mockInteractor.presenter = systemUnderTest
    }
    
    override func tearDownWithError() throws {
        systemUnderTest = nil
        mockInteractor = nil
        mockView = nil
        mockRouter = nil
        mockDataProvider = nil
        mockCoreDataManager = nil
        try super.tearDownWithError()
    }
    
    // MARK: - Тесты viewDidLoad
    
    func test_viewDidLoad_callsInteractorFetchTodosIfNeeded() {
        // When
        systemUnderTest.viewDidLoad()
        
        // Then
        XCTAssertTrue(mockInteractor.fetchTodosIfNeededCalled, "viewDidLoad() должен вызывать interactor.fetchTodosIfNeeded()")
    }
    
    // MARK: - Тесты InteractorOutput (только ошибки)
    
    func test_frcFetchFailed_callsViewDisplayError() {
        // Given
        enum TestError: Error { case frcError }
        let error = TestError.frcError
        
        // When
        systemUnderTest.frcFetchFailed(error: error)
        
        // Then
        XCTAssertNotNil(mockView.displayErrorCalledWithError, "View должен показать ошибку FRC")
        XCTAssertTrue(mockView.displayErrorCalledWithError is TestError, "Тип ошибки должен совпадать")
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
    
    // MARK: - Тесты действий пользователя
    
    func test_checkboxDidTapped_callsDataProviderObjectAt_callsInteractorToggleCompletion() {
        // Given
        let indexPath = IndexPath(row: 0, section: 0)
        let entity = createTestTodoEntity(id: "toggle123", context: mockCoreDataManager.viewContext)
        mockDataProvider.objectToReturn = entity
        
        // When
        systemUnderTest.checkboxDidTapped(at: indexPath)
        
        // Then
        XCTAssertEqual(mockDataProvider.objectAtIndexPathCalled, indexPath, "Должен быть запрошен объект у DataProvider по индексу")
        XCTAssertEqual(mockInteractor.toggleTodoCompletionCalledWithId, "toggle123", "Interactor должен получить ID для переключения")
    }
    
    func test_checkboxDidTapped_whenDataProviderReturnsNil_doesNothing() {
        // Given
        let indexPath = IndexPath(row: 0, section: 0)
        mockDataProvider.objectToReturn = nil
        
        // When
        systemUnderTest.checkboxDidTapped(at: indexPath)
        
        // Then
        XCTAssertEqual(mockDataProvider.objectAtIndexPathCalled, indexPath)
        XCTAssertNil(mockInteractor.toggleTodoCompletionCalledWithId, "Interactor.toggle не должен вызываться")
    }
    
    func test_didTappedCreateTodoButton_callsRouterNavigateToDetailWithNil() {
        // When
        systemUnderTest.didTappedCreateTodoButton()
        
        // Then
        XCTAssertTrue(mockRouter.navigateToTodoDetailCalled, "Роутер должен быть вызван для навигации")
        XCTAssertNil(mockRouter.navigateToTodoDetailCalledWithTodo, "При создании новой задачи todo должен быть nil")
        XCTAssertTrue(mockRouter.coreDataManagerPassed is MockCoreDataManager, "Должен быть передан CoreDataManager")
    }
    
    func test_didTappedEditMenuOptionEdit_callsDataProviderObjectAt_callsRouterNavigateToDetailWithTodo() {
        // Given
        let indexPath = IndexPath(row: 1, section: 0)
        let entity = createTestTodoEntity(id: "edit456", title: "Edit Me", context: mockCoreDataManager.viewContext)
        mockDataProvider.objectToReturn = entity
        
        // When
        systemUnderTest.didTappedEditMenuOption(option: .edit, at: indexPath)
        
        // Then
        XCTAssertEqual(mockDataProvider.objectAtIndexPathCalled, indexPath)
        XCTAssertTrue(mockRouter.navigateToTodoDetailCalled, "Роутер должен быть вызван для навигации")
        XCTAssertEqual(mockRouter.navigateToTodoDetailCalledWithTodo?.id, "edit456", "Роутер должен получить правильное todo для редактирования")
        XCTAssertEqual(mockRouter.navigateToTodoDetailCalledWithTodo?.title, "Edit Me")
        XCTAssertTrue(mockRouter.coreDataManagerPassed is MockCoreDataManager, "Должен быть передан CoreDataManager")
    }
    
    func test_didTappedEditMenuOptionShare_callsDataProviderObjectAt_callsViewShowShare() {
        // Given
        let indexPath = IndexPath(row: 0, section: 0)
        let entity = createTestTodoEntity(id: "share789", title: "Share This", context: mockCoreDataManager.viewContext)
        mockDataProvider.objectToReturn = entity
        
        // When
        systemUnderTest.didTappedEditMenuOption(option: .share, at: indexPath)
        
        // Then
        XCTAssertEqual(mockDataProvider.objectAtIndexPathCalled, indexPath)
        XCTAssertEqual(mockView.showShareCalledWithTodo?.id, "share789", "View должен получить правильное todo для шаринга")
        XCTAssertEqual(mockView.showShareCalledWithTodo?.title, "Share This")
    }
    
    func test_didTappedEditMenuOptionDelete_callsDataProviderObjectAt_callsInteractorDeleteTodo() {
        // Given
        let indexPath = IndexPath(row: 0, section: 0)
        let entity = createTestTodoEntity(id: "delete101", context: mockCoreDataManager.viewContext)
        mockDataProvider.objectToReturn = entity
        
        // When
        systemUnderTest.didTappedEditMenuOption(option: .delete, at: indexPath)
        
        // Then
        XCTAssertEqual(mockDataProvider.objectAtIndexPathCalled, indexPath)
        XCTAssertEqual(mockInteractor.deleteTodoCalledWithId, "delete101", "Interactor должен получить ID для удаления")
    }
    
    // MARK: - Тесты поиска
    
    func test_searchTextChanged_callsDataProviderUpdatePredicate() {
        // Given
        let searchText = "find me"
        
        // When
        systemUnderTest.searchTextChanged(to: searchText)
        
        // Then
        XCTAssertEqual(mockDataProvider.updatePredicateCalledWithText, searchText, "DataProvider должен обновить предикат с текстом поиска")
    }
    
    
    // MARK: - Helpers
    @discardableResult
    func createTestTodoEntity(id: String = UUID().uuidString, title: String = "Test", description: String = "Desc", isCompleted: Bool = false, date: Date = Date(), context: NSManagedObjectContext) -> TodoEntity {
        let entity = TodoEntity(context: context)
        entity.id = id
        entity.title = title
        entity.todoDescription = description
        entity.isCompleted = isCompleted
        entity.dateOfCreation = date
        return entity
    }
}
