//
//  TodosLoader.swift
//  ToDoList
//
//  Created by Niykee Moore on 29.03.2025.
//

import Foundation

protocol TodosLoading {
    func load(handler: @escaping (Result<[TodoItemDTO], Error>) -> Void)
}

struct TodosLoader: TodosLoading {
    // MARK: - Dependencies
    private let networkClient: NetworkRouting
    
    // MARK: - Properties
    private var dummyTodos: URL {
        guard let url = URL(string: "https://dummyjson.com/todos") else {
            preconditionFailure("Некорректный URL")
        }
        return url
    }
    
    // MARK: - Initialization
    init(networkClient: NetworkRouting) {
        self.networkClient = networkClient
    }
    
    // MARK: - TodosLoading
    func load(handler: @escaping (Result<[TodoItemDTO], any Error>) -> Void) {
        networkClient.fetch(url: dummyTodos) { result in
            switch result {
            case .success(let data):
                do {
                    let decoded = try JSONDecoder().decode(TodosResponse.self, from: data)
                    handler(.success(decoded.todos))
                } catch {
                    handler(.failure(error))
                }
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }
}
