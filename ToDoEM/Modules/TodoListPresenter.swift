//
//  TodoListPresenter.swift
//  ToDoEM
//
//  Created by Nurseit Seitov on 16.09.2025.
//

import Foundation
final class TodoListPresenter: TodoListPresenterProtocol {
    weak var view: TodoListViewProtocol?
    var interactor: TodoListInteractorInput?
    var router: TodoListRouterProtocol?

    func viewDidLoad() {
        interactor?.fetchTasks()
    }

    func didSelectTask(id: Int64) {
        router?.navigateToEditTask(with: id, from: view!)
    }

    func didToggleComplete(id: Int64, completed: Bool) {
        interactor?.toggleTaskComplete(id: id, completed: completed)
    }

    func didTapAdd() {
        router?.navigateToAddTask(from: view!)
    }

    func didTapDelete(id: Int64) {
        interactor?.deleteTask(id: id)
    }
    
    func search(text: String) {
        let query = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if query.isEmpty {
            interactor?.fetchTasks()
        } else {
            interactor?.fetchTasks(matching: query)
        }
    }
    
}
extension TodoListPresenter: TodoListInteractorOutput {
    func didFetchTasks(_ tasks: [TodoItemViewModel]) {
        view?.showTasks(tasks)
    }

    func didFail(with error: Error) {
        view?.showError(error.localizedDescription)
    }
}

