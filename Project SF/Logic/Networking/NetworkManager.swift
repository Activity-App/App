//
//  NetworkManager.swift
//  Project SF
//
//  Created by Roman Esin on 10.07.2020.
//

import Foundation
import Network

class NetworkManager {
    
    // MARK: Type Aliases
    
    typealias DataResult = Result<Data, NetworkError>
    typealias DecodedResult<T> = Result<T, NetworkError>
    
    // MARK: Static Properties

    static let shared = NetworkManager(urlSession: URLSession.shared)
    
    // MARK: Properties
    
    let urlSession: URLSession
    
    private let monitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue(label: "NetworkMonitorQueue")
    var connected = false
    
    // MARK: Init
    
    init(urlSession: URLSession) {
        self.urlSession = urlSession
        
        self.monitor.pathUpdateHandler = { update in
            self.connected = update.status == .satisfied
            print(self.connected)
        }
        self.monitor.start(queue: monitorQueue)
    }

    // MARK: Data Request
    
    func request(_ url: URL?, _ completion: @escaping (DataResult) -> Void) {
        guard let url = url else {
            completion(.failure(.invalidURL))
            return
        }

        urlSession.dataTask(with: url) { (data, _, error) in
            if error != nil {
                completion(.failure(.networkError))
                return
            }

            guard let data = data else {
                completion(.failure(.noDataInResponse))
                return
            }

            completion(.success(data))
        }.resume()
    }

    // MARK: Decoded Request
    
    func request<T: Codable>(_ url: URL?,
                             decode type: T.Type,
                             completion: @escaping (DecodedResult<T>) -> Void) {
        request(url) { (result) in
            switch result {
            case .success(let data):
                do {
                    let decoded = try JSONDecoder().decode(type, from: data)
                    completion(.success(decoded))
                } catch {
                    completion(.failure(.decodingError))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // MARK: - Network Error
    
    enum NetworkError: Error {
        case invalidURL
        case networkError
        case noDataInResponse
        case decodingError
    }
    
}
