//
//  CartItemCell.swift
//  AvitoInternshipWinter2025
//
//  Created by Никита Абаев on 17.02.2025.
//


import UIKit

class CartItemCell: UICollectionViewCell {
    //MARK: - Private
    
    private var cartItem: CartItem?
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let priceLabel = UILabel()
    private let deleteButton = UIButton(type: .system)
    private let decreaseButton = UIButton(type: .system)
    private let increaseButton = UIButton(type: .system)
    private let quantityLabel = UILabel()
    
    var onDeleteItem: (() -> Void)?
    var onItemTapped: (() -> Void)?
    var onQuantityChanged: ((CartItem) -> Void)?
    
    //MARK: - Didset
    
    var quantity: Int = 1 {
        didSet {
            quantityLabel.text = "\(quantity)"
            updatePrice()
        }
    }
    
    var unitPrice: Int = 0 {
        didSet {
            updatePrice()
        }
    }
    
    //MARK: - init's
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Setup  UI
    
    private func setupUI() {
        contentView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.1)
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
        
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)
        
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        
        priceLabel.font = UIFont.systemFont(ofSize: 20)
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(priceLabel)
        
        deleteButton.setImage(R.Image.trash, for: .normal)
        deleteButton.addTarget(self, action: #selector(deleteItem), for: .touchUpInside)
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(deleteButton)
        
        decreaseButton.setTitle(R.Strings.minus, for: .normal)
        decreaseButton.addTarget(self, action: #selector(decreaseQuantity), for: .touchUpInside)
        decreaseButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(decreaseButton)
        
        increaseButton.setTitle(R.Strings.plus, for: .normal)
        increaseButton.addTarget(self, action: #selector(increaseQuantity), for: .touchUpInside)
        increaseButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(increaseButton)
        
        quantityLabel.font = UIFont.systemFont(ofSize: 16)
        quantityLabel.text = "\(quantity)"
        quantityLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(quantityLabel)
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            imageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 100),
            imageView.heightAnchor.constraint(equalToConstant: 100),
            
            priceLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 10),
            priceLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            
            deleteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            deleteButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            deleteButton.widthAnchor.constraint(equalToConstant: 30),
            deleteButton.heightAnchor.constraint(equalToConstant: 30),
            
            titleLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 10),
            titleLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 5),
            titleLabel.trailingAnchor.constraint(equalTo: deleteButton.leadingAnchor, constant: -5),
            
            decreaseButton.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            decreaseButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            decreaseButton.widthAnchor.constraint(equalToConstant: 30),
            decreaseButton.heightAnchor.constraint(equalToConstant: 30),
            
            quantityLabel.leadingAnchor.constraint(equalTo: decreaseButton.trailingAnchor, constant: 5),
            quantityLabel.centerYAnchor.constraint(equalTo: decreaseButton.centerYAnchor),
            
            increaseButton.leadingAnchor.constraint(equalTo: quantityLabel.trailingAnchor, constant: 5),
            increaseButton.centerYAnchor.constraint(equalTo: decreaseButton.centerYAnchor),
            increaseButton.widthAnchor.constraint(equalToConstant: 30),
            increaseButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    //MARK: - @objc methods
    @objc private func deleteItem() {
        onDeleteItem?()
    }
    
    @objc private func itemTapped() {
        onItemTapped?()
    }
    
    @objc private func decreaseQuantity() {
        guard var item = cartItem, item.quantity > 1 else { return }
        item.quantity -= 1
        cartItem = item
        onQuantityChanged?(item)
        updateCellUI(item)
    }
    
    @objc private func increaseQuantity() {
        guard var item = cartItem else { return }
        item.quantity += 1
        cartItem = item
        onQuantityChanged?(item)
        updateCellUI(item)
    }
    
    //MARK: - another methods
    
    private func updatePrice() {
        let totalPrice = unitPrice * quantity
        priceLabel.text = "\(totalPrice)$"
    }
    
    private func updateCellUI(_ item: CartItem) {
        quantityLabel.text = "\(item.quantity)"
        priceLabel.text = "\(item.product.price * item.quantity)$"
    }
    
    //MARK: - loadImage
    
    func loadImage(from url: String) {
        guard let imageURL = URL(string: url) else { return }
        
        let task = URLSession.shared.dataTask(with: imageURL) { (data, response, error) in
            if let error = error {
                print("Error loading image: \(error)")
                return
            }
            
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.imageView.image = image
                }
            }
        }
        task.resume()
    }
    
    //MARK: - Configure
    func configure(with item: CartItem) {
        self.cartItem = item
        titleLabel.text = item.product.title
        unitPrice = item.product.price
        quantity = item.quantity
        
        if let imageURLString = item.product.images.first, let _ = URL(string: imageURLString) {
            loadImage(from: imageURLString)
        } else {
            imageView.image = R.Image.placeholderImage
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(itemTapped))
        contentView.addGestureRecognizer(tapGesture)
    }
}