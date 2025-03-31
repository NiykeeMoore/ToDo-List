//
//  TodoInteractor.swift
//  ToDoList
//
//  Created by Niykee Moore on 29.03.2025.
//

import Foundation

protocol TodoInteractorInput {
    func fetchTodos()
    func toggleTodoComplition(at index: Int)
    func shareTodo(todo: Todo)
    func deleteTodo(at index: Int)
}

protocol TodoInteractorOutput: AnyObject {
    func didFetchTodos(todos: [Todo])
    func didFailToFetchTodos(error: Error)
    func prepareToShare(todo: Todo)
}

final class TodoListInteractor: TodoInteractorInput {
    // MARK: - Dependencies
    weak var presenter: TodoInteractorOutput?
    private let todosLoader: TodosLoader
    
    // MARK: - Properties
    private var todos: [Todo] = []
    private let dataQueue = DispatchQueue(label: "background.queue.for.data.update", qos: .userInitiated)

    // MARK: - Initialization
    init(todosLoader: TodosLoader) {
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
                self.presenter?.didFetchTodos(todos: self.todos)
            }
        }
    }

    func shareTodo(todo: Todo) {
          DispatchQueue.main.async { [weak self] in
              guard let self else { return }
             self.presenter?.prepareToShare(todo: todo)
         }
     }
    
    func deleteTodo(at index: Int) {
        dataQueue.async { [weak self] in
            guard let self,
                  self.todos.indices.contains(index) else { return }

            self.todos.remove(at: index)

            DispatchQueue.main.async {
                self.presenter?.didFetchTodos(todos: self.todos)
            }
        }
    }
}
