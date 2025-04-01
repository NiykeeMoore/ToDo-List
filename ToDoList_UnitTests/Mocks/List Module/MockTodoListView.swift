//
//  MockTodoListView.swift
//  ToDoList
//
//  Created by Niykee Moore on 31.03.2025.
//

@testable import ToDoList

final class MockTodoListView: TodoListViewInput {
    var displayErrorCalledWithError: Error?
    var showShareCalledWithTodo: Todo?
    var updateTodoCounterCalledWithCount: Int?
    
    func displayError(error: Error) {
        displayErrorCalledWithError = error
    }
    
    func showShare(for todo: Todo) {
        showShareCalledWithTodo = todo
    }
    
    func updateTodoCounter(_ count: Int) {
        updateTodoCounterCalledWithCount = count
    }
}
