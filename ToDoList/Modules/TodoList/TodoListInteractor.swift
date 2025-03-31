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
    private let todoStore: TodoStoring
    
    // MARK: - Properties
    private var todos: [Todo] = []
    private let dataQueue = DispatchQueue(label: "background.queue.for.data.update", qos: .userInitiated)
    private let didLoadInitialDataKey = "didLoadInitialDataKey"
    
    // MARK: - Initialization
    init(todosLoader: TodosLoading, todoStore: TodoStoring) {
        self.todosLoader = todosLoader
        self.todoStore = todoStore
    }
    
    //MARK: - TodoInteractorInput
    func fetchTodos() {
        dataQueue.async { [weak self] in
            guard let self else { return }
            
            self.todoStore.fetchTodos { result in
                switch result {
                case .success(let storedTodos):
                    print("Interactor: Загружено \(storedTodos.count) todos из core data.")
                    let didLoadInitial = UserDefaults.standard.bool(forKey: self.didLoadInitialDataKey)
                    
                    if storedTodos.isEmpty && !didLoadInitial {
                        print("Interactor: Массив пустой и первая загрузка. Берем todos из api...")
                        self.loadFromNetworkAndSave()
                    } else {
                        print("Interactor: Берем todos из coredata")
                        self.updateLocalTodos(with: storedTodos)
                        self.presenter?.didFetchTodos(todos: storedTodos)
                    }
                    
                case .failure(let error):
                    print("Interactor: Ошибка загрузки из coredata. Ошибка: \(error)")
                    self.presenter?.didFailToFetchTodos(error: error)
                }
            }
        }
    }

    func toggleTodoComplition(at index: Int) {
        dataQueue.async { [weak self] in
            guard
                let self,
            self.todos.indices.contains(index) else { return }
            
            let originalTodo = self.todos[index]
            let updatedTodo = originalTodo.withUpdatedComplition(isCompleted: !originalTodo.isCompleted)
            print("Interactor: Устанавлиавем тогл комплишен todo id \(updatedTodo.id) на=\(updatedTodo.isCompleted)")
            
            self.todoStore.saveTodo(updatedTodo) { result in
                switch result {
                case .success:
                    print("Interactor: Тогл комплишен установлен todo id \(updatedTodo.id)")
                    self.dataQueue.async {
                        if self.todos.indices.contains(index) {
                            self.todos[index] = updatedTodo
                        }
                        DispatchQueue.main.async {
                            self.presenter?.didUpdateTodo(at: index, with: updatedTodo)
                        }
                    }
                    
                case .failure(let error):
                    print("Interactor: Ошибка тогл комплишена todo id \(updatedTodo.id). Ошибка: \(error)")
                    
                    self.presenter?.didFailToFetchTodos(error: error)
                }
            }
        }
    }
    
    func deleteTodo(at index: Int) {
        dataQueue.async { [weak self] in
            guard
                let self,
                self.todos.indices.contains(index) else { return }
            
            let todoIdToDelete = self.todos[index].id
            print("Interactor: Удаление todo id \(todoIdToDelete)")
            
            self.todoStore.deleteTodo(id: todoIdToDelete) { result in
                
                switch result {
                case .success:
                    print("Interactor: Удалили id \(todoIdToDelete)")
                    self.dataQueue.async {
                        if self.todos.indices.contains(index) && self.todos[index].id == todoIdToDelete {
                            self.todos.remove(at: index)
                        }
                        DispatchQueue.main.async {
                            self.presenter?.didDeleteTodo(at: index)
                        }
                    }
                    
                case .failure(let error):
                    print("Interactor: Не удалили todo id \(todoIdToDelete). Ошибка: \(error)")
                    self.presenter?.didFailToFetchTodos(error: error)
                }
            }
        }
    }
    
    //MARK: - Helper methods
    private func loadFromNetworkAndSave() {
        todosLoader.load { [weak self] result in
            guard let self else { return }
            self.dataQueue.async {
                switch result {
                case .success(let networkTodos):
                    print("Interactor: загружено \(networkTodos.count) todos из API.")
                    let group = DispatchGroup()
                    var saveError: Error? = nil
                    
                    for todo in networkTodos {
                        group.enter()
                        self.todoStore.saveTodo(todo) { result in
                            if case .failure(let error) = result {
                                if saveError == nil {
                                    saveError = error
                                }
                                print("Interactor: сохранение сетевого todo (id: \(todo.id)). Ошибка: \(error)")
                            } else {
                                print("Interactor: сохранен сетевой todo (id: \(todo.id)).")
                            }
                            group.leave()
                        }
                    }
                    
                    
                    group.notify(queue: self.dataQueue) {
                        if let error = saveError {
                            print("Interactor: Ошибка загрузки сетевых todo")
                            DispatchQueue.main.async {
                                self.presenter?.didFailToFetchTodos(error: error)
                            }
                        } else {
                            print("Interactor: Todos получены из api. Поставили флаг didLoadInitialDataKey")
                            UserDefaults.standard.set(true, forKey: self.didLoadInitialDataKey)
                            DispatchQueue.main.async {
                                self.fetchTodos() // осознанная рекурсия - но данные уже есть
                            }
                        }
                    }
                    
                case .failure(let error):
                    print("Interactor: Не получилось получить todos по API. Ошибка: \(error)")
                    DispatchQueue.main.async {
                        self.presenter?.didFailToFetchTodos(error: error)
                    }
                }
            }
        }
    }
    
    private func updateLocalTodos(with newTodos: [Todo]) {
        dataQueue.async {
            self.todos = newTodos
        }
    }
}
