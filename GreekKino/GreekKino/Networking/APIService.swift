//
//  APIService.swift
//  GreekKino
//
//

import Foundation

enum APIError: Error {
    case invalidURL
    case requestFailed
    case invalidResponse
}

protocol APIServiceProtocol {
    func fetchData<T: Codable>(from urlString: String, completion: @escaping (Result<T, Error>) -> Void)
}

class APIService: APIServiceProtocol {    
    func fetchData<T: Codable>(from urlString: String, completion: @escaping (Result<T, Error>) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(APIError.requestFailed))
                return
            }
            
            guard let data = data else {
                completion(.failure(APIError.invalidResponse))
                return
            }
            
            do {
                let decodedData = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decodedData))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
