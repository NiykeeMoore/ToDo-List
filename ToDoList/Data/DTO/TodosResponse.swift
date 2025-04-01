//
//  TodosResponse.swift
//  ToDoList
//
//  Created by Niykee Moore on 29.03.2025.
//

import Foundation

struct TodosResponse: Decodable {
    let todos: [TodoItemDTO]
}
