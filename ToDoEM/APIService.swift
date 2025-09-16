//
//  APIService.swift
//  ToDoEM
//
//  Created by Nurseit Seitov on 16.09.2025.
//

import Foundation
import Foundation

// структура задачи из API
struct TodoAPIItem: Decodable {
    let id: Int
    let todo: String
    let completed: Bool
    let userId: Int
}

// структура ответа API
struct TodoListResponse: Decodable {
    let todos: [TodoAPIItem]
}

final class APIService {
    static let shared = APIService()
    private init() {}

    func fetchTodos(completion: @escaping (Result<[TodoAPIItem], Error>) -> Void) {
        guard let url = URL(string: "https://dummyjson.com/todos") else {
            completion(.failure(URLError(.badURL))); return
        }
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error)); return
            }
            guard let data = data else {
                completion(.failure(URLError(.badServerResponse))); return
            }
            do {
                let wrapper = try JSONDecoder().decode(TodoListResponse.self, from: data)
                completion(.success(wrapper.todos))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
