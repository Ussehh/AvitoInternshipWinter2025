//
//  Product.swift
//  AvitoInternshipWinter2025
//
//  Created by Никита Абаев on 17.02.2025.
//


import Foundation

// MARK: - Product

struct Product: Codable {
    let id: Int
    let title: String
    let price: Int
    let description: String
    let category: Category
    let images: [String]
    let creationAt: String?
    let updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id, title, price, description, category, images, creationAt, updatedAt
    }
}

// MARK: - Category

struct Category: Codable {
    let id: Int
    let name: String
    let image: String
    let creationAt: String?
    let updatedAt: String?     

    enum CodingKeys: String, CodingKey {
        case id, name, image, creationAt, updatedAt
    }
}