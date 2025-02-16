//
//  NetworkError.swift
//  AvitoInternshipWinter2025
//
//  Created by Никита Абаев on 17.02.2025.
//


import Foundation

enum NetworkError: Error, LocalizedError {
    
    case invalidURL
    case unableToComplete
    case invalidResponse
    case invalidData
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return NSLocalizedString("The URL is invalid. Please try again later.", comment: "")
        case .unableToComplete:
            return NSLocalizedString("Unable to complete your request. Please check your internet connection.", comment: "")
        case .invalidResponse:
            return NSLocalizedString("Invalid response from the server. Please try again later.", comment: "")
        case .invalidData:
            return NSLocalizedString("The data received from the server was invalid. Please try again.", comment: "")
        }
    }
}