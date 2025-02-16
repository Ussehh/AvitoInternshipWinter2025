//
//  FilterViewControllerDelegate.swift
//  AvitoInternshipWinter2025
//
//  Created by Никита Абаев on 17.02.2025.
//


import UIKit

protocol FilterViewControllerDelegate: AnyObject {
    func didApplyFilters(categoryId: Int?, priceMin: Int?, priceMax: Int?)
}

class FilterViewController: UIViewController {
    weak var delegate: FilterViewControllerDelegate?
    
    // MARK: - private
    
    private var selectedCategoryId: Int?
    private var minPrice: Int?
    private var maxPrice: Int?
    
    private let categories = R.Strings.categories
    
    private lazy var categoryPicker: UIPickerView = {
        let picker = UIPickerView()
        picker.dataSource = self
        picker.delegate = self
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.text = R.Strings.price
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let minPriceField: UITextField = {
        let textField = UITextField()
        textField.placeholder = R.Strings.ot
        textField.keyboardType = .numberPad
        textField.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        textField.layer.cornerRadius = 8
        textField.layer.masksToBounds = true
        textField.textColor = .black
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 0))
        textField.leftViewMode = .always
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let maxPriceField: UITextField = {
        let textField = UITextField()
        textField.placeholder = R.Strings.Do
        textField.keyboardType = .numberPad
        textField.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        textField.layer.cornerRadius = 8
        textField.layer.masksToBounds = true
        textField.textColor = .black
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 0))
        textField.leftViewMode = .always
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var applyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(R.Strings.applyFilters, for: .normal)
        button.backgroundColor = UIColor.lightGray
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(applyFilters), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        let backArrowImage = R.Image.chevronLeft
        button.setImage(backArrowImage, for: .normal)
        button.tintColor = R.Colors.black
        button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var resetButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(R.Strings.reset, for: .normal)
        button.setTitleColor(.lightGray, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.addTarget(self, action: #selector(resetFilters), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = R.Colors.backgroungColor
        setupViews()
        setupKeyboardToolbar()
        restoreFilters()
        setupPriceButton()
        sledim()
    }
    
    //MARK: - Setup UI
    
    private func setupViews() {
        view.addSubview(categoryPicker)
        view.addSubview(priceLabel)
        view.addSubview(minPriceField)
        view.addSubview(maxPriceField)
        view.addSubview(applyButton)
        view.addSubview(backButton)
        view.addSubview(resetButton)
        
        NSLayoutConstraint.activate([
            categoryPicker.topAnchor.constraint(equalTo: view.topAnchor, constant: 40),
            categoryPicker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categoryPicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            priceLabel.topAnchor.constraint(equalTo: categoryPicker.bottomAnchor, constant: 40),
            priceLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            minPriceField.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 8),
            minPriceField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            minPriceField.widthAnchor.constraint(equalToConstant: (view.frame.width - 48) / 2),
            minPriceField.heightAnchor.constraint(equalToConstant: 50),
            
            maxPriceField.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 8),
            maxPriceField.leadingAnchor.constraint(equalTo: minPriceField.trailingAnchor, constant: 8),
            maxPriceField.widthAnchor.constraint(equalToConstant: (view.frame.width - 48) / 2),
            maxPriceField.heightAnchor.constraint(equalToConstant: 50),
            
            applyButton.topAnchor.constraint(equalTo: maxPriceField.bottomAnchor, constant: 40),
            applyButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            applyButton.widthAnchor.constraint(equalToConstant: view.frame.width - 32),
            applyButton.heightAnchor.constraint(equalToConstant: 55),
            
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            
            resetButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            resetButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
    }
    
    //MARK: - methods
    
    private func setupPriceButton() {
        minPriceField.addTarget(self, action: #selector(minPriceChanged(_:)), for: .editingChanged)
        maxPriceField.addTarget(self, action: #selector(maxPriceChanged(_:)), for: .editingChanged)
    }
    
    private func sledim() {
        minPriceField.addTarget(self, action: #selector(filterChanged), for: .editingChanged)
        maxPriceField.addTarget(self, action: #selector(filterChanged), for: .editingChanged)
        
    }
    
    private func setupKeyboardToolbar() {
        let doneToolbar: UIToolbar = UIToolbar()
        doneToolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
        doneToolbar.setItems([doneButton], animated: false)
        
        minPriceField.inputAccessoryView = doneToolbar
        maxPriceField.inputAccessoryView = doneToolbar
    }
    
    private func restoreFilters() {
        if let savedCategoryId = UserDefaults.standard.value(forKey: "selectedCategoryId") as? Int {
            selectedCategoryId = savedCategoryId
            if let index = categories.firstIndex(where: { $0.1 == savedCategoryId }) {
                categoryPicker.selectRow(index, inComponent: 0, animated: false)
            }
        } else {
            selectedCategoryId = nil
            categoryPicker.selectRow(0, inComponent: 0, animated: false)
        }
        
        var savedMinPrice = UserDefaults.standard.value(forKey: "minPrice") as? Int
        var savedMaxPrice = UserDefaults.standard.value(forKey: "maxPrice") as? Int
        
        if let minPrice = savedMinPrice, let maxPrice = savedMaxPrice,
           minPrice != 0, maxPrice != 1_000_000 {
        } else {
            if savedMinPrice != nil, savedMinPrice != 0 {
                savedMaxPrice = nil
                UserDefaults.standard.removeObject(forKey: "maxPrice")
            }
            
            if savedMaxPrice != nil, savedMaxPrice != 1_000_000 {
                savedMinPrice = nil
                UserDefaults.standard.removeObject(forKey: "minPrice")
            }
        }
        
        minPrice = savedMinPrice
        maxPrice = savedMaxPrice
        
        minPriceField.text = savedMinPrice != nil ? "\(savedMinPrice!)" : ""
        maxPriceField.text = savedMaxPrice != nil ? "\(savedMaxPrice!)" : ""
        
        filterChanged()
    }
    
    //MARK: - @objc methods
    
    @objc private func resetFilters() {
        UserDefaults.standard.removeObject(forKey: "selectedCategoryId")
        UserDefaults.standard.removeObject(forKey: "minPrice")
        UserDefaults.standard.removeObject(forKey: "maxPrice")
        
        selectedCategoryId = nil
        minPrice = nil
        maxPrice = nil
        
        categoryPicker.selectRow(0, inComponent: 0, animated: true)
        minPriceField.text = ""
        maxPriceField.text = ""
        
        resetButton.setTitleColor(.lightGray, for: .normal)
        
        delegate?.didApplyFilters(categoryId: selectedCategoryId, priceMin: nil, priceMax: nil)
    }
    
    @objc private func applyFilters() {
        let appliedMinPrice = minPrice ?? (maxPrice != nil ? 0 : nil)
        let appliedMaxPrice = maxPrice ?? (minPrice != nil ? 1_000_000 : nil)
        
        UserDefaults.standard.set(selectedCategoryId, forKey: "selectedCategoryId")
        if let appliedMinPrice = appliedMinPrice {
            UserDefaults.standard.set(appliedMinPrice, forKey: "minPrice")
        } else {
            UserDefaults.standard.removeObject(forKey: "minPrice")
        }
        if let appliedMaxPrice = appliedMaxPrice {
            UserDefaults.standard.set(appliedMaxPrice, forKey: "maxPrice")
        } else {
            UserDefaults.standard.removeObject(forKey: "maxPrice")
        }
        
        delegate?.didApplyFilters(categoryId: selectedCategoryId, priceMin: appliedMinPrice, priceMax: appliedMaxPrice)
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func backButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func minPriceChanged(_ textField: UITextField) {
        if let text = textField.text, let value = Int(text) {
            minPrice = value
        } else {
            minPrice = nil
        }
    }
    
    @objc private func maxPriceChanged(_ textField: UITextField) {
        if let text = textField.text, let value = Int(text) {
            maxPrice = value
        } else {
            maxPrice = nil
        }
    }
    
    @objc private func filterChanged() {
        let isCategorySelected = selectedCategoryId != nil
        let isMinPriceEntered = !(minPriceField.text?.isEmpty ?? true)
        let isMaxPriceEntered = !(maxPriceField.text?.isEmpty ?? true)
        
        let hasFilters = isCategorySelected || isMinPriceEntered || isMaxPriceEntered
        
        resetButton.setTitleColor(hasFilters ? .black : .lightGray, for: .normal)
    }
    
    
}

//MARK: - Ext UIPickerViewDelegate UIPickerViewDataSource

extension FilterViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categories[row].0
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedCategoryId = categories[row].1
        filterChanged()
    }
}