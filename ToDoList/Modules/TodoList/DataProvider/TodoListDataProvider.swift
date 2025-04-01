//
//  TodoListDataProvider.swift
//  ToDoList
//
//  Created by Niykee Moore on 01.04.2025.
//

import Foundation
import CoreData

protocol DataProviderDelegate: AnyObject {
    func dataProviderWillChangeContent()
    func dataProviderDidChangeContent()
    func dataProviderDidInsertObject(at indexPath: IndexPath)
    func dataProviderDidDeleteObject(at indexPath: IndexPath)
    func dataProviderDidUpdateObject(at indexPath: IndexPath)
    func dataProviderDidMoveObject(from oldIndexPath: IndexPath, to newIndexPath: IndexPath)
}

// Протокол для доступа к данным FRC и управления им
protocol TodoListDataProviderProtocol: AnyObject {
    var delegate: DataProviderDelegate? { get set }
    
    func numberOfSections() -> Int
    func numberOfRows(in section: Int) -> Int
    func object(at indexPath: IndexPath) -> TodoEntity?
    
    func performFetch() throws
    func updatePredicate(for searchText: String)
}

final class FetchedResultsDataProvider: NSObject, TodoListDataProviderProtocol, NSFetchedResultsControllerDelegate {
    
    private let context: NSManagedObjectContext
    private var currentSearchText: String = ""
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TodoEntity> = {
        let fetchRequest: NSFetchRequest<TodoEntity> = TodoEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \TodoEntity.dateOfCreation, ascending: false)]
        fetchRequest.predicate = self.createPredicate(for: self.currentSearchText)
        
        let frc = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        frc.delegate = self
        return frc
    }()
    
    weak var delegate: DataProviderDelegate?
    
    // MARK: - Initialization
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
    }
    
    // MARK: - TodoListDataProviderProtocol
    
    func numberOfSections() -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func numberOfRows(in section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func object(at indexPath: IndexPath) -> TodoEntity? {
        guard indexPath.section < (fetchedResultsController.sections?.count ?? 0),
              indexPath.row < (fetchedResultsController.sections?[indexPath.section].numberOfObjects ?? 0) else { return nil }
        return fetchedResultsController.object(at: indexPath)
    }
    
    func performFetch() throws {
        try fetchedResultsController.performFetch()
    }
    
    func updatePredicate(for searchText: String) {
        guard searchText != currentSearchText else { return }
        
        currentSearchText = searchText
        fetchedResultsController.fetchRequest.predicate = createPredicate(for: searchText)
        
        do {
            try performFetch()
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.delegate?.dataProviderDidChangeContent()
            }
        } catch {
            print("DataProvider Ошибка загрузки предиката после фетча: \(error)")
        }
    }
    
    private func createPredicate(for searchText: String) -> NSPredicate? {
        if searchText.isEmpty {
            return nil
        } else {
            return NSPredicate(format: "title CONTAINS[cd] %@ OR todoDescription CONTAINS[cd] %@", searchText, searchText)
        }
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.dataProviderWillChangeContent()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let newIndexPath = newIndexPath {
                delegate?.dataProviderDidInsertObject(at: newIndexPath)
            }
        case .delete:
            if let indexPath = indexPath {
                delegate?.dataProviderDidDeleteObject(at: indexPath)
            }
        case .update:
            if let indexPath = indexPath {
                delegate?.dataProviderDidUpdateObject(at: indexPath)
            }
        case .move:
            if let indexPath = indexPath, let newIndexPath = newIndexPath {
                delegate?.dataProviderDidMoveObject(from: indexPath, to: newIndexPath)
            }
        @unknown default:
            print("DataProvider: NSFetchedResultsChangeType: \(type)")
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.dataProviderDidChangeContent()
    }
}
