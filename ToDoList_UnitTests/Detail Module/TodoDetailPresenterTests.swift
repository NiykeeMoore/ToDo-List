//
//  TodoDetailPresenterTests.swift
//  ToDoList
//
//  Created by Niykee Moore on 31.03.2025.
//

import XCTest
@testable import ToDoList

final class TodoDetailPresenterTests: XCTestCase {
    
    // systemUnderTest и моки будут создаваться для каждого теста отдельно,
    // т.к. systemUnderTest инициализируется с разными параметрами - nil или существующий Todo
    var systemUnderTest: TodoDetailPresenter!
    var mockInteractor: MockTodoDetailInteractor!
    var mockView: MockTodoDetailView!
    var mockRouter: MockTodoDetailRouter!
    
    func setupPresenter(with todo: Todo?) {
        mockInteractor = MockTodoDetailInteractor()
        mockView = MockTodoDetailView()
        mockRouter = MockTodoDetailRouter()
        
        systemUnderTest = TodoDetailPresenter(interactor: mockInteractor, todo: todo)
        systemUnderTest.viewController = mockView
        systemUnderTest.router = mockRouter
        mockInteractor.presenter = systemUnderTest
    }
    
    override func tearDownWithError() throws {
        systemUnderTest = nil
        mockInteractor = nil
        mockView = nil
        mockRouter = nil
        try super.tearDownWithError()
    }
    
    // MARK: - Тесты viewDidLoad
    
    func test_viewDidLoad_whenExistingTodo_callsViewTodoLoadedWithExistingTodo() {
        // Given
        let existingTodo = createTestTodo(id: "existing123", title: "Existing Task")
        setupPresenter(with: existingTodo)
        
        // When
        systemUnderTest.viewDidLoad()
        
        // Then
        XCTAssertEqual(mockView.todoLoadedCalledWithTodo?.id, "existing123", "View должен загрузить переданный todo")
        XCTAssertEqual(mockView.todoLoadedCalledWithTodo?.title, "Existing Task")
    }
    
    func test_viewDidLoad_whenNewTodo_callsViewTodoLoadedWithGeneratedTodo() {
        // Given
        setupPresenter(with: nil)
        
        // When
        systemUnderTest.viewDidLoad()
        
        // Then
        let loadedTodo = mockView.todoLoadedCalledWithTodo
        XCTAssertNotNil(loadedTodo, "View должен получить сгенерированный пустой todo")
        XCTAssertFalse(loadedTodo?.id.isEmpty ?? true, "У нового todo должен быть сгенерирован ID")
        XCTAssertEqual(loadedTodo?.title, "", "Название нового todo должно быть пустым")
        XCTAssertEqual(loadedTodo?.description, "", "Описание нового todo должно быть пустым")
        XCTAssertFalse(loadedTodo?.isCompleted ?? true, "Новый todo не должен быть выполнен")
        XCTAssertNotNil(loadedTodo?.dateOfCreation)
    }
    
    // MARK: - Тесты buttonBackPressed
    
    func test_buttonBackPressed_whenNoChanges_doesNotCallInteractorSave_callsRouterNavigateBack() {
        // Given
        let existingTodo = createTestTodo(id: "1", title: "Title", description: "Desc")
        setupPresenter(with: existingTodo)
        systemUnderTest.viewDidLoad()
        
        // When
        systemUnderTest.buttonBackPressed(currentTitle: "Title", currentDescription: "Desc")
        
        // Then
        XCTAssertNil(mockInteractor.saveTodoCalledWithTodo, "Сохранение не должно вызываться, если нет изменений")
        XCTAssertTrue(mockRouter.navigateBackCalled, "Навигация назад должна быть вызвана")
    }
    
    func test_buttonBackPressed_whenNewTodoIsEmptyAndRemainsEmpty_doesNotCallInteractorSave_callsRouterNavigateBack() {
        // Given
        setupPresenter(with: nil)
        systemUnderTest.viewDidLoad()
        
        // When
        systemUnderTest.buttonBackPressed(currentTitle: "", currentDescription: "")
        
        // Then
        XCTAssertNil(mockInteractor.saveTodoCalledWithTodo, "Сохранение не должно вызываться для пустой новой задачи")
        XCTAssertTrue(mockRouter.navigateBackCalled, "Навигация назад должна быть вызвана")
    }
    
    func test_buttonBackPressed_whenNewTodoIsNotEmpty_callsInteractorSave_callsRouterNavigateBack() {
        // Given
        setupPresenter(with: nil)
        systemUnderTest.viewDidLoad()
        let originalGeneratedId = mockView.todoLoadedCalledWithTodo?.id
        
        // When
        systemUnderTest.buttonBackPressed(currentTitle: "New Task Title", currentDescription: "Some description")
        
        // Then
        let savedTodo = mockInteractor.saveTodoCalledWithTodo
        XCTAssertNotNil(savedTodo, "Сохранение должно быть вызвано для непустой новой задачи")
        XCTAssertEqual(savedTodo?.id, originalGeneratedId, "ID должен совпадать со сгенерированным при viewDidLoad")
        XCTAssertEqual(savedTodo?.title, "New Task Title")
        XCTAssertEqual(savedTodo?.description, "Some description")
        XCTAssertTrue(mockRouter.navigateBackCalled, "Навигация назад должна быть вызвана")
    }
    
    // MARK: - Тесты InteractorOutput
    
    func test_didSaveTodoSuccessfully_doesNothingSpecific() {
        // Given
        setupPresenter(with: nil)
        
        // When/Then - просто проверяем, что вызов не падает
        XCTAssertNoThrow(systemUnderTest.didSaveTodoSuccessfully())
    }
    
    func test_didFailToSaveTodo_callsViewDisplaySaveError() {
        // Given
        setupPresenter(with: nil)
        enum TestError: Error { case saveFailed }
        let error = TestError.saveFailed
        
        // When
        systemUnderTest.didFailToSaveTodo(error: error)
        
        // Then
        XCTAssertNotNil(mockView.displaySaveErrorCalledWithError, "View должен показать ошибку сохранения")
        XCTAssertTrue(mockView.displaySaveErrorCalledWithError is TestError, "Тип ошибки должен совпадать")
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
