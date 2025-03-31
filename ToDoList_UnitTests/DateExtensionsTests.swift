//
//  DateExtensionsTests.swift
//  ToDoListTests
//
//  Created by Niykee Moore on 31.03.2025.
//

import XCTest
@testable import ToDoList

final class DateExtensionsTests: XCTestCase {
    
    private func createDate(year: Int, month: Int, day: Int, hour: Int = 12, minute: Int = 0, second: Int = 0) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        components.second = second
        
        let calendar = Calendar(identifier: .gregorian)
        return calendar.date(from: components)!
    }
    
    func test_formattedDisplayString_formatsDateCorrectly_forRussianLocale() {
        // Arrange
        let date1 = createDate(year: 2024, month: 1, day: 1)   // 1 января 2024
        let date2 = createDate(year: 2025, month: 12, day: 31) // 31 декабря 2025
        let date3 = createDate(year: 2023, month: 3, day: 8)   // 8 марта 2023
        let dateToday = createDate(year: 2025, month: 3, day: 31)
        
        let expectedString1 = "01/01/2024"
        let expectedString2 = "31/12/2025"
        let expectedString3 = "08/03/2023"
        let expectedStringToday = "31/03/2025"
        
        // Act
        let actualString1 = date1.formattedDisplayString
        let actualString2 = date2.formattedDisplayString
        let actualString3 = date3.formattedDisplayString
        let actualStringToday = dateToday.formattedDisplayString
        
        // Assert
        XCTAssertEqual(actualString1, expectedString1, "Неправильный формат для \(date1)")
        XCTAssertEqual(actualString2, expectedString2, "Неправильный формат для \(date2)")
        XCTAssertEqual(actualString3, expectedString3, "Неправильный формат для \(date3)")
        XCTAssertEqual(actualStringToday, expectedStringToday, "Неправильный формат для \(dateToday)")
    }
}
