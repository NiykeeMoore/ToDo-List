//
//  TodoDetailPresenter.swift
//  ToDoList
//
//  Created by Niykee Moore on 30.03.2025.
//

import Foundation

protocol TodoDetailPresenterInput: AnyObject {
    var viewController: TodoDetailViewInput? { get set }
    var router: TodoDetailRouterInput? { get set }
    var interactor: TodoDetailInteractorInput? { get set }
    func viewDidLoad()
    func buttonBackPressed(currentTitle: String?, currentDescription: String?)
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
                id: UUID().uuidString,
                title: "",
                description: "",
                dateOfCreation: today,
                isCompleted: false
            )
            self.todo = emptyTodo
            viewController?.todoLoaded(emptyTodo)
        }
    }
    
    func buttonBackPressed(currentTitle: String?, currentDescription: String?) {
        let title = currentTitle?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let description = currentDescription ?? ""
        guard let originalTodo = self.todo else {
            router?.navigateBack()
            return
        }
        
        let isNewTaskAndEmpty = (originalTodo.title.isEmpty && originalTodo.description.isEmpty && title.isEmpty)
        
        let hasChanges = originalTodo.title != title || originalTodo.description != description
        let shouldSave = hasChanges && !isNewTaskAndEmpty  // не сохраняем пустую todo
        
        if shouldSave {
            let todoToSave = Todo(
                id: originalTodo.id,
                title: title,
                description: description,
                dateOfCreation: originalTodo.dateOfCreation,
                isCompleted: originalTodo.isCompleted
            )
            interactor?.saveTodo(todo: todoToSave)
        }
        router?.navigateBack()
    }
}
