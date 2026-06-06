//
//  MockLoader .swift
//  Telegram
//
//  Created by Danil Chekantsev on 02/08/2025.
//

import Foundation

final class ChatService {
    
    func loadChats(from resource: String = "mock_chats") async throws -> [Chat] {
        guard let url = Bundle.main.url(forResource: resource, withExtension: "json") else {
            throw CocoaError(.fileNoSuchFile)
        }
        print("mock_chats.json in bundle:", url)
        print("Bundle path:", Bundle.main.bundlePath)
        
        let data = try Data(contentsOf: url)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        return try decoder.decode([Chat].self, from: data)
            .sorted { ($0.lastMessage?.sentDate ?? .distantPast) > ($1.lastMessage?.sentDate ?? .distantPast) }
    }
}
