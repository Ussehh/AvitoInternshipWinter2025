//
//  DetailViewControllerProtocol.swift
//  AvitoInternshipWinter2025
//
//  Created by Никита Абаев on 17.02.2025.
//


import UIKit

// MARK: - Protocol

protocol DetailViewControllerProtocol: AnyObject {
    func displayImages(_ images: [String])
    func displayPrice(_ price: String?)
    func displayTitle(_ title: String?)
    func displayDescription(_ description: String?)
    func displayCategory(_ category: String?)
}

class DetailViewController: UIViewController, DetailViewControllerProtocol {
    // MARK: - Private
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let priceLabel = UILabel()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let categoryLabel = UILabel()
    private var collectionView: UICollectionView!
    private var pageLabel: UILabel!
    private let actionButton = UIButton()
    
    var presenter: DetailPresenterProtocol!
    var product: Product
    var images: [String] = []
    
    // MARK: - init's
    
    init(presenter: DetailPresenterProtocol, product: Product) {
        self.product = product
        super.init(nibName: nil, bundle: nil)
        self.presenter = presenter
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - lifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupCustomBackButton()
        setupShareButton()
        presenter.viewDidLoad()
        setupSwipeBackGesture()
        updatePageLabel()
        updateAddToCartButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateAddToCartButton()
    }
    
    // MARK: - UI Setup
    
    private func setupView() {
        view.backgroundColor = R.Colors.backgroungColor
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.itemSize = CGSize(width: view.bounds.width, height: view.bounds.width * 0.9)
        layout.sectionInset = .zero
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(collectionView)
        
        pageLabel = UILabel()
        pageLabel.textColor = .white
        pageLabel.font = UIFont.boldSystemFont(ofSize: 18)
        pageLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(pageLabel)
        
        priceLabel.font = UIFont.boldSystemFont(ofSize: 28)
        priceLabel.textAlignment = .left
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(priceLabel)
        
        titleLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        titleLabel.textAlignment = .left
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .left
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(descriptionLabel)
        
        categoryLabel.font = UIFont.systemFont(ofSize: 14)
        categoryLabel.textAlignment = .left
        categoryLabel.textColor = .gray
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(categoryLabel)
        
        actionButton.setTitle(R.Strings.goodsInCart, for: .normal)
        actionButton.backgroundColor = .gray
        actionButton.setTitleColor(.black, for: .normal)
        actionButton.layer.cornerRadius = 25
        actionButton.clipsToBounds = true
        actionButton.addTarget(self, action: #selector(addToCartButtonTapped), for: .touchUpInside)
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(actionButton)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            collectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            collectionView.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            
            pageLabel.bottomAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: -10),
            pageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            priceLabel.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 10),
            priceLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            priceLabel.heightAnchor.constraint(equalToConstant: 30),
            
            titleLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            
            categoryLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 10),
            categoryLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            
            
            actionButton.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 40),
            actionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            actionButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            actionButton.heightAnchor.constraint(equalToConstant: 50),
            actionButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    // MARK: - Share Button Setup
    
    private func setupShareButton() {
        let shareButton = UIBarButtonItem(
            image: R.Image.squareAndArrowUp,
            style: .plain,
            target: self,
            action: #selector(shareButtonTapped)
        )
        shareButton.tintColor = R.Colors.black
        navigationItem.rightBarButtonItem = shareButton
    }
    
    // MARK: - methods
    
    @objc func shareButtonTapped() {
        guard let title = titleLabel.text,
              let price = priceLabel.text,
              let description = descriptionLabel.text else {
            return
        }
        
        let shareText = """
        Название: \(title)
        Цена: \(price)
        Описание: \(description)
        """
        
        let activityItems: [Any] = [shareText]
        
        let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
    }
    
    @objc func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    private func updatePageLabel() {
        if images.count > 0 {
            pageLabel.text = "1/\(images.count)"
        } else {
            pageLabel.text = "0/0"
        }
    }
    
    private func setupCustomBackButton() {
        let backButton = UIBarButtonItem(
            image: R.Image.chevronLeft,
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        )
        backButton.tintColor = R.Colors.black
        navigationItem.leftBarButtonItem = backButton
    }
    
    // MARK: - DetailViewControllerProtocol methods
    
    func displayImages(_ images: [String]) {
        self.images = images
        collectionView.reloadData()
        
        updatePageLabel()
    }
    
    func displayPrice(_ price: String?) {
        priceLabel.text = price
    }
    
    func displayTitle(_ title: String?) {
        titleLabel.text = title
    }
    
    func displayDescription(_ description: String?) {
        descriptionLabel.text = description ?? R.StringsMessage.noDescription
    }
    
    func displayCategory(_ category: String?) {
        categoryLabel.text = category
    }
    
    
}


// MARK: - Ext UIGestureRecognizerDelegate

extension DetailViewController: UIGestureRecognizerDelegate {
    
    private func setupSwipeBackGesture() {
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return navigationController?.viewControllers.count ?? 0 > 1
    }
    
}

// MARK: - Ext UICollectionViewDataSource, UICollectionViewDelegate
extension DetailViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        let imageUrl = images[indexPath.item]
        
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        cell.contentView.addSubview(imageView)
        
        imageView.image = R.Image.placeholderImage
        
        if !imageUrl.isEmpty {
            NetworkManager.shared.downloadImage(from: imageUrl) { image in
                DispatchQueue.main.async {
                    if let image = image {
                        imageView.image = image
                    } else {
                        imageView.image = R.Image.placeholderImage
                    }
                }
            }
        }
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor)
        ])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let fullScreenVC = FullScreenImageViewController(images: images)
        navigationController?.pushViewController(fullScreenVC, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.frame.size.width != 0 else { return }
        
        let page = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
        
        pageLabel.text = "\(page + 1)/\(images.count)"
    }
    
}

//MARK: - Ext work this cart

extension DetailViewController {
    @objc private func updateAddToCartButton() {
        if isProductInCart() {
            actionButton.setTitle(R.Strings.goToCart, for: .normal)
        } else {
            actionButton.setTitle(R.Strings.plusInCart, for: .normal)
        }
    }
    
    private func isProductInCart() -> Bool {
        return UserDefaults.standard.bool(forKey: "isProductInCart-\(product.id)")
    }
    
    @objc func addToCartButtonTapped() {
        if isProductInCart() {
            
            let cartVC = CartViewController()
            let navigationController = UINavigationController(rootViewController: cartVC)
            
            navigationController.modalPresentationStyle = .fullScreen
            self.present(navigationController, animated: true, completion: nil)
        } else {
            addProductToCart()
            updateAddToCartButton()
        }
    }
    
    private func addProductToCart() {
        var cartItems = getCartItems()
        if let index = cartItems.firstIndex(where: { $0.product.id == product.id }) {
            cartItems[index].quantity += 1
        } else {
            cartItems.append(CartItem(product: product, quantity: 1))
        }
        saveCartItems(cartItems)
        saveProductAddedState(isAdded: true)
        updateAddToCartButton()
    }
    
    
    private func getCartItems() -> [CartItem] {
        if let data = UserDefaults.standard.data(forKey: "cartItems"),
           let savedCartItems = try? JSONDecoder().decode([CartItem].self, from: data) {
            return savedCartItems
        }
        return []
    }
    
    private func saveProductAddedState(isAdded: Bool) {
        UserDefaults.standard.set(isAdded, forKey: "isProductInCart-\(product.id)")
    }
    
    private func saveCartItems(_ cartItems: [CartItem]) {
        if let data = try? JSONEncoder().encode(cartItems) {
            UserDefaults.standard.set(data, forKey: "cartItems")
        }
    }
}