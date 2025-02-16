//
//  CartItem.swift
//  AvitoInternshipWinter2025
//
//  Created by Никита Абаев on 17.02.2025.
//


import Foundation

//MARK: - Model CartItem

struct CartItem: Codable {
    var product: Product
    var quantity: Int
}