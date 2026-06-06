//
//  ChatCell.swift
//  Telegram
//
//  Created by Danil Chekantsev on 31/07/2025.
//
import Foundation
import UIKit

final class ChatCell: UITableViewCell {
    
    static let reuseIndentifier = "ChatCell"
    
    private let avatarImage = UIImageView()
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let timeLabel = UILabel()
    private let badgeView = UILabel()
    private let mutedImage = UIImageView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        mutedImage.isHidden = true
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
            timeLabel.text = format(date)
        }
        
        badgeView.isHidden = chat.unreadCount == 0
        badgeView.text = String(chat.unreadCount)
        
        if
            let sender = chat.lastMessage?.sender as? Sender {
            avatarImage.load(from: sender.avatarURL)
        } else {
            avatarImage.image = UIImage(named: "avatar-placeholder")
        }
        
        mutedImage.isHidden = !chat.isMuted
    }
    
    // MARK: - Private Methods
    
    private func setupViews() {
        
        avatarImage.layer.cornerRadius = 30
        avatarImage.clipsToBounds = true
        avatarImage.translatesAutoresizingMaskIntoConstraints = false
        avatarImage.contentMode = .scaleAspectFill
        
        titleLabel.font = .boldSystemFont(ofSize: 16)
        
        messageLabel.font = .systemFont(ofSize: Constants.UI.systemFontSize)
        messageLabel.textColor = .gray
        
        timeLabel.font = .systemFont(ofSize: Constants.UI.systemFontSize)
        timeLabel.textColor = .gray
        
        badgeView.font = .systemFont(ofSize: Constants.UI.systemFontSize)
        badgeView.textColor = .white
        badgeView.backgroundColor = .systemBlue
        badgeView.layer.cornerRadius = 10
        badgeView.clipsToBounds = true
        badgeView.textAlignment = .center
        
        titleLabel.numberOfLines = Constants.UI.numberOfLines
        messageLabel.numberOfLines = Constants.UI.numberOfLines
        badgeView.numberOfLines = Constants.UI.numberOfLines
        
        mutedImage.tintColor = .systemGray
        mutedImage.contentMode = .scaleAspectFit
        mutedImage.translatesAutoresizingMaskIntoConstraints = false
        mutedImage.image = UIImage(named: "muted")
        mutedImage.isHidden = true
        
        [avatarImage, titleLabel, messageLabel, timeLabel, badgeView, mutedImage].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        NSLayoutConstraint.activate([
            avatarImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            avatarImage.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            avatarImage.widthAnchor.constraint(equalToConstant: 60),
            avatarImage.heightAnchor.constraint(equalToConstant: 60),

            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: avatarImage.trailingAnchor, constant: 12),

            timeLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            timeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -2),
            timeLabel.widthAnchor.constraint(equalToConstant: 50),

            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            messageLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            messageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -28),

            badgeView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            badgeView.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 10),
            badgeView.widthAnchor.constraint(greaterThanOrEqualToConstant: 21),
            badgeView.heightAnchor.constraint(equalToConstant: 21),
                        
            mutedImage.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            mutedImage.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 6),
            mutedImage.trailingAnchor.constraint(lessThanOrEqualTo: timeLabel.leadingAnchor, constant: -6),
            mutedImage.widthAnchor.constraint(equalToConstant: 14),
            mutedImage.heightAnchor.constraint(equalToConstant: 14)
            
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
        
        guard let url else { return }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data, let img = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                self.image = img
            }
        }.resume()
    }
}

extension ChatCell {
    enum Constants {
        enum UI {
            static let numberOfLines = 1
            static let systemFontSize: CGFloat = 14
        }
    }
}
