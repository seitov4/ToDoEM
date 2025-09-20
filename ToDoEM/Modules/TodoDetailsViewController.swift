//
//  TodoDetailsViewController.swift
//  ToDoEM
//
//  Created by Nurseit Seitov on 18.09.2025.
//

import UIKit
import CoreData

final class TodoDetailsViewController: UIViewController {

    var taskId: Int64?
    var onSave: (() -> Void)?

    // Заголовок (теперь UITextView, многострочный)
    private let titleView: UITextView = {
        let tv = UITextView()
        tv.font = .systemFont(ofSize: 28, weight: .bold)
        tv.backgroundColor = .clear
        tv.textColor = .white
        tv.isScrollEnabled = false                // 🔑 высота растёт автоматически
        tv.textContainerInset = .zero
        tv.textContainer.lineFragmentPadding = 0
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
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
        tv.isScrollEnabled = true
        tv.alwaysBounceVertical = true
        tv.textContainerInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        tv.textContainer.lineFragmentPadding = 0
        tv.textContainer.lineBreakMode = .byWordWrapping
        tv.isEditable = true
        tv.isSelectable = true
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupNav()
        layout()
        setupKeyboardObservers()

        if let id = taskId {
            loadTask(id: id)
        } else {
            titleView.becomeFirstResponder()
            dateLabel.text = DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .short)
        }
    }

    private func setupNav() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Назад", style: .plain, target: self, action: #selector(cancelTapped))
        navigationItem.leftBarButtonItem?.tintColor = .systemYellow
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Готово", style: .done, target: self, action: #selector(saveTapped))
        navigationItem.rightBarButtonItem?.tintColor = .systemYellow
    }

    private func layout() {
        view.addSubview(titleView)
        view.addSubview(dateLabel)
        view.addSubview(textView)

        NSLayoutConstraint.activate([
            titleView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            dateLabel.topAnchor.constraint(equalTo: titleView.bottomAnchor, constant: 6),
            dateLabel.leadingAnchor.constraint(equalTo: titleView.leadingAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: titleView.trailingAnchor),

            textView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 12),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func loadTask(id: Int64) {
        let ctx = CoreDataStack.shared.viewContext
        let req: NSFetchRequest<Task> = Task.fetchRequest()
        req.predicate = NSPredicate(format: "id == %d", id)
        if let task = try? ctx.fetch(req).first {
            titleView.text = task.title
            textView.text = task.taskDescription
            let df = DateFormatter(); df.dateStyle = .medium; df.timeStyle = .short
            dateLabel.text = df.string(from: task.createdAt)
        }
    }

    @objc private func cancelTapped() { dismiss(animated: true) }

    @objc private func saveTapped() {
        let titleText = titleView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        let bodyText = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)

        if titleText.isEmpty && bodyText.isEmpty {
            dismiss(animated: true); return
        }

        let bg = CoreDataStack.shared.newBackgroundContext()
        bg.perform {
            if let id = self.taskId {
                let req: NSFetchRequest<Task> = Task.fetchRequest()
                req.predicate = NSPredicate(format: "id == %d", id)
                if let found = try? bg.fetch(req).first {
                    found.title = titleText.isEmpty ? found.title : titleText
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

    // MARK: - Keyboard Handling
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        if let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            let height = frame.height
            textView.contentInset.bottom = height
            textView.verticalScrollIndicatorInsets.bottom = height
        }
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        textView.contentInset.bottom = 0
        textView.verticalScrollIndicatorInsets.bottom = 0
    }
}
