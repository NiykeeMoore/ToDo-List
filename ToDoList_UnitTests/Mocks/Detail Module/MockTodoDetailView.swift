//
//  MockTodoDetailView.swift
//  ToDoList
//
//  Created by Niykee Moore on 31.03.2025.
//

@testable import ToDoList

final class MockTodoDetailView: TodoDetailViewInput {
    var todoLoadedCalledWithTodo: Todo?
    var displaySaveErrorCalledWithError: Error?

    func todoLoaded(_ todo: Todo?) {
        todoLoadedCalledWithTodo = todo
    }

    func displaySaveError(_ error: Error) {
        displaySaveErrorCalledWithError = error
    }
}
