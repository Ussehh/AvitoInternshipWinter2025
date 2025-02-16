//
//  SearchResultsViewControllerProtocol.swift
//  AvitoInternshipWinter2025
//
//  Created by Никита Абаев on 17.02.2025.
//

import UIKit

protocol SearchResultsViewControllerProtocol: AnyObject {
    func didSelectHistoryItem(historyItem: String)
}

class SearchResultsViewController: UIViewController {
    // MARK: - Properties
    
    weak var delegate: SearchResultsViewControllerProtocol?
    
    // MARK: - Private
    
    private var dataSource: UITableViewDiffableDataSource<Int, String>!
    
    private lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.register(UITableViewCell.self, forCellReuseIdentifier: R.Constants.historyItemCellIdentifier)
        tv.backgroundColor = R.Colors.backgroungColor
        tv.delegate = self
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        configureDataSource()
        setupKeyboardObservers()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup TableView
    
    private func setupTableView() {
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - DataSource Setup
    
    private func configureDataSource() {
        dataSource = UITableViewDiffableDataSource<Int, String>(tableView: tableView, cellProvider: { tableView, indexPath, historyItem in
            let cell = tableView.dequeueReusableCell(withIdentifier: R.Constants.historyItemCellIdentifier, for: indexPath)
            
            cell.backgroundColor = R.Colors.backgroungColor
            cell.textLabel?.text = historyItem
            cell.textLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            cell.textLabel?.textColor = R.Colors.black
            
            cell.imageView?.image = R.Image.clock
            cell.imageView?.tintColor = R.Colors.black
            
            let arrowImageView = UIImageView(image: R.Image.chevronRight)
            arrowImageView.tintColor = R.Colors.black
            cell.accessoryView = arrowImageView
            
            return cell
        })
        
        var snapshot = NSDiffableDataSourceSnapshot<Int, String>()
        snapshot.appendSections([0])
        snapshot.appendItems([])
        dataSource.apply(snapshot, animatingDifferences: false)
        
        tableView.dataSource = dataSource
    }
    
    // MARK: - update
    
    func updateView(historyItems: [String]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, String>()
        snapshot.appendSections([0])
        snapshot.appendItems(historyItems)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    // MARK: - Keyboard Observers
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            let insets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.height, right: 0)
            tableView.contentInset = insets
            tableView.scrollIndicatorInsets = insets
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        tableView.contentInset = .zero
        tableView.scrollIndicatorInsets = .zero
    }
}

// MARK: - UITableViewDelegate

extension SearchResultsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath),
           let historyItem = cell.textLabel?.text {
            delegate?.didSelectHistoryItem(historyItem: historyItem)
        }
    }
}
