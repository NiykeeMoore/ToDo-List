//
//  TodoTests.swift
//  ToDoListTests
//
//  Created by Niykee Moore on 31.03.2025.
//

import XCTest
@testable import ToDoList

final class TodoTests: XCTestCase {
    let baseDate = Date()
    lazy var baseTodo = Todo(
        id: "base-123",
        title: "Base Title",
        description: "Base Description",
        dateOfCreation: baseDate,
        isCompleted: false
    )
    
    func test_withUpdatedComplition_returnsNewInstanceWithUpdatedFlag_andOtherPropertiesUnchanged() {
        // Arrange
        let expectedCompletion = true
        
        // Act
        let updatedTodo = baseTodo.withUpdatedComplition(isCompleted: expectedCompletion)
        
        // Assert
        XCTAssertEqual(updatedTodo.isCompleted, expectedCompletion, "isCompleted должен обновиться")
        XCTAssertEqual(updatedTodo.id, baseTodo.id, "ID не должен меняться")
        XCTAssertEqual(updatedTodo.title, baseTodo.title, "Title не должен меняться")
        XCTAssertEqual(updatedTodo.description, baseTodo.description, "Description не должен меняться")
        XCTAssertEqual(updatedTodo.dateOfCreation, baseTodo.dateOfCreation, "DateOfCreation не должен меняться")
    }
    
    func test_withUpdatedTitle_returnsNewInstanceWithUpdatedTitle_andOtherPropertiesUnchanged() {
        // Arrange
        let expectedTitle = "Updated Title"
        
        // Act
        let updatedTodo = baseTodo.withUpdatedTitle(title: expectedTitle)
        
        // Assert
        XCTAssertEqual(updatedTodo.title, expectedTitle, "Title должен обновиться")
        XCTAssertEqual(updatedTodo.id, baseTodo.id, "ID не должен меняться")
        XCTAssertEqual(updatedTodo.isCompleted, baseTodo.isCompleted, "isCompleted не должен меняться")
        XCTAssertEqual(updatedTodo.description, baseTodo.description, "Description не должен меняться")
        XCTAssertEqual(updatedTodo.dateOfCreation, baseTodo.dateOfCreation, "DateOfCreation не должен меняться")
    }
    
    func test_withUpdatedDescription_returnsNewInstanceWithUpdatedDescription_andOtherPropertiesUnchanged() {
        // Arrange
        let expectedDescription = "Updated Description"
        
        // Act
        let updatedTodo = baseTodo.withUpdatedDescription(description: expectedDescription)
        
        // Assert
        XCTAssertEqual(updatedTodo.description, expectedDescription, "Description должен обновиться")
        XCTAssertEqual(updatedTodo.id, baseTodo.id, "ID не должен меняться")
        XCTAssertEqual(updatedTodo.title, baseTodo.title, "Title не должен меняться")
        XCTAssertEqual(updatedTodo.isCompleted, baseTodo.isCompleted, "isCompleted не должен меняться")
        XCTAssertEqual(updatedTodo.dateOfCreation, baseTodo.dateOfCreation, "DateOfCreation не должен меняться")
    }
}
