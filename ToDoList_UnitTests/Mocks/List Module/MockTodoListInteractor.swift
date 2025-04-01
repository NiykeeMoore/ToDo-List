//
//  MockTodoListInteractor.swift
//  ToDoList
//
//  Created by Niykee Moore on 31.03.2025.
//

@testable import ToDoList

final class MockTodoListInteractor: TodoInteractorInput {
    var presenter: TodoInteractorOutput?
    
    var fetchTodosIfNeededCalled = false
    var toggleTodoCompletionCalledWithId: String?
    var deleteTodoCalledWithId: String?
    
    func fetchTodosIfNeeded() {
        fetchTodosIfNeededCalled = true
    }
    
    func toggleTodoCompletion(for todoID: String) {
        toggleTodoCompletionCalledWithId = todoID
    }
    
    func deleteTodo(with todoID: String) {
        deleteTodoCalledWithId = todoID
    }
}
