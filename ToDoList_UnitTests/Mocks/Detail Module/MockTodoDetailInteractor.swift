//
//  MockTodoDetailInteractor.swift
//  ToDoList
//
//  Created by Niykee Moore on 31.03.2025.
//

@testable import ToDoList

final class MockTodoDetailInteractor: TodoDetailInteractorInput {
    var presenter: ToDoList.TodoDetailInteractorOutput?

    var saveTodoCalledWithTodo: Todo?

    func saveTodo(todo: Todo) {
        saveTodoCalledWithTodo = todo
    }
}
