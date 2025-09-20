//
//  TodoListInteractorTests.swift
//  ToDoEMTests
//
//  Created by Nurseit Seitov on 20.09.2025.
//

import Foundation
import CoreData
@testable import ToDoEM

final class TodoListInteractorForTests: TodoListInteractorInput {
    weak var output: TodoListInteractorOutput?
    private let stack: CoreDataStackProtocol

    init(stack: CoreDataStackProtocol) {
        self.stack = stack
    }

    func fetchTasks() {
        let ctx = stack.viewContext
        let req: NSFetchRequest<Task> = Task.fetchRequest()
        req.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        let results = (try? ctx.fetch(req)) ?? []
        let vms = mapTasksToViewModels(results)
        output?.didFetchTasks(vms)
    }

    func toggleTaskComplete(id: Int64, completed: Bool) {
        let ctx = stack.viewContext
        let req: NSFetchRequest<Task> = Task.fetchRequest()
        req.predicate = NSPredicate(format: "id == %d", id)
        if let task = try? ctx.fetch(req).first {
            task.isCompleted = completed
            try? ctx.save()
        }
        fetchTasks()
    }

    func deleteTask(id: Int64) {
        let ctx = stack.viewContext
        let req: NSFetchRequest<Task> = Task.fetchRequest()
        req.predicate = NSPredicate(format: "id == %d", id)
        if let task = try? ctx.fetch(req).first {
            ctx.delete(task)
            try? ctx.save()
        }
        fetchTasks()
    }

    func fetchTasks(matching text: String) {
        let ctx = stack.viewContext
        let req: NSFetchRequest<Task> = Task.fetchRequest()
        req.predicate = NSPredicate(format: "title CONTAINS[cd] %@ OR taskDescription CONTAINS[cd] %@", text, text)
        req.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        let results = (try? ctx.fetch(req)) ?? []
        let vms = mapTasksToViewModels(results)
        output?.didFetchTasks(vms)
    }

    // MARK: - Helper
    private func mapTasksToViewModels(_ tasks: [Task]) -> [TodoItemViewModel] {
        tasks.map {
            TodoItemViewModel(
                id: $0.id,
                title: $0.title,
                description: $0.taskDescription ?? "",
                isCompleted: $0.isCompleted,
                dateString: DateFormatter.localizedString(from: $0.createdAt,
                                                          dateStyle: .short,
                                                          timeStyle: .none)
            )
        }
    }
}
