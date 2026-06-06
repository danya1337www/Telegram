//
//  MockUser.swift
//  Telegram
//
//  Created by Danil Chekantsev on 28/07/2025.
//

import Foundation
import MessageKit

struct Sender: SenderType, Codable, Hashable {
    let senderId: String
    let displayName: String
    let lastSeenDate: Date
    let avatarURL: URL
}

enum MessageKind: Codable, Hashable {
    case text(String)

    private enum CodingKeys: String, CodingKey { case type, text }
    private enum Kind: String, Codable { case text }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        switch try c.decode(Kind.self, forKey: .type) {
        case .text:
            self = .text(try c.decode(String.self, forKey: .text))
        }
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .text(let text):
            try c.encode(Kind.text, forKey: .type)
            try c.encode(text,      forKey: .text)
        }
    }
}

struct Message: MessageType, Codable, Hashable {

    // MARK: - Stored properties for Codable / Hashable
    private let senderModel: Sender

    var sender: SenderType { senderModel }

    let messageId: String
    let sentDate: Date
    private let storedKind: MessageKind

    // MARK: - MessageKit bridge
    var kind: MessageKit.MessageKind {
        switch storedKind {
        case .text(let text): return .text(text)
        }
    }

    // MARK: - Codable mapping
    private enum CodingKeys: String, CodingKey {
        case senderModel = "sender", messageId, sentDate
        case storedKind = "kind"
    }

    init(sender: Sender,
         messageId: String,
         sentDate: Date,
         kind: MessageKit.MessageKind)
    {
        self.senderModel = sender
        self.messageId  = messageId
        self.sentDate   = sentDate

        switch kind {
        case .text(let text):
            self.storedKind = .text(text)
        default:
            fatalError("Unsupported MessageKind (\(kind)). Extend `storedKind` & `switch` above.")
        }
    }

    // MARK: - Codable
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        senderModel = try c.decode(Sender.self,  forKey: .senderModel)
        messageId  = try c.decode(String.self,  forKey: .messageId)
        sentDate   = try c.decode(Date.self,    forKey: .sentDate)
        storedKind = try c.decode(MessageKind.self, forKey: .storedKind)
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(senderModel,     forKey: .senderModel)
        try c.encode(messageId,  forKey: .messageId)
        try c.encode(sentDate,   forKey: .sentDate)
        try c.encode(storedKind, forKey: .storedKind)
    }
}

struct Chat: Codable, Hashable {
    let id: String
    let title: String
    var messages: [Message]
    var unreadCount: Int
    var lastOffset: CGPoint?
    var lastMessage: Message? { messages.max(by: { $0.sentDate < $1.sentDate }) }
    var isMuted: Bool = false
    
    enum CodingKeys: String, CodingKey {
            case id, title, messages, unreadCount, lastOffset, isMuted
        }

        init(id: String,
             title: String,
             messages: [Message],
             unreadCount: Int,
             lastOffset: CGPoint? = nil,
             isMuted: Bool = false) {
            self.id = id
            self.title = title
            self.messages = messages
            self.unreadCount = unreadCount
            self.lastOffset = lastOffset
            self.isMuted = isMuted
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            id = try container.decode(String.self, forKey: .id)
            title = try container.decode(String.self, forKey: .title)
            messages = try container.decode([Message].self, forKey: .messages)
            unreadCount = try container.decode(Int.self, forKey: .unreadCount)
            lastOffset = try container.decodeIfPresent(CGPoint.self, forKey: .lastOffset)
            isMuted = try container.decodeIfPresent(Bool.self, forKey: .isMuted) ?? false
        }
}
