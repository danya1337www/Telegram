//
//  ChatCell.swift
//  Telegram
//
//  Created by Danil Chekantsev on 31/07/2025.
//
import Foundation
import UIKit

final class ChatCell: UITableViewCell {
    
    // MARK: - Properties
    static let reuseIndentifier = "ChatCell"
    
    private let avatarImage = UIImageView()
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let timeLabel = UILabel()
    private let badgeView = UILabel()
    

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Methods
    
    func configure(with chat: Chat) {
        titleLabel.text = chat.title
        if case let .text(text)? = chat.lastMessage?.kind {
            messageLabel.text = text
        } else {
            messageLabel.text = "-- empty --"
        }
        if let date = chat.lastMessage?.sentDate {
            timeLabel.text = RelativeDateTimeFormatter().localizedString(for: date, relativeTo: Date())
        }
        
        badgeView.isHidden = chat.unreadCount == 0
        badgeView.text = String(chat.unreadCount)
        
        if
            let sender = chat.lastMessage?.sender as? Sender
        {
            avatarImage.load(from: sender.avatarURL)
        } else {
            // fall‑back: placeholder
            avatarImage.image = UIImage(named: "avatar-placeholder")
        }
    }
    
    // MARK: - Private Methods
    
    private func setupViews() {
        
        avatarImage.layer.cornerRadius = 30
        avatarImage.clipsToBounds = true
        avatarImage.translatesAutoresizingMaskIntoConstraints = false
        avatarImage.contentMode = .scaleAspectFill
        
        // Configure colors,size,font for labels.
        titleLabel.font = .boldSystemFont(ofSize: 16)
        messageLabel.font = .systemFont(ofSize: 14)
        messageLabel.textColor = .gray
        timeLabel.font = .systemFont(ofSize: 14)
        timeLabel.textColor = .gray
        badgeView.font = .systemFont(ofSize: 14)
        badgeView.textColor = .white
        badgeView.backgroundColor = .systemBlue
        badgeView.layer.cornerRadius = 10
        badgeView.clipsToBounds = true
        badgeView.textAlignment = .center
        
        titleLabel.numberOfLines = 1
        messageLabel.numberOfLines = 1
        badgeView.numberOfLines = 1
        
        [avatarImage, titleLabel, messageLabel, timeLabel, badgeView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            // avatar
            avatarImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            avatarImage.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            avatarImage.widthAnchor.constraint(equalToConstant: 60),
            avatarImage.heightAnchor.constraint(equalToConstant: 60),

            // title
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: avatarImage.trailingAnchor, constant: 12),

            // time
            timeLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            timeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -2),
            timeLabel.widthAnchor.constraint(equalToConstant: 50),

            // message
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            messageLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            messageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            // badge
            badgeView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            badgeView.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 10),
            badgeView.widthAnchor.constraint(greaterThanOrEqualToConstant: 21),
            badgeView.heightAnchor.constraint(equalToConstant: 21)
            
        ])
        
    }
    
    private func format(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
}

extension UIImageView {
    func load(from url: URL?) {
        self.image = UIImage(systemName: "person.crop.circle")
        
        guard let url = url else { return }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data, let img = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                self.image = img
            }
        }.resume()
    }
}
