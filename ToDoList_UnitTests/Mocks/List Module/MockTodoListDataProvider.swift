//
//  MockTodoListDataProvider.swift
//  ToDoListTests
//
//  Created by Niykee Moore on 01.04.2025.
//

import XCTest
import CoreData
@testable import ToDoList

final class MockTodoListDataProvider: TodoListDataProviderProtocol {
    weak var delegate: DataProviderDelegate?
    
    var numberOfSectionsToReturn: Int = 1
    var numberOfRowsToReturn: Int = 0
    var objectToReturn: TodoEntity?
    var performFetchShouldThrowError: Error?
    var updatePredicateCalledWithText: String?
    
    var numberOfSectionsCalled = false
    var numberOfRowsInSectionCalled: Int?
    var objectAtIndexPathCalled: IndexPath?
    var performFetchCalled = false
    var updatePredicateCalled = false
    
    
    func numberOfSections() -> Int {
        numberOfSectionsCalled = true
        return numberOfSectionsToReturn
    }
    
    func numberOfRows(in section: Int) -> Int {
        numberOfRowsInSectionCalled = section
        return numberOfRowsToReturn
    }
    
    func object(at indexPath: IndexPath) -> TodoEntity? {
        objectAtIndexPathCalled = indexPath
        return objectToReturn
    }
    
    func performFetch() throws {
        performFetchCalled = true
        if let error = performFetchShouldThrowError {
            throw error
        }
    }
    
    func updatePredicate(for searchText: String) {
        updatePredicateCalled = true
        updatePredicateCalledWithText = searchText
    }
}
