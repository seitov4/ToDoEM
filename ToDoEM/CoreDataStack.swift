//
//  CoreDataStack.swift
//  ToDoEM
//
//  Created by Nurseit Seitov on 16.09.2025.
//

// CoreDataStack.swift
import CoreData

final class CoreDataStack: CoreDataStackProtocol {
    static let shared = CoreDataStack()

    let container: NSPersistentContainer

    // default обычный файл-store, но для тестов можно создать CoreDataStack(inMemory: true)
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "ToDoEM") // <- проверь имя .xcdatamodeld
        if inMemory {
            let desc = NSPersistentStoreDescription()
            desc.type = NSInMemoryStoreType
            container.persistentStoreDescriptions = [desc]
        }
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Unresolved Core Data error: \(error)")
            }
        }
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    var viewContext: NSManagedObjectContext { container.viewContext }

    func newBackgroundContext() -> NSManagedObjectContext {
        container.newBackgroundContext()
    }

    func saveViewContext() {
        let ctx = container.viewContext
        if ctx.hasChanges {
            do { try ctx.save() } catch {
                print("CoreData save error:", error)
            }
        }
    }
}
