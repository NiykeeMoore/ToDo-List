//
//  TodoDetailPresenter.swift
//  ToDoList
//
//  Created by Niykee Moore on 30.03.2025.
//

import UIKit

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
            let emptyTodo = Todo(
                id: 0,
                title: "",
                description: "",
                dateOfCreation: customTodayDate(),
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
    
    private func customTodayDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        return dateFormatter.string(from: Date())
    }
}
