//
//  TodoCell.swift
//  ToDoEM
//
//  Created by Nurseit Seitov on 16.09.2025.
//

import UIKit

final class TodoCell: UITableViewCell {
    static let reuseId = "TodoCell"

    private let checkboxButton: UIButton = {
        let btn = UIButton(type: .system)

        // Отключаем iOS15+ конфигурацию (иначе появляется фон-бокс)
        btn.configuration = nil

        btn.setImage(UIImage(systemName: "circle"), for: .normal)
        btn.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .selected)
        btn.tintColor = .systemYellow
        btn.translatesAutoresizingMaskIntoConstraints = false

        btn.backgroundColor = .clear
        btn.layer.borderWidth = 0
        btn.layer.cornerRadius = 0
        btn.clipsToBounds = false

        return btn
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 17, weight: .semibold)
        l.textColor = .white
        l.numberOfLines = 1
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let descriptionLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13)
        l.textColor = .lightGray
        l.numberOfLines = 2
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let dateLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12)
        l.textColor = .gray
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    var onToggle: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none

        contentView.addSubview(checkboxButton)
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(dateLabel)

        checkboxButton.addTarget(self, action: #selector(didTapCheckbox), for: .touchUpInside)

        NSLayoutConstraint.activate([
            checkboxButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            checkboxButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkboxButton.widthAnchor.constraint(equalToConstant: 28),
            checkboxButton.heightAnchor.constraint(equalToConstant: 28),

            titleLabel.leadingAnchor.constraint(equalTo: checkboxButton.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),

            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),

            dateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            dateLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 8),
            dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    @objc private func didTapCheckbox() {
        checkboxButton.isSelected.toggle()
        applyStrikeThrough(checkboxButton.isSelected)
        onToggle?()
    }

    private func applyStrikeThrough(_ strike: Bool) {
        if strike {
            let attr = NSAttributedString(
                string: titleLabel.text ?? "",
                attributes: [
                    .strikethroughStyle: NSUnderlineStyle.single.rawValue,
                    .foregroundColor: UIColor.systemGray
                ])
            titleLabel.attributedText = attr
        } else {
            titleLabel.attributedText = NSAttributedString(string: titleLabel.text ?? "",
                                                           attributes: [.foregroundColor: UIColor.white])
        }
    }

    func configure(with vm: TodoItemViewModel) {
        titleLabel.text = vm.title
        descriptionLabel.text = vm.description
        dateLabel.text = vm.dateString
        checkboxButton.isSelected = vm.isCompleted
        applyStrikeThrough(vm.isCompleted)
    }

    // Убираем стандартную подсветку
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {}
    override func setSelected(_ selected: Bool, animated: Bool) {}
}
