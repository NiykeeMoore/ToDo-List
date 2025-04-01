//
//  TodoItemDTO.swift
//  ToDoList
//
//  Created by Niykee Moore on 29.03.2025.
//

import Foundation

struct TodoItemDTO: Decodable {
    let id: Int
    let todo: String
    let completed: Bool
    let userId: Int
}

extension TodoItemDTO {
    func toDomain(description: String, dateOfCreation: Date) -> Todo {
        return Todo(
            id: String(self.id),
            title: todo,
            description: description,
            dateOfCreation: dateOfCreation,
            isCompleted: completed
        )
    }
}
