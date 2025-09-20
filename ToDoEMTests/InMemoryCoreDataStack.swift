//
//  InMemoryCoreDataStack.swift.swift
//  ToDoEMTests
//
//  Created by Nurseit Seitov on 20.09.2025.
//

import Foundation
import CoreData
@testable import ToDoEM

final class InMemoryCoreDataStack: CoreDataStackProtocol {
    private let container: NSPersistentContainer

    init() {
        // ищем модель внутри тестового бандла
        let bundle = Bundle(for: InMemoryCoreDataStack.self)
        guard let modelURL = bundle.url(forResource: "ToDoEM", withExtension: "momd") else {
            fatalError("❌ Could not find ToDoEM.momd in test bundle")
        }
        guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("❌ Could not load model from: \(modelURL)")
        }

        container = NSPersistentContainer(name: "ToDoEM", managedObjectModel: model)
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]

        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("❌ InMemory store error: \(error)")
            }
        }
    }

    var viewContext: NSManagedObjectContext { container.viewContext }

    func newBackgroundContext() -> NSManagedObjectContext {
        container.newBackgroundContext()
    }

    func saveViewContext() {
        if viewContext.hasChanges {
            try? viewContext.save()
        }
    }
}
