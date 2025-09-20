//
//  TodoListContracts.swift
//  ToDoEM
//
//  Created by Nurseit Seitov on 16.09.2025.
//

import Foundation

protocol TodoListViewProtocol: AnyObject {
    func showTasks(_ tasks: [TodoItemViewModel])
    func showError(_ message: String)
}

protocol TodoListPresenterProtocol: AnyObject {
    func viewDidLoad()
    func didSelectTask(id: Int64)
    func didToggleComplete(id: Int64, completed: Bool)
    func didTapAdd()
    func didTapShare(id: Int64)
    func didTapDelete(id: Int64)
    func search(text: String)

}

protocol TodoListInteractorInput: AnyObject {
    func fetchTasks()
    func toggleTaskComplete(id: Int64, completed: Bool)
    func fetchTasks(matching text: String)
    func deleteTask(id: Int64)
}

protocol TodoListInteractorOutput: AnyObject {
    func didFetchTasks(_ tasks: [TodoItemViewModel])
    func didFail(with error: Error)
}

protocol TodoListRouterProtocol: AnyObject {
    func navigateToAddTask(from view: TodoListViewProtocol)
    func navigateToEditTask(with id: Int64, from view: TodoListViewProtocol)
    func presentShare(id: Int64, from view: TodoListViewProtocol)
}

