//
//  TodoListRouter.swift
//  ToDoEM
//
//  Created by Nurseit Seitov on 16.09.2025.
//

import Foundation
import UIKit
import CoreData

final class TodoListRouter: TodoListRouterProtocol {
    static func createModule() -> UIViewController {
        let view = TodoListViewController()
        let presenter = TodoListPresenter()
        let interactor = TodoListInteractor()
        let router = TodoListRouter()

        view.presenter = presenter

        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router

        interactor.output = presenter

        return UINavigationController(rootViewController: view)
    }

    func navigateToAddTask(from view: TodoListViewProtocol) {
        guard let fromVC = view as? UIViewController else { return }
        let details = TodoDetailsViewController()
        details.onSave = {
            // обновим список после сохранения
            if let v = fromVC as? TodoListViewController {
                v.presenter?.viewDidLoad()
            }
        }
        let nav = UINavigationController(rootViewController: details)
        fromVC.present(nav, animated: true)
    }
    func presentShare(id: Int64, from view: TodoListViewProtocol) {
        guard let vc = view as? UIViewController else { return }

        let ctx = CoreDataStack.shared.viewContext
        let req: NSFetchRequest<Task> = Task.fetchRequest()
        req.predicate = NSPredicate(format: "id == %d", id)

        if let task = try? ctx.fetch(req).first {
            let text = "\(task.title)\n\n\(task.taskDescription ?? "")"
            let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
            vc.present(activityVC, animated: true)
        }
    }


    func navigateToEditTask(with id: Int64, from view: TodoListViewProtocol) {
        guard let fromVC = view as? UIViewController else { return }
        let details = TodoDetailsViewController()
        details.taskId = id
        details.onSave = {
            if let v = fromVC as? TodoListViewController {
                v.presenter?.viewDidLoad()
            }
        }
        let nav = UINavigationController(rootViewController: details)
        fromVC.present(nav, animated: true)
    }
}
