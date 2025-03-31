//
//  TodoDetailPresenter.swift
//  ToDoList
//
//  Created by Niykee Moore on 30.03.2025.
//

import Foundation

protocol TodoDetailPresenterInput: AnyObject {
    func viewDidLoad()
    func buttonBackPressed(save todo: Todo?)
}

final class TodoDetailPresenter: TodoDetailPresenterInput, TodoDetailInteractorOutput {
    // MARK: - Dependencies
    weak var viewController: TodoDetailViewInput?
    var interactor: TodoDetailInteractorInput?
    var router: TodoDetailRouterInput?
    
    // MARK: - Properties
    private var todo: Todo?
    
    init(interactor: TodoDetailInteractorInput, todo: Todo?) {
        self.interactor = interactor
        self.todo = todo
    }
    
    // MARK: - TodoDetailPresenterInput
    func viewDidLoad() {
        if let existingTodo = todo {
            viewController?.todoLoaded(existingTodo)
        } else {
            let today = Date()
            let emptyTodo = Todo(
                id: 0,
                title: "",
                description: "",
                dateOfCreation: today,
                isCompleted: false
            )
            self.todo = emptyTodo
            viewController?.todoLoaded(emptyTodo)
        }
    }
    
    func buttonBackPressed(save savedTodo: Todo?) {
        if let savedTodo {
            interactor?.saveTodo(todo: savedTodo)
        }
        router?.navigateBack()
    }
}
