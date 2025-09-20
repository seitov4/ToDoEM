//
//  TodoListInteractor.swift
//  ToDoEM
//
//  Created by Nurseit Seitov on 16.09.2025.
//

import Foundation
import CoreData

final class TodoListInteractor: TodoListInteractorInput {
    weak var output: TodoListInteractorOutput?

    private let coreDataStack: CoreDataStackProtocol

    init(coreDataStack: CoreDataStackProtocol = CoreDataStack.shared) {
        self.coreDataStack = coreDataStack
    }

    func fetchTasks() {
        let bg = coreDataStack.newBackgroundContext()
        bg.perform {
            let req: NSFetchRequest<Task> = Task.fetchRequest()
            req.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
            do {
                let results = try bg.fetch(req)
                let vms = results.map {
                    TodoItemViewModel(
                        id: $0.id,
                        title: $0.title ?? "",
                        description: $0.taskDescription ?? "",
                        isCompleted: $0.isCompleted,
                        dateString: Self.formatter.string(from: $0.createdAt)
                    )
                }
                DispatchQueue.main.async { self.output?.didFetchTasks(vms) }
            } catch {
                DispatchQueue.main.async { self.output?.didFail(with: error) }
            }
        }
    }

    func fetchTasks(matching text: String) {
        let bg = coreDataStack.newBackgroundContext()
        bg.perform {
            let req: NSFetchRequest<Task> = Task.fetchRequest()
            req.predicate = NSPredicate(format: "title CONTAINS[cd] %@ OR taskDescription CONTAINS[cd] %@", text, text)
            req.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
            do {
                let results = try bg.fetch(req)
                let vms = results.map {
                    TodoItemViewModel(
                        id: $0.id,
                        title: $0.title ?? "",
                        description: $0.taskDescription ?? "",
                        isCompleted: $0.isCompleted,
                        dateString: Self.formatter.string(from: $0.createdAt)
                    )
                }
                DispatchQueue.main.async { self.output?.didFetchTasks(vms) }
            } catch {
                DispatchQueue.main.async { self.output?.didFail(with: error) }
            }
        }
    }

    func toggleTaskComplete(id: Int64, completed: Bool) {
        let bg = coreDataStack.newBackgroundContext()
        bg.perform {
            let req: NSFetchRequest<Task> = Task.fetchRequest()
            req.predicate = NSPredicate(format: "id == %d", id)
            if let task = try? bg.fetch(req).first {
                task.isCompleted = completed
                try? bg.save()
                self.fetchTasks()
            }
        }
    }

    func deleteTask(id: Int64) {
        let bg = coreDataStack.newBackgroundContext()
        bg.perform {
            let req: NSFetchRequest<Task> = Task.fetchRequest()
            req.predicate = NSPredicate(format: "id == %d", id)
            if let task = try? bg.fetch(req).first {
                bg.delete(task)
                try? bg.save()
                self.fetchTasks()
            }
        }
    }

    // MARK: - Helpers
    private static let formatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "dd/MM/yy"
        return df
    }()
}
