//
//  TodoEntity+CoreDataProperties.swift
//  ToDoList
//
//  Created by Niykee Moore on 31.03.2025.
//
//

import Foundation
import CoreData


extension TodoEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TodoEntity> {
        return NSFetchRequest<TodoEntity>(entityName: "TodoEntity")
    }

    @NSManaged public var id: String?
    @NSManaged public var title: String?
    @NSManaged public var todoDescription: String?
    @NSManaged public var dateOfCreation: Date?
    @NSManaged public var isCompleted: Bool

}

extension TodoEntity : Identifiable {

}
