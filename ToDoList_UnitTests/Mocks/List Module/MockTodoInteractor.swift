//
//  MockTodoInteractor.swift
//  ToDoList
//
//  Created by Niykee Moore on 31.03.2025.
//

@testable import ToDoList

final class MockTodoInteractor: TodoInteractorInput {
    var presenter: TodoInteractorOutput?
    
    var fetchTodosCalled = false
    var toggleTodoComplitionCalledWithIndex: Int?
    var deleteTodoCalledWithIndex: Int?

    func fetchTodos() {
        fetchTodosCalled = true
    }

    func toggleTodoComplition(at index: Int) {
        toggleTodoComplitionCalledWithIndex = index
    }

    func deleteTodo(at index: Int) {
        deleteTodoCalledWithIndex = index
    }
}
