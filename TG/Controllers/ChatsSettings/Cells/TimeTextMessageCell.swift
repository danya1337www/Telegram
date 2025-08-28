//
//  TimeTextMessageCell.swift
//  Telegram
//
//  Created by Danil Chekantsev on 10/08/2025.
//

import Foundation
import MessageKit
import UIKit

import MessageKit

final class TimeTextMessageCell: TextMessageCell {

    private static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter
    }()

    let timeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        messageLabel.textInsets = UIEdgeInsets(top: 8, left: 12, bottom: 18, right: 28)

        messageContainerView.addSubview(timeLabel)
        NSLayoutConstraint.activate([
            timeLabel.trailingAnchor.constraint(equalTo: messageContainerView.trailingAnchor, constant: -10),
            timeLabel.bottomAnchor.constraint(equalTo: messageContainerView.bottomAnchor, constant: -6)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func configure(with message: MessageType,
                            at indexPath: IndexPath,
                            and messagesCollectionView: MessagesCollectionView) {
        super.configure(with: message, at: indexPath, and: messagesCollectionView)
        timeLabel.text = Self.dateFormatter.string(from: message.sentDate)
        
        let isOutgoing = messagesCollectionView.messagesDataSource?
            .isFromCurrentSender(message: message) ?? false
        timeLabel.textColor = isOutgoing ? UIColor.white.withAlphaComponent(0.8) : .secondaryLabel
    }
}
