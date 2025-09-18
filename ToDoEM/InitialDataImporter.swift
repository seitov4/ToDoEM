//
//  InitialDataImporter.swift
//  ToDoEM
//
//  Created by Nurseit Seitov on 16.09.2025.
//

import Foundation
import Foundation
import CoreData

final class InitialDataImporter {
    private let defaultsKey = "hasImportedInitialTodos"

    func importIfNeeded(completion: @escaping (Result<Void, Error>) -> Void) {
        let already = UserDefaults.standard.bool(forKey: defaultsKey)
        if already {
            completion(.success(()))
            return
        }

        APIService.shared.fetchTodos { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let items):
                let bg = CoreDataStack.shared.newBackgroundContext()
                bg.perform {
                    for it in items {
                        let fetchReq: NSFetchRequest<Task> = Task.fetchRequest()
                        fetchReq.predicate = NSPredicate(format: "id == %d", it.id)
                        if let existing = (try? bg.fetch(fetchReq))?.first {
                            // optional: update fields if changed
                            existing.title = it.todo
                            existing.isCompleted = it.completed
                            continue
                        }
                        let t = Task(context: bg)
                        t.id = Int64(it.id)
                        t.title = it.todo
                        t.taskDescription = ""
                        t.isCompleted = it.completed
                        t.createdAt = Date()
                    }
                    do {
                        try bg.save()
                        UserDefaults.standard.set(true, forKey: self.defaultsKey)
                        completion(.success(()))
                    } catch {
                        completion(.failure(error))
                    }
                }
            }
        }

    }
}
