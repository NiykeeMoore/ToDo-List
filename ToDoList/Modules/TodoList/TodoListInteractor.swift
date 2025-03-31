//
//  TodoInteractor.swift
//  ToDoList
//
//  Created by Niykee Moore on 29.03.2025.
//

import Foundation

protocol TodoInteractorInput {
    var presenter: TodoInteractorOutput? { get set }
    func fetchTodos()
    func toggleTodoComplition(at index: Int)
    func deleteTodo(at index: Int)
}

protocol TodoInteractorOutput: AnyObject {
    func didFetchTodos(todos: [Todo])
    func didFailToFetchTodos(error: Error)
    func didUpdateTodo(at index: Int, with todo: Todo)
    func didDeleteTodo(at index: Int)
}

final class TodoListInteractor: TodoInteractorInput {
    // MARK: - Dependencies
    weak var presenter: TodoInteractorOutput?
    private let todosLoader: TodosLoading
    
    // MARK: - Properties
    private var todos: [Todo] = []
    private let dataQueue = DispatchQueue(label: "background.queue.for.data.update", qos: .userInitiated)

    // MARK: - Initialization
    init(todosLoader: TodosLoading) {
        self.todosLoader = todosLoader
    }
    
    //MARK: - TodoInteractorInput
    func fetchTodos() {
        todosLoader.load { [weak self] result in
            guard let self else { return }
            
            self.dataQueue.async {
                  let processedResult: Result<[Todo], Error>
                  switch result {
                  case .success(let fetchedTodos):
                      self.todos = fetchedTodos
                      processedResult = .success(self.todos)
                  case .failure(let error):
                      processedResult = .failure(error)
                  }

                  DispatchQueue.main.async {
                      switch processedResult {
                      case .success(let todosToPresent):
                          self.presenter?.didFetchTodos(todos: todosToPresent)
                      case .failure(let error):
                          self.presenter?.didFailToFetchTodos(error: error)
                      }
                  }
            }
        }
    }
    
    func toggleTodoComplition(at index: Int) {
        dataQueue.async { [weak self] in
            guard let self,
                  self.todos.indices.contains(index) else { return }

            let updatedTask = self.todos[index].withUpdatedComplition(isCompleted: !self.todos[index].isCompleted)
            self.todos[index] = updatedTask

            DispatchQueue.main.async {
                self.presenter?.didUpdateTodo(at: index, with: updatedTask)
            }
        }
    }
    
    func deleteTodo(at index: Int) {
        dataQueue.async { [weak self] in
            guard let self,
                  self.todos.indices.contains(index) else { return }

            self.todos.remove(at: index)

            DispatchQueue.main.async {
                self.presenter?.didDeleteTodo(at: index)
            }
        }
    }
}
