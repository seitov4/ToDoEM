//
//  TodoListViewController.swift
//  ToDoEM
//
//  Created by Nurseit Seitov on 16.09.2025.
//

import UIKit

final class TodoListViewController: UIViewController, TodoListViewProtocol {

    var presenter: TodoListPresenterProtocol?
    private let tableView = UITableView()
    private var tasks: [TodoItemViewModel] = []

    // MARK: - UI Elements
    private let bottomBar: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(white: 0.06, alpha: 1)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let countLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 14)
        l.textColor = .white
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let pencilButtonSmall: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "square.and.pencil"), for: .normal)
        b.tintColor = .systemYellow
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    // search controller
    private var searchController: UISearchController!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Задачи"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        view.backgroundColor = .black
        setupNavBar()
        setupTableView()
        setupSearch()
        setupBottomBar()
        presenter?.viewDidLoad()
    }

    // MARK: - Setup UI
    private func setupNavBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .black
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white,
                                               .font: UIFont.systemFont(ofSize: 34, weight: .bold)]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.tintColor = .systemYellow
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .black
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = .darkGray
        tableView.register(TodoCell.self, forCellReuseIdentifier: TodoCell.reuseId)
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableView.automaticDimension
        tableView.keyboardDismissMode = .interactive

        view.addSubview(tableView)

        // tableView bottom привязан к верхней границе bottomBar
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            // bottomAnchor добавим ниже (после создания bottomBar)
        ])
    }

    private func setupSearch() {
        let sc = UISearchController(searchResultsController: nil)
        sc.obscuresBackgroundDuringPresentation = false
        sc.searchBar.placeholder = "Search"
        sc.searchBar.searchTextField.textColor = .white
        sc.searchResultsUpdater = self
        sc.searchBar.barStyle = .black

        // показать кнопку справа (bookmark) и поставить иконку микрофона
        sc.searchBar.showsBookmarkButton = true
        sc.searchBar.setImage(UIImage(systemName: "mic.fill"), for: .bookmark, state: .normal)
        sc.searchBar.delegate = self

        navigationItem.searchController = sc
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController = sc
    }

    private func setupBottomBar() {
        view.addSubview(bottomBar)
        bottomBar.addSubview(countLabel)
        bottomBar.addSubview(pencilButtonSmall)

        NSLayoutConstraint.activate([
            bottomBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bottomBar.heightAnchor.constraint(equalToConstant: 56)
        ])

        // теперь свяжем tableView.bottomAnchor с bottomBar.topAnchor
        NSLayoutConstraint.activate([
            tableView.bottomAnchor.constraint(equalTo: bottomBar.topAnchor)
        ])

        NSLayoutConstraint.activate([
            countLabel.centerXAnchor.constraint(equalTo: bottomBar.centerXAnchor),
            countLabel.centerYAnchor.constraint(equalTo: bottomBar.centerYAnchor),

            pencilButtonSmall.trailingAnchor.constraint(equalTo: bottomBar.trailingAnchor, constant: -16),
            pencilButtonSmall.centerYAnchor.constraint(equalTo: bottomBar.centerYAnchor),
            pencilButtonSmall.widthAnchor.constraint(equalToConstant: 36),
            pencilButtonSmall.heightAnchor.constraint(equalToConstant: 36)
        ])
        pencilButtonSmall.addTarget(self, action: #selector(didTapAdd), for: .touchUpInside)
    }

    // MARK: - Actions
    @objc private func didTapAdd() {
        presenter?.didTapAdd()
    }

    // MARK: - TodoListViewProtocol
    func showTasks(_ tasks: [TodoItemViewModel]) {
        self.tasks = tasks
        countLabel.text = "\(tasks.count) Задач"
        print("DEBUG: получено задач ->", tasks.count)
        tableView.reloadData()
    }

    func showError(_ message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension TodoListViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: TodoCell.reuseId, for: indexPath) as? TodoCell else {
            return UITableViewCell()
        }
        let task = tasks[indexPath.row]
        print("DEBUG: рисуем задачу ->", task.title)
        cell.configure(with: task)
        cell.onToggle = { [weak self] in
            self?.presenter?.didToggleComplete(id: task.id, completed: !task.isCompleted)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let task = tasks[indexPath.row]
        presenter?.didSelectTask(id: task.id)
    }

    // Context menu (long press)
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let task = tasks[indexPath.row]
        return UIContextMenuConfiguration(identifier: nil, previewProvider: {
            // preview: небольшая вью с заголовком и описанием (используем контроллер)
            let vc = UIViewController()
            vc.view.backgroundColor = .clear
            let container = UIView()
            container.backgroundColor = UIColor(white: 0.06, alpha: 1)
            container.layer.cornerRadius = 12
            container.translatesAutoresizingMaskIntoConstraints = false

            let title = UILabel()
            title.font = .systemFont(ofSize: 16, weight: .semibold)
            title.textColor = .white
            title.text = task.title
            title.translatesAutoresizingMaskIntoConstraints = false

            let desc = UILabel()
            desc.font = .systemFont(ofSize: 13)
            desc.textColor = .lightGray
            desc.numberOfLines = 3
            desc.text = task.description
            desc.translatesAutoresizingMaskIntoConstraints = false

            container.addSubview(title)
            container.addSubview(desc)
            vc.view.addSubview(container)

            NSLayoutConstraint.activate([
                container.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
                container.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
                container.widthAnchor.constraint(equalToConstant: min(UIScreen.main.bounds.width - 40, 320)),
                title.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
                title.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
                title.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
                desc.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 6),
                desc.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
                desc.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
                desc.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12)
            ])
            return vc
        }, actionProvider: { _ in
            let edit = UIAction(title: "Редактировать", image: UIImage(systemName: "pencil")) { _ in
                self.presenter?.didSelectTask(id: task.id)
            }
            let share = UIAction(title: "Поделиться", image: UIImage(systemName: "square.and.arrow.up")) { _ in
            }
            let delete = UIAction(title: "Удалить", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
                self.presenter?.didTapDelete(id: task.id)
            }
            return UIMenu(title: "", children: [edit, share, delete])
        })
    }
}

// MARK: - UISearchResultsUpdating
extension TodoListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let text = searchController.searchBar.text ?? ""
        if text.isEmpty {
            presenter?.viewDidLoad()
        } else {
            presenter?.search(text: text)
        }
    }
}

extension TodoListViewController: UISearchBarDelegate {
    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        // TODO: интеграция диктовки — пока просто фидбек
        let alert = UIAlertController(title: nil, message: "Voice input placeholder", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
