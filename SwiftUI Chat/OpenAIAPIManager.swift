//
//  OpenAIAPIManager.swift
//  SwiftUI Chat
//
//  Created by Danny Phantom on 5/19/23.
//  Copyright © 2023 AntiChat, Inc. All rights reserved.
//

import Foundation

class OpenAIAPIManager {
    private let apiKey = "<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>"
    private let apiURL = "https://api.openai.com/v1/engines/davinci-codex/completions"
    
    func chatWithGPT3(userMessage: String, completion: @escaping (Result<String, Error>) -> Void) {
        // Prepare URL and request
        guard let url = URL(string: apiURL) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Prepare body content
        let promptData = ["prompt": userMessage, "max_tokens": 60] as [String : Any]
        request.httpBody = try? JSONSerialization.data(withJSONObject: promptData, options: [])
        
        // Execute request
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
            } else if let data = data {
                do {
                    // Parse response data
                    if let jsonResult = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let choices = jsonResult["choices"] as? [[String: Any]],
                       let firstChoice = choices.first,
                       let text = firstChoice["text"] as? String {
                        completion(.success(text))
                    }
                } catch {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
}

