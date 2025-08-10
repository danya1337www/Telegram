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

        // Two ISO8601 formatters: one with fractional seconds and one without.
        let isoNoFrac = ISO8601DateFormatter()
        isoNoFrac.formatOptions = [.withInternetDateTime]
        let isoWithFrac = ISO8601DateFormatter()
        isoWithFrac.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        // Fallbacks for other possible date string shapes.
        let plain = DateFormatter()
        plain.locale = Locale(identifier: "en_US_POSIX")
        plain.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS" // without timezone offset
        let alt = DateFormatter()
        alt.locale = Locale(identifier: "en_US_POSIX")
        alt.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ" // with numeric timezone

        d.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let raw = try container.decode(String.self)

            if let date = isoNoFrac.date(from: raw) { return date }
            if let date = isoWithFrac.date(from: raw) { return date }
            if let date = plain.date(from: raw) { return date }
            if let date = alt.date(from: raw) { return date }

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
