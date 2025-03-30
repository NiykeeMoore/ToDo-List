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
    func toDomain(description: String, dateOfCreation: String) -> Todo {
        return Todo(
            id: id,
            title: todo,
            description: description,
            dateofCreation: dateOfCreation,
            isCompleted: completed
        )
    }
}
