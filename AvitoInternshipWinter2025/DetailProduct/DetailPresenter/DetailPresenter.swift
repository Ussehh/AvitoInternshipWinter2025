//
//  DetailPresenterProtocol.swift
//  AvitoInternshipWinter2025
//
//  Created by Никита Абаев on 17.02.2025.
//


import Foundation

protocol DetailPresenterProtocol {
    func viewDidLoad()
}

class DetailPresenter: DetailPresenterProtocol {
    weak var view: DetailViewControllerProtocol?
    var product: Product
    
    init(view: DetailViewControllerProtocol?, product: Product) {
        self.view = view
        self.product = product
    }
    
    func viewDidLoad() {
        view?.displayTitle(product.title)
        view?.displayDescription(product.description)
        view?.displayCategory(product.category.name)
        
        let priceString = "\(product.price)$"
        view?.displayPrice(priceString)
        
        view?.displayImages(product.images)
    }
}