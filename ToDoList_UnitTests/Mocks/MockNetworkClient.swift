//
//  MockNetworkClient.swift
//  ToDoListTests
//
//  Created by Niykee Moore on 31.03.2025.
//

import XCTest
@testable import ToDoList

final class MockNetworkClient: NetworkRouting {
    var fetchCalledWithURL: URL?
    var fetchHandlerResult: Result<Data, Error>?

    var fetchExpectation: XCTestExpectation?

    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void) {
        fetchCalledWithURL = url

        if let result = fetchHandlerResult {
            // Имитируем асинхронность сети
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
                handler(result)
                self.fetchExpectation?.fulfill()
            }
        } else {
            fatalError("fetchHandlerResult не установлен в MockNetworkClient")
        }
    }
}
