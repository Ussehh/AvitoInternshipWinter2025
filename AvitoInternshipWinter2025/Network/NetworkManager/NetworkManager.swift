//
//  APIConstants.swift
//  AvitoInternshipWinter2025
//
//  Created by Никита Абаев on 17.02.2025.
//


import UIKit

// MARK: - APIConstants

enum APIConstants {
    static let baseURL = "https://api.escuelajs.co/api/v1"
    static let productsEndpoint = "/products"
}

// MARK: - Protocol NetworkManagerProtocol
protocol NetworkManagerProtocol {
    
    typealias HandlerProducts = (Result<[Product], NetworkError>) -> Void
    typealias HandlerProduct = (Result<Product, NetworkError>) -> Void
    
    func getProducts(offset: Int,
                     limit: Int,
                     title: String?,
                     price: Int?,
                     priceMin: Int?,
                     priceMax: Int?,
                     categoryId: Int?,
                     completion: @escaping HandlerProducts)
    
    func getProduct(by id: Int, completion: @escaping HandlerProduct)
    
    func downloadImage(from url: String?, completed: @escaping (UIImage?) -> Void)
}

// MARK: - NetworkManager

class NetworkManager: NetworkManagerProtocol {
    
    static let shared = NetworkManager()
    private let session = URLSession.shared
    let cache = NSCache<NSString, UIImage>()
    
    private func performRequest<T: Decodable>(url: URL, completion: @escaping (Result<T, NetworkError>) -> Void) {
        let task = session.dataTask(with: url) { data, response, error in
            if let _ = error {
                completion(.failure(.unableToComplete))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                completion(.failure(.invalidResponse))
                return
            }
            
            guard let data = data else {
                completion(.failure(.invalidData))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let decodedData = try decoder.decode(T.self, from: data)
                completion(.success(decodedData))
            } catch {
                completion(.failure(.invalidData))
            }
        }
        task.resume()
    }
    
    // MARK: - Getting a list of products with filters and pagination
    
    func getProducts(offset: Int = 0,
                     limit: Int = 10,
                     title: String? = nil,
                     price: Int? = nil,
                     priceMin: Int? = nil,
                     priceMax: Int? = nil,
                     categoryId: Int? = nil,
                     completion: @escaping HandlerProducts) {
        
        var components = URLComponents(string: "\(APIConstants.baseURL)\(APIConstants.productsEndpoint)")
        
        var queryItems = [URLQueryItem]()
        queryItems.append(URLQueryItem(name: "offset", value: "\(offset)"))
        queryItems.append(URLQueryItem(name: "limit", value: "\(limit)"))
        
        if let title = title, !title.isEmpty {
            queryItems.append(URLQueryItem(name: "title", value: title))
        }
        if let price = price {
            queryItems.append(URLQueryItem(name: "price", value: "\(price)"))
        }
        if let priceMin = priceMin {
            queryItems.append(URLQueryItem(name: "price_min", value: "\(priceMin)"))
        }
        if let priceMax = priceMax {
            queryItems.append(URLQueryItem(name: "price_max", value: "\(priceMax)"))
        }
        if let categoryId = categoryId {
            queryItems.append(URLQueryItem(name: "categoryId", value: "\(categoryId)"))
        }
        
        components?.queryItems = queryItems
        
        guard let url = components?.url else {
            completion(.failure(.invalidURL))
            return
        }
        
        performRequest(url: url, completion: completion)
    }
    
    // MARK: - Getting one product by id
    
    func getProduct(by id: Int, completion: @escaping HandlerProduct) {
        let urlString = "\(APIConstants.baseURL)\(APIConstants.productsEndpoint)/\(id)"
        guard let url = URL(string: urlString) else {
            completion(.failure(.invalidURL))
            return
        }
        performRequest(url: url, completion: completion)
    }
    
    // MARK: - download Image
    func downloadImage(from url: String?, completed: @escaping (UIImage?) -> Void) {
        guard let urlString = url, let url = URL(string: urlString) else {
            completed(nil)
            return
        }
        
        let cacheKey = NSString(string: urlString)
        if let cachedImage = cache.object(forKey: cacheKey) {
            completed(cachedImage)
            return
        }
        
        let task = session.dataTask(with: url) { [weak self] data, response, error in
            if let _ = error {
                completed(nil)
                return
            }
            guard let self = self,
                  let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200,
                  let data = data,
                  let image = UIImage(data: data) else {
                completed(nil)
                return
            }
            
            self.cache.setObject(image, forKey: cacheKey)
            completed(image)
        }
        task.resume()
    }
}