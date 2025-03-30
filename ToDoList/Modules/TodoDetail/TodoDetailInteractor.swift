//
//  TodoDetailInteractor.swift
//  ToDoList
//
//  Created by Niykee Moore on 30.03.2025.
//

import Foundation

protocol TodoDetailInteractorInput: AnyObject {
    func saveTodo(todo: Todo)
}

protocol TodoDetailInteractorOutput: AnyObject {
    
}

final class TodoDetailInteractor: TodoDetailInteractorInput {
    // MARK: - Dependencies
    weak var presenter: TodoDetailInteractorOutput?
    
    // MARK: - Properties
    private var todo: Todo?
    
    // MARK: - Initialization
    init(todo: Todo?) {
        self.todo = todo
    }
    
    func saveTodo(todo: Todo) {
        print("SAVED TODO: \(todo)")
    }
}
