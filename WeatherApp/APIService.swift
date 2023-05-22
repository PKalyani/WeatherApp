//
//  APIService.swift
//  WeatherAPP
//
//  Created by Kalyani Puvvada on 5/20/23.
//

import Foundation

class APIService {
    
    static let  shared = APIService()
    
    public enum APIError: Error {
        case error(_ errorString: String)
    }
    
    // Reusable method to make an API call and fetching the data
    func getJSON<T: Decodable>(urlString: String, completion: @escaping (Result<T, APIError>) -> Void) {
        guard let url = URL(string: urlString.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            completion(.failure(.error("failed to get url.")))
            return }
        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { data, response, error in
            guard let data = data, error == nil else {
                completion(.failure(.error("Failed to fetch data - \(String(describing: error))")))
                return }
            do {
                let modelData = try JSONDecoder().decode(T.self, from: data)
                completion(.success(modelData))
            }
            catch {
                completion(.failure(.error("Failed to decode the data - \(error)")))
                print("failed with \(error)")
            }
        }
        task.resume()
    }
    
    // Fetching the image from URL
    func fetchImageData(urlString: String, completion: @escaping (Data?, Error?) -> ()) {
        print(urlString)
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: URLRequest(url: url)) { data, response, error in
            if error != nil {
                print("Error while getting data - \(String(describing: error))")
                completion(nil, error)
                return
            }
            completion(data, nil)
        }.resume()
    }
}
