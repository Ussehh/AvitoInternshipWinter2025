//
//  SearchPresenterProtocol.swift
//  AvitoInternshipWinter2025
//
//  Created by Никита Абаев on 17.02.2025.
//


import Foundation

//MARK: - Protocol

protocol SearchPresenterProtocol {
    func searchItems(term: String,
                     offset: Int,
                     price: Int?,
                     priceMin: Int?,
                     priceMax: Int?,
                     categoryId: Int?)
    
    func clearSearchResults()
    func getHistoryItems(term: String?)
}

final class SearchPresenter: SearchPresenterProtocol {
    weak private var view: SearchViewControllerProtocol?
    
    //MARK: - private
    
    private let networkManager: NetworkManagerProtocol
    private(set) var products: [Product] = []
    private var searchTerm: String = ""
    
    //MARK: - properties
    
    var currentOffset: Int = 0
    let limit: Int = 10
    var hasMoreProducts: Bool = true
    
    //MARK: - init
    
    init(networkManager: NetworkManagerProtocol = NetworkManager.shared) {
        self.networkManager = networkManager
    }
    
    //MARK: - Set view
    
    func setView(view: SearchViewControllerProtocol) {
        self.view = view
    }
    
    //MARK: - search
    
    func searchItems(term: String,
                     offset: Int,
                     price: Int? = nil,
                     priceMin: Int? = nil,
                     priceMax: Int? = nil,
                     categoryId: Int? = nil) {
        DispatchQueue.main.async {
            self.view?.startActivityIndicator()
        }
        
        self.searchTerm = term
        self.saveTerm(term: term)
        
        networkManager.getProducts(offset: offset,
                                   limit: limit,
                                   title: term.isEmpty ? nil : term,
                                   price: price,
                                   priceMin: priceMin,
                                   priceMax: priceMax,
                                   categoryId: categoryId) { result in
            DispatchQueue.main.async {
                self.view?.stopActivityIndicator()
            }
            switch result {
            case .success(let fetchedProducts):
                if offset == 0 {
                    self.products = fetchedProducts
                } else {
                    self.products.append(contentsOf: fetchedProducts)
                }
                self.currentOffset = offset
                self.hasMoreProducts = fetchedProducts.count == self.limit
                DispatchQueue.main.async {
                    self.view?.updateSearch(products: self.products)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.view?.showError(error.localizedDescription)
                }
            }
        }
    }
    
    //MARK: - Methods
    
    func clearSearchResults() {
        products = []
        currentOffset = 0
        hasMoreProducts = true
        view?.updateSearch(products: [])
        view?.clearView()
    }
    
    func getHistoryItems(term: String?) {
        guard let term = term else {
            self.view?.updateHistory(queries: [])
            return
        }
        let allHistoryItems = UserDefaults.standard.stringArray(forKey: R.Constants.historyItemKey) ?? []
        let historyItems: [String]
        if term.isEmpty {
            historyItems = Array(allHistoryItems.suffix(5).reversed())
        } else {
            historyItems = Array(allHistoryItems.filter { $0.lowercased().contains(term.lowercased()) }.suffix(5).reversed())
        }
        self.view?.updateHistory(queries: historyItems)
    }
    
    
    private func saveTerm(term: String) {
        guard !term.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        
        var allHistoryItems = UserDefaults.standard.stringArray(forKey: R.Constants.historyItemKey) ?? []
        if let index = allHistoryItems.firstIndex(of: term) {
            allHistoryItems.remove(at: index)
        }
        allHistoryItems.append(term)
        UserDefaults.standard.set(allHistoryItems, forKey: R.Constants.historyItemKey)
    }
    
}