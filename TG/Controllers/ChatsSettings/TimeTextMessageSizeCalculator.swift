//
//  TimeTextMessageSizeCalculator.swift
//  Telegram
//
//  Created by Danil Chekantsev on 10/08/2025.
//

import Foundation
import UIKit
import MessageKit

final class TimeTextMessageSizeCalculator: TextMessageSizeCalculator {

    override init(layout: MessagesCollectionViewFlowLayout?) {
        super.init(layout: layout)
    }

    override func messageContainerSize(for message: MessageType,
                                       at indexPath: IndexPath) -> CGSize {
        var size = super.messageContainerSize(for: message, at: indexPath)
        size.height += 10
        size.width  += 20
        return size
    }
}
