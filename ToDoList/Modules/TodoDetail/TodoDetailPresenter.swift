//
//  TodoDetailPresenter.swift
//  ToDoList
//
//  Created by Niykee Moore on 30.03.2025.
//

import Foundation

protocol TodoDetailPresenterInput: AnyObject {
    func viewDidLoad()
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
        viewController?.todoLoaded(todo)
    }
}
