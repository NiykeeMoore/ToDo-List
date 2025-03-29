//
//  TodoItemDTO.swift
//  ToDoList
//
//  Created by Niykee Moore on 29.03.2025.
//

import Foundation

struct TodoItemDTO: Codable {
    let id: Int
    let todo: String
    let completed: Bool
    let userId: Int
}

extension TodoItemDTO {
    func toDomain() -> Todo {
        return Todo(
            id: id,
            title: todo,
            isCompleted: completed
        )
    }
}
