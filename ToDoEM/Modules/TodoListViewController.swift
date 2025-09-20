//
//  TodoListViewController.swift
//  ToDoEM
//
//  Created by Nurseit Seitov on 16.09.2025.
//
import CoreData
import UIKit
import Speech
import AVFoundation

final class TodoListViewController: UIViewController, TodoListViewProtocol {

    var presenter: TodoListPresenterProtocol?

    private let tableView = UITableView()
    private var tasks: [TodoItemViewModel] = []

    // Footer
    private let footerView = UIView()
    private let tasksCountLabel = UILabel()
    private let addButton = UIButton(type: .system)

    // MARK: - Voice Recognition
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ru-RU"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()

    private var searchController: UISearchController!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Задачи"
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .black

        setupNavBar()
        setupTableView()
        setupFooter()
        setupSearchController()
        presenter?.viewDidLoad()

        requestSpeechAuthorization()
    }

    private func setupNavBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .black
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white, .font: UIFont.boldSystemFont(ofSize: 34)]
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .black
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = .darkGray
        tableView.register(TodoCell.self, forCellReuseIdentifier: TodoCell.reuseId)

        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func setupFooter() {
        footerView.translatesAutoresizingMaskIntoConstraints = false
        footerView.backgroundColor = .black

        tasksCountLabel.translatesAutoresizingMaskIntoConstraints = false
        tasksCountLabel.textColor = .lightGray
        tasksCountLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        tasksCountLabel.textAlignment = .center

        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.tintColor = .systemYellow
        addButton.setImage(UIImage(systemName: "square.and.pencil"), for: .normal)
        addButton.addTarget(self, action: #selector(addTapped), for: .touchUpInside)

        footerView.addSubview(tasksCountLabel)
        footerView.addSubview(addButton)
        view.addSubview(footerView)

        NSLayoutConstraint.activate([
            footerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            footerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            footerView.heightAnchor.constraint(equalToConstant: 44),

            tasksCountLabel.centerXAnchor.constraint(equalTo: footerView.centerXAnchor),
            tasksCountLabel.centerYAnchor.constraint(equalTo: footerView.centerYAnchor),

            addButton.trailingAnchor.constraint(equalTo: footerView.trailingAnchor, constant: -16),
            addButton.centerYAnchor.constraint(equalTo: footerView.centerYAnchor),

            tableView.bottomAnchor.constraint(equalTo: footerView.topAnchor)
        ])
    }

    @objc private func addTapped() {
        presenter?.didTapAdd()
    }

    private func setupSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Поиск"
        searchController.searchBar.delegate = self

        // иконка микрофона
        searchController.searchBar.setImage(UIImage(systemName: "mic.fill"), for: .bookmark, state: .normal)
        searchController.searchBar.showsBookmarkButton = true

        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }

    // MARK: - TodoListViewProtocol
    func showTasks(_ tasks: [TodoItemViewModel]) {
        self.tasks = tasks
        tableView.reloadData()
        tasksCountLabel.text = "\(tasks.count) Задач"
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
        cell.configure(with: task)

        // callback для чекбокса
        cell.onToggle = { [weak self] in
            guard let self = self else { return }
            self.presenter?.didToggleComplete(id: task.id, completed: !task.isCompleted)
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let task = tasks[indexPath.row]
        presenter?.didSelectTask(id: task.id)
    }

    // Context menu (long press)
    func tableView(_ tableView: UITableView,
                   contextMenuConfigurationForRowAt indexPath: IndexPath,
                   point: CGPoint) -> UIContextMenuConfiguration? {
        let task = tasks[indexPath.row]
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let edit = UIAction(title: "Редактировать", image: UIImage(systemName: "pencil")) { _ in
                self.presenter?.didSelectTask(id: task.id)
            }
            let share = UIAction(title: "Поделиться", image: UIImage(systemName: "square.and.arrow.up")) { _ in
                self.presenter?.didTapShare(id: task.id)
            }
            let delete = UIAction(title: "Удалить", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
                self.presenter?.didTapDelete(id: task.id)
            }
            return UIMenu(title: "", children: [edit, share, delete])
        }
    }
}

// MARK: - UISearchResultsUpdating
extension TodoListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        presenter?.search(text: searchController.searchBar.text ?? "")
    }
}

// MARK: - UISearchBarDelegate
extension TodoListViewController: UISearchBarDelegate {
    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        if audioEngine.isRunning {
            stopRecording()
        } else {
            startRecording()
        }
    }
}

// MARK: - Voice Recognition Logic
extension TodoListViewController {

    private func requestSpeechAuthorization() {
        SFSpeechRecognizer.requestAuthorization { status in
            if status != .authorized {
                print("⚠️ Доступ к распознаванию речи запрещён")
            }
        }
    }

    private func startRecording() {
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }

        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Ошибка при настройке аудио сессии: \(error)")
            return
        }

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            print("Не удалось создать recognitionRequest")
            return
        }
        recognitionRequest.shouldReportPartialResults = true

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.removeTap(onBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }

        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            print("Не удалось запустить audioEngine: \(error)")
            return
        }

        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
            if let result = result {
                DispatchQueue.main.async {
                    self.searchController.searchBar.text = result.bestTranscription.formattedString
                    self.presenter?.search(text: result.bestTranscription.formattedString)
                }
            }
            if error != nil || (result?.isFinal ?? false) {
                self.stopRecording()
            }
        }
    }

    private func stopRecording() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        recognitionTask = nil
    }
}
