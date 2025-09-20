//
//  TodoCell.swift
//  ToDoEM
//
//  Created by Nurseit Seitov on 16.09.2025.
//

import UIKit

final class TodoCell: UITableViewCell {
    static let reuseId = "TodoCell"

    private let titleLabel = UILabel()
    private let checkboxButton = UIButton(type: .system)

    var onToggle: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupUI() {
        backgroundColor = .black
        selectionStyle = .none

        // Текст заметки
        titleLabel.font = .systemFont(ofSize: 22, weight: .regular)  // больше размер
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 0  // чтобы длинные задачи переносились
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        // Чекбокс
        checkboxButton.tintColor = .systemYellow
        checkboxButton.translatesAutoresizingMaskIntoConstraints = false
        checkboxButton.addTarget(self, action: #selector(toggleTapped), for: .touchUpInside)

        contentView.addSubview(titleLabel)
        contentView.addSubview(checkboxButton)

        NSLayoutConstraint.activate([
            // Чекбокс побольше
            checkboxButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            checkboxButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkboxButton.widthAnchor.constraint(equalToConstant: 32),
            checkboxButton.heightAnchor.constraint(equalToConstant: 32),

            // Текст задачи с большими отступами
            titleLabel.leadingAnchor.constraint(equalTo: checkboxButton.trailingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }

    func configure(with model: TodoItemViewModel) {
        if model.isCompleted {
            let attr = NSAttributedString(
                string: model.title,
                attributes: [
                    .strikethroughStyle: NSUnderlineStyle.single.rawValue,
                    .foregroundColor: UIColor.lightGray
                ]
            )
            titleLabel.attributedText = attr
        } else {
            titleLabel.attributedText = nil
            titleLabel.text = model.title
            titleLabel.textColor = .white
        }

        let imageName = model.isCompleted ? "checkmark.circle.fill" : "circle"
        checkboxButton.setImage(UIImage(systemName: imageName), for: .normal)
    }

    @objc private func toggleTapped() {
        onToggle?()
    }
}
