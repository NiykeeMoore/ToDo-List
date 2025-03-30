//
//  Todo.swift
//  ToDoList
//
//  Created by Niykee Moore on 29.03.2025.
//

import Foundation

struct Todo {
    let id: Int
    let title: String
    let description: String
    let dateOfCreation: String
    let isCompleted: Bool
    
    func withUpdatedComplition(isCompleted: Bool) -> Self {
        return Todo(
            id: self.id,
            title: self.title,
            description: self.description,
            dateOfCreation: self.dateOfCreation,
            isCompleted: isCompleted)
    }
    
    func withUpdatedTitle(title: String) -> Self {
        return Todo(
            id: self.id,
            title: title,
            description: self.description,
            dateOfCreation: self.dateOfCreation,
            isCompleted: self.isCompleted)
    }
    
    func withUpdatedDescription(description: String) -> Self {
        return Todo(
            id: self.id,
            title: self.title,
            description: description,
            dateOfCreation: self.dateOfCreation,
            isCompleted: self.isCompleted)
    }
}
