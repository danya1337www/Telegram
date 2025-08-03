//
//  MockLoader .swift
//  Telegram
//
//  Created by Danil Chekantsev on 02/08/2025.
//

import Foundation

final class ChatService {
    private let decoder: JSONDecoder = {
        let d = JSONDecoder()

        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        let plain = DateFormatter()
        plain.locale = Locale(identifier: "en_US_POSIX")
        plain.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"   // без смещения

        d.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let raw = try container.decode(String.self)

            if let date = iso.date(from: raw) { return date }
            if let date = plain.date(from: raw) { return date }

            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Нераспознанная дата: \(raw)"
            )
        }
        return d
    }()
    
    func loadChats(from resource: String = "mock_chats") async throws -> [Chat] {
        guard let url = Bundle.main.url(forResource: resource, withExtension: "json") else {
            throw CocoaError(.fileNoSuchFile)
        }
        let data = try Data(contentsOf: url)
        return try decoder.decode([Chat].self, from: data)
            .sorted { ($0.lastMessage?.sentDate ?? .distantPast) > ($1.lastMessage?.sentDate ?? .distantPast) }
    }
}
