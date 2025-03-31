//
//  Date+Extensions.swift
//  ToDoList
//
//  Created by Niykee Moore on 31.03.2025.
//

import Foundation

extension Date {
    private static let displayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()

    var formattedDisplayString: String {
        return Date.displayFormatter.string(from: self)
    }
}
