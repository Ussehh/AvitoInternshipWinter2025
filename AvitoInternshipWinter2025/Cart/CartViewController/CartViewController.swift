//
//  CartViewController.swift
//  AvitoInternshipWinter2025
//
//  Created by Никита Абаев on 17.02.2025.
//


import UIKit

class CartViewController: UIViewController {
    //MARK: - Private
    
    private var cartItems: [CartItem] = []
    private var collectionView: UICollectionView!
    private var totalView: UIView!
    private var totalItemsLabel: UILabel!
    private var totalPriceLabel: UILabel!
    private var shareButton: UIButton!
    private var emptyCartLabel: UILabel!
    
    //MARK: - init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = R.Colors.backgroungColor
        setupNavigationBar()
        setupCollectionView()
        setupEmptyCartLabel()
        setupTotalView()
        updateCartState()
        loadCartItems()
        setupSwipeBackGesture()
    }
    
    //MARK: - SetupUI
    
    private func setupNavigationBar() {
        self.title = R.Strings.cart
        
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 22),
            NSAttributedString.Key.foregroundColor: UIColor.black
        ]
        
        let backButton = UIBarButtonItem(
            image: R.Image.chevronLeft,
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        )
        navigationItem.leftBarButtonItem = backButton
        
        let deleteAllButton = UIBarButtonItem(
            title: R.Strings.clear,
            style: .plain,
            target: self,
            action: #selector(deleteAllButtonTapped)
        )
        navigationItem.rightBarButtonItem = deleteAllButton
        deleteAllButton.tintColor = R.Colors.black
        
    }
    
    private func setupCollectionView() {
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: view.bounds.width - 32, height: 120)
        layout.minimumLineSpacing = 10
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(CartItemCell.self, forCellWithReuseIdentifier: "CartItemCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = .clear
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -130)
        ])
    }
    
    private func setupTotalView() {
        totalView = UIView()
        totalView.backgroundColor = R.Colors.backgroungColor
        totalView.layer.cornerRadius = 20
        totalView.layer.shadowColor = UIColor.black.cgColor
        totalView.layer.shadowOpacity = 0.1
        totalView.layer.shadowOffset = CGSize(width: 0, height: -2)
        totalView.layer.shadowRadius = 4
        totalView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(totalView)
        
        totalItemsLabel = UILabel()
        totalItemsLabel.font = UIFont.systemFont(ofSize: 16)
        totalItemsLabel.textColor = .black
        totalItemsLabel.translatesAutoresizingMaskIntoConstraints = false
        totalView.addSubview(totalItemsLabel)
        
        totalPriceLabel = UILabel()
        totalPriceLabel.font = UIFont.boldSystemFont(ofSize: 18)
        totalPriceLabel.textColor = .black
        totalPriceLabel.translatesAutoresizingMaskIntoConstraints = false
        totalView.addSubview(totalPriceLabel)
        
        shareButton = UIButton(type: .system)
        shareButton.setTitle(R.Strings.share, for: .normal)
        shareButton.backgroundColor = UIColor.lightGray
        shareButton.layer.cornerRadius = 10
        shareButton.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
        shareButton.translatesAutoresizingMaskIntoConstraints = false
        totalView.addSubview(shareButton)
        
        NSLayoutConstraint.activate([
            totalView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            totalView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            totalView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            totalView.heightAnchor.constraint(equalToConstant: 130),
            
            totalItemsLabel.topAnchor.constraint(equalTo: totalView.topAnchor, constant: 16),
            totalItemsLabel.leadingAnchor.constraint(equalTo: totalView.leadingAnchor, constant: 16),
            
            totalPriceLabel.topAnchor.constraint(equalTo: totalItemsLabel.bottomAnchor, constant: 8),
            totalPriceLabel.leadingAnchor.constraint(equalTo: totalView.leadingAnchor, constant: 16),
            
            shareButton.topAnchor.constraint(equalTo: totalView.topAnchor, constant: 20),
            shareButton.trailingAnchor.constraint(equalTo: totalView.trailingAnchor, constant: -16),
            shareButton.heightAnchor.constraint(equalToConstant: 40),
            shareButton.widthAnchor.constraint(equalToConstant: 120)
        ])
    }
    
    private func setupEmptyCartLabel() {
        emptyCartLabel = UILabel()
        emptyCartLabel.text = R.Strings.emptyCart
        emptyCartLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        emptyCartLabel.textColor = .black
        emptyCartLabel.textAlignment = .center
        emptyCartLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyCartLabel.isHidden = true
        view.addSubview(emptyCartLabel)
        
        NSLayoutConstraint.activate([
            emptyCartLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyCartLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func loadCartItems() {
        if let data = UserDefaults.standard.data(forKey: "cartItems"),
           let savedCartItems = try? JSONDecoder().decode([CartItem].self, from: data) {
            cartItems = savedCartItems
        }
        collectionView.reloadData()
        updateTotalInfo()
        updateCartState()
    }
    
    //MARK: - @objc methods
    
    @objc func shareButtonTapped() {
        let shareText = cartItems.map { item in
            "Название: \(item.product.title)\nЦена: \(item.product.price)$\nКоличество: \(item.quantity)"
        }.joined(separator: "\n\n")
        
        let activityViewController = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
    }
    
    
    @objc private func backButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func deleteAllButtonTapped() {
        cartItems.removeAll()
        for item in cartItems {
            UserDefaults.standard.removeObject(forKey: "isProductInCart-\(item.product.id)")
        }
        
        UserDefaults.standard.removeObject(forKey: "cartItems")
        self.collectionView.reloadData()
        self.updateTotalInfo()
        self.updateCartState()
    }
    
    //MARK: - Another methods
    
    private func updateTotalInfo() {
        let totalItems = cartItems.reduce(0) { $0 + $1.quantity }
        let totalPrice = cartItems.reduce(0) { $0 + $1.product.price * $1.quantity }
        
        totalItemsLabel.text = "Товаров: \(totalItems)"
        totalPriceLabel.text = "Сумма: \(Int(totalPrice))$"
    }
    
    private func updateCartState() {
        if cartItems.isEmpty {
            totalView.alpha = 0.0
            emptyCartLabel.isHidden = false
        } else {
            totalView.alpha = 1.0
            emptyCartLabel.isHidden = true
        }
    }
    
    private func updateCartItemQuantity(_ updatedItem: CartItem) {
        if let index = cartItems.firstIndex(where: { $0.product.id == updatedItem.product.id }) {
            cartItems[index] = updatedItem
            saveCartItems()
            updateTotalInfo()
        }
    }
    
    private func setupSwipeBackGesture() {
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    private func saveCartItems() {
        if let data = try? JSONEncoder().encode(cartItems) {
            UserDefaults.standard.set(data, forKey: "cartItems")
        }
    }
    
}

//MARK: - Ext UIGestureRecognizerDelegate
extension CartViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return navigationController?.viewControllers.count ?? 0 > 1
    }
}

//MARK: - Ext UICollectionViewDelegate UICollectionViewDataSource

extension CartViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cartItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CartItemCell", for: indexPath) as! CartItemCell
        let item = cartItems[indexPath.item]
        cell.configure(with: item)
        
        cell.onDeleteItem = {
            self.cartItems.remove(at: indexPath.item)
            UserDefaults.standard.set(false, forKey: "isProductInCart-\(item.product.id)")
            self.collectionView.reloadData()
            self.saveCartItems()
            self.updateTotalInfo()
            self.updateCartState()
            
            
        }
        
        cell.onQuantityChanged = { updatedItem in
            
            self.updateCartItemQuantity(updatedItem)
        }
        
        cell.onItemTapped = {
            let product = item.product
            let detailPresenter = DetailPresenter(view: nil, product: product)
            let detailViewController = DetailViewController(presenter: detailPresenter, product: product)
            detailPresenter.view = detailViewController
            self.navigationController?.pushViewController(detailViewController, animated: true)
        }
        
        return cell
    }
}
