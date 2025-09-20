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

    // MARK: - Lifecycle
    func viewDidLoad() {
        interactor?.fetchTasks()
    }

    // MARK: - User actions
    func didSelectTask(id: Int64) {
        guard let view = view else { return }
        router?.navigateToEditTask(with: id, from: view)
    }

    func didToggleComplete(id: Int64, completed: Bool) {
        interactor?.toggleTaskComplete(id: id, completed: completed)
    }

    func didTapAdd() {
        guard let view = view else { return }
        router?.navigateToAddTask(from: view)
    }

    func didTapDelete(id: Int64) {
        interactor?.deleteTask(id: id)
    }

    func didTapShare(id: Int64) {
        guard let view = view else { return }
        router?.presentShare(id: id, from: view)
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

// MARK: - TodoListInteractorOutput
extension TodoListPresenter: TodoListInteractorOutput {
    func didFetchTasks(_ tasks: [TodoItemViewModel]) {
        view?.showTasks(tasks)
    }

    func didFail(with error: Error) {
        view?.showError(error.localizedDescription)
    }
}
