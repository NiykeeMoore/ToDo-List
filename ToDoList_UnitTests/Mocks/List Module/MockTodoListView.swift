//
//  MockTodoListView.swift
//  ToDoList
//
//  Created by Niykee Moore on 31.03.2025.
//

@testable import ToDoList

final class MockTodoListView: TodoListViewInput {
    var reloadDataCalled = false
    var reloadDataTodoCount: Int?
    var displayErrorCalledWithError: Error?
    var reloadRowCalledAtIndex: Int?
    var reloadRowTodoCount: Int?
    var deleteRowCalledAtIndex: Int?
    var deleteRowTodoCount: Int?
    var showShareCalledWithTodo: Todo?

    func reloadData(todoCount: Int) {
        reloadDataCalled = true
        reloadDataTodoCount = todoCount
    }

    func displayError(error: Error) {
        displayErrorCalledWithError = error
    }

    func reloadRow(at index: Int, todoCount: Int) {
        reloadRowCalledAtIndex = index
        reloadRowTodoCount = todoCount
    }

    func deleteRow(at index: Int, todoCount: Int) {
        deleteRowCalledAtIndex = index
        deleteRowTodoCount = todoCount
    }

    func showShare(for todo: Todo) {
        showShareCalledWithTodo = todo
    }
}
