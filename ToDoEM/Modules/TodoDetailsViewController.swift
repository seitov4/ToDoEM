//
//  TodoDetailsViewController.swift
//  ToDoEM
//
//  Created by Nurseit Seitov on 18.09.2025.
//

import Foundation
import UIKit
import CoreData

final class TodoDetailsViewController: UIViewController {

    var taskId: Int64?
    var onSave: (() -> Void)?

    private let titleField: UITextField = {
        let tf = UITextField()
        tf.font = .systemFont(ofSize: 28, weight: .bold)
        tf.textColor = .white
        tf.placeholder = "Заголовок"
        tf.borderStyle = .none
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    private let dateLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13)
        l.textColor = .gray
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let textView: UITextView = {
        let tv = UITextView()
        tv.font = .systemFont(ofSize: 17)
        tv.backgroundColor = .clear
        tv.textColor = .white
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupNav()
        layout()
        if let id = taskId { loadTask(id: id) } else { titleField.becomeFirstResponder() }
    }

    private func setupNav() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Назад", style: .plain, target: self, action: #selector(cancelTapped))
        navigationItem.leftBarButtonItem?.tintColor = .systemYellow
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Готово", style: .done, target: self, action: #selector(saveTapped))
        navigationItem.rightBarButtonItem?.tintColor = .systemYellow
    }

    private func layout() {
        view.addSubview(titleField)
        view.addSubview(dateLabel)
        view.addSubview(textView)

        NSLayoutConstraint.activate([
            titleField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            dateLabel.topAnchor.constraint(equalTo: titleField.bottomAnchor, constant: 6),
            dateLabel.leadingAnchor.constraint(equalTo: titleField.leadingAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: titleField.trailingAnchor),

            textView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 12),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            textView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func loadTask(id: Int64) {
        let ctx = CoreDataStack.shared.viewContext
        let req: NSFetchRequest<Task> = Task.fetchRequest()
        req.predicate = NSPredicate(format: "id == %d", id)
        if let task = try? ctx.fetch(req).first {
            titleField.text = task.title
            textView.text = task.taskDescription
            let df = DateFormatter(); df.dateStyle = .medium
            dateLabel.text = df.string(from: task.createdAt)
        }
    }

    @objc private func cancelTapped() { dismiss(animated: true) }

    @objc private func saveTapped() {
        let titleText = titleField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let bodyText = textView.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if titleText.isEmpty && bodyText.isEmpty {
            dismiss(animated: true); return
        }

        let bg = CoreDataStack.shared.newBackgroundContext()
        bg.perform {
            if let id = self.taskId {
                let req: NSFetchRequest<Task> = Task.fetchRequest()
                req.predicate = NSPredicate(format: "id == %d", id)
                if let found = try? bg.fetch(req).first {
                    found.title = titleText.isEmpty ? (found.title) : titleText
                    found.taskDescription = bodyText
                    found.createdAt = Date()
                }
            } else {
                let newTask = Task(context: bg)
                newTask.id = Int64(Date().timeIntervalSince1970 * 1000)
                newTask.title = titleText.isEmpty ? "Новая заметка" : titleText
                newTask.taskDescription = bodyText
                newTask.isCompleted = false
                newTask.createdAt = Date()
            }
            try? bg.save()
            DispatchQueue.main.async {
                self.onSave?()
                self.dismiss(animated: true)
            }
        }
    }
}
