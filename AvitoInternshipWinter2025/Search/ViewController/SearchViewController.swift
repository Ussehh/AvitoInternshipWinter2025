//
//  SearchViewControllerProtocol.swift
//  AvitoInternshipWinter2025
//
//  Created by Никита Абаев on 17.02.2025.
//


import UIKit

// MARK: - SearchViewControllerProtocol

protocol SearchViewControllerProtocol: AnyObject {
    func updateSearch(products: [Product])
    func updateHistory(queries: [String])
    func startActivityIndicator()
    func stopActivityIndicator()
    func clearView()
    func showError(_ message: String)
}

class SearchViewController: UIViewController, SearchViewControllerProtocol {
    
    // MARK:  Properties
    
    var presenter: SearchPresenter
    private var collectionView: UICollectionView!
    private var offset: Int = 0
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = R.Strings.goods
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var cartButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            image: R.Image.cart,
            style: .plain,
            target: self,
            action: #selector(cartButtonTapped)
        )
        return button
    }()
    
    private lazy var noResultsLabel: UILabel = {
        let label = UILabel()
        label.text = R.Strings.noGoodsLabel
        label.textColor = R.Colors.black
        label.font = R.Fonts.pouf
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
        }()
    
    private var searchController: UISearchController
    
    // MARK: - Init's
    
    init(presenter: SearchPresenter) {
        self.presenter = presenter
        let searchResultsController = SearchResultsViewController()
        self.searchController = UISearchController(searchResultsController: searchResultsController)
        self.searchController.searchBar.tintColor = R.Colors.black
        super.init(nibName: nil, bundle: nil)
        self.presenter.setView(view: self)
        searchResultsController.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
        presenter.searchItems(term: "", offset: 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if presenter.products.isEmpty {
            presenter.searchItems(term: "", offset: 0)
        }
    }
    
    // MARK: - Setup UI
    
    private func setupView() {
        view.backgroundColor = R.Colors.backgroungColor
        setupTitleLabel()
        setupCollectionView()
        setupActivityIndicator()
        setupNavigationBar()
        setupSearchController()
        setupNoResultsLabel()
    }
    
    private func setupTitleLabel() {
        view.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    private func setupNoResultsLabel() {
            view.addSubview(noResultsLabel)
            NSLayoutConstraint.activate([
                noResultsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                noResultsLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                noResultsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                noResultsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
            ])
        }
    
    private func setupCollectionView() {
        let layout = createTwoColumnFlowLayout()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(SearchCollectionCell.self, forCellWithReuseIdentifier: SearchCollectionCell.reuseIdentifier)
        collectionView.register(FullWidthCell.self, forCellWithReuseIdentifier: FullWidthCell.reuseIdentifier) //
        collectionView.register(Loader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: Loader.loaderID)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = R.Colors.backgroungColor
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupActivityIndicator() {
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = cartButton
        navigationItem.titleView = searchController.searchBar
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }
    
    private func setupSearchController() {
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = R.Strings.placeholder
        searchController.searchBar.delegate = self
        searchController.showsSearchResultsController = true
        searchController.hidesNavigationBarDuringPresentation = false
        addFilterButtonToSearchBar()
    }
    
    private func addFilterButtonToSearchBar() {
        guard let searchTextField = searchController.searchBar.value(forKey: "searchField") as? UITextField else { return }
        let filterButton = createFilterButton()
        searchTextField.rightView = filterButton
        searchTextField.rightViewMode = .always
    }
    
    private func createFilterButton() -> UIButton {
        let filterButton = UIButton(type: .system)
        filterButton.setImage(R.Image.filter, for: .normal)
        filterButton.tintColor = .black
        filterButton.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
        return filterButton
    }
    
    // MARK: - @objc methods
    
    @objc private func cartButtonTapped() {

        
        let cartVC = CartViewController()
        let navigationController = UINavigationController(rootViewController: cartVC)

        navigationController.modalPresentationStyle = .fullScreen

        self.present(navigationController, animated: true, completion: nil)
    }

    @objc private func filterButtonTapped() {
        let filterVC = FilterViewController()
        filterVC.delegate = self
        filterVC.modalPresentationStyle = .custom
        filterVC.modalTransitionStyle = .coverVertical
        present(filterVC, animated: true)
    }
    
    // MARK: - Layout Helper
    
    private func createTwoColumnFlowLayout() -> UICollectionViewFlowLayout {
        let padding: CGFloat = 16
        let minimumItemSpacing: CGFloat = 10
        let availableWidth = view.bounds.width - (padding * 2) - minimumItemSpacing
        let itemWidth = availableWidth / 2
        let itemHeight: CGFloat = 270
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        layout.minimumInteritemSpacing = minimumItemSpacing
        layout.minimumLineSpacing = minimumItemSpacing
        layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
        return layout
    }
    
    
    // MARK: - SearchViewControllerProtocol Methods
    
    func updateSearch(products: [Product]) {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
                self.noResultsLabel.isHidden = !products.isEmpty
            }
        }
    
    func updateHistory(queries: [String]) {
        if let searchResultsController = searchController.searchResultsController as? SearchResultsViewController {
            searchResultsController.updateView(historyItems: queries)
        }
    }
    
    func startActivityIndicator() {
        DispatchQueue.main.async {
            self.activityIndicator.startAnimating()
        }
    }
    
    func stopActivityIndicator() {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
        }
    }
    
    func clearView() {
        searchController.searchBar.text = ""
    }
    
    func showError(_ message: String) {
        let alert = UIAlertController(title: R.Strings.errorTitle, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: R.Strings.OK, style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UICollectionView DataSource & Delegate

extension SearchViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter.products.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let product = presenter.products[indexPath.item]
        
        if /*product.category.id == 1 ||*/ product.category.id == 4 || product.category.id == 8 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FullWidthCell.reuseIdentifier, for: indexPath) as? FullWidthCell else {
                return UICollectionViewCell()
            }
            cell.configureCell(product: product)
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchCollectionCell.reuseIdentifier, for: indexPath) as? SearchCollectionCell else {
                return UICollectionViewCell()
            }
            cell.configureCell(product: product)
            return cell
        }
    }

    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > contentHeight - height {
            if searchController.isActive, let term = searchController.searchBar.text, !term.isEmpty {
                return
            } else {
                if presenter.hasMoreProducts {
                    let newOffset = presenter.currentOffset + presenter.limit
                    presenter.searchItems(term: searchController.searchBar.text ?? "", offset: newOffset)
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionFooter {
            guard let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Loader.loaderID, for: indexPath) as? Loader else {
                return UICollectionReusableView()
            }
            return footer
        }
        return UICollectionReusableView()
    }
}

// MARK: - UISearchResultsUpdating

    extension SearchViewController: UISearchResultsUpdating {
        func updateSearchResults(for searchController: UISearchController) {
            if searchController.isActive {
                presenter.getHistoryItems(term: searchController.searchBar.text)
            }
        }
    }

// MARK: - UISearchBarDelegate

    extension SearchViewController: UISearchBarDelegate {
        func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
            titleLabel.text = R.Strings.results
            navigationItem.leftBarButtonItem = nil
            navigationItem.rightBarButtonItems = nil
            if let searchTextField = searchController.searchBar.value(forKey: "searchField") as? UITextField {
                searchTextField.rightView = nil
            }
        }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
           guard let term = searchBar.text, !term.isEmpty else { return }
           
           searchController.isActive = false
           titleLabel.text = R.Strings.results
           
           presenter.searchItems(term: term, offset: 0)
           
           navigationItem.leftBarButtonItem = createBackButton()
           navigationItem.rightBarButtonItems = [cartButton]
           addFilterButtonToSearchBar()
       }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
           presenter.searchItems(term: "", offset: 0)
           titleLabel.text = R.Strings.goods
           navigationItem.rightBarButtonItems = [cartButton]
           addFilterButtonToSearchBar()
       }
}

// MARK: - SearchResultsViewControllerProtocol

extension SearchViewController: SearchResultsViewControllerProtocol {
    func didSelectHistoryItem(historyItem: String) {
        searchController.isActive = false
        
        presenter.searchItems(term: historyItem, offset: 0)
        searchController.searchBar.text = historyItem
        
        navigationItem.leftBarButtonItem = createBackButton()
        navigationItem.rightBarButtonItems = [cartButton]
        addFilterButtonToSearchBar()
    }
    
    private func createBackButton() -> UIBarButtonItem {
        return UIBarButtonItem(
            image: R.Image.chevronLeft,
            style: .plain,
            target: self,
            action: #selector(searchDone)
        )
    }
    
    @objc private func searchDone() {
        searchController.searchBar.text = ""
        searchController.isActive = false
        presenter.searchItems(term: "", offset: 0)
        titleLabel.text = R.Strings.goods
        navigationItem.leftBarButtonItem = nil
        navigationItem.rightBarButtonItems = [cartButton]
        addFilterButtonToSearchBar()
    }

}


// MARK: - FilterViewControllerDelegate

extension SearchViewController: FilterViewControllerDelegate {
    func didApplyFilters(categoryId: Int?, priceMin: Int?, priceMax: Int?) {
        presenter.searchItems(
            term: searchController.searchBar.text ?? "",
            offset: 0,
            priceMin: priceMin,
            priceMax: priceMax,
            categoryId: categoryId
        )
    }
}



// MARK: - Ext UICollectionViewDelegateFlowLayout

extension SearchViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let product = presenter.products[indexPath.item]
        
        if /*product.category.id == 1 ||*/ product.category.id == 4 || product.category.id == 8 {
            return CGSize(width: view.bounds.width - 32, height: 350)
        }
        let itemWidth = (view.bounds.width - 48) / 2
        return CGSize(width: itemWidth, height: 270)
    }
}

//MARK: - detailView

extension SearchViewController {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedProduct = presenter.products[indexPath.item]
        navigateToDetailScreen(for: selectedProduct)
    }
    
    private func navigateToDetailScreen(for product: Product) {
        let detailPresenter = DetailPresenter(view: nil, product: product)
        let detailViewController = DetailViewController(presenter: detailPresenter, product: product)
        detailPresenter.view = detailViewController
        navigationController?.pushViewController(detailViewController, animated: true)
    }
}