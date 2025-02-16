//
//  R.swift
//  AvitoInternshipWinter2025
//
//  Created by Никита Абаев on 17.02.2025.
//


import UIKit

enum R {
    enum Colors {
        static let backgroungColor   = UIColor(hexString: "#F8F4FF")
        static let textColor =  UIColor(hexString: "#755A57")
        static let separator = UIColor(hexString: "#A0A0A0")
        static let buttonColor = UIColor(hexString: "#BC987E")
        static let filterButton = UIColor(hexString: "#CFCFCF")
        static let black = UIColor.black
    }
    
    enum Strings {
        static let description = "Описание"
        static let OK = "ОК"
        static let errorTitle = "Что-то пошло не так"
        static let placeholder = "Найди меня"
        static let results = "Результаты:"
        static let goods = "Товары"
        static let cart = "Корзина"
        static let emptyCart = "Корзина пуста"
        static let clear = "Очистить"
        static let goodsInCart = "Добавить в корзину"
        static let goToCart = "Перейти в корзину"
        static let plusInCart = "Добавить в корзину"
        static let plus = "+"
        static let minus  = "-"
        static let price = "Цена"
        static let ot = "От"
        static let Do = "До"
        static let applyFilters = "Применить фильтры"
        static let reset = "Сбросить"
        static let share = "Поделиться"
        static let noGoodsLabel = "Извините, таких товаров пока нет :("
        static let categories = [("Выберите категорию", nil), ("Аксессуары", 47), ("Дорогое", 8),
                                 ("Электроника", 2), ("Мебель", 3), ("Ноутбуки", 6),
                                 ("Одежда", 1), ("Обувь", 4), ("Разное", 5)]

    }
    
    enum Image {
        static let chevronLeft = UIImage(systemName: "chevron.left")
        static let chevronRight = UIImage(systemName: "chevron.right")
        static let squareAndArrowUp = UIImage(systemName: "square.and.arrow.up")
        static let squareAndArrowDown = UIImage(systemName: "square.and.arrow.down")
        static let filter = UIImage(systemName: "line.horizontal.3.decrease.circle")
        static let checkmark = UIImage(systemName: "checkmark")
        static let cart = UIImage(systemName: "cart")
        static let placeholderImage = UIImage(named: "placeholder")
        static let trash = UIImage(systemName: "trash")
        static let clock = UIImage(systemName: "clock.arrow.trianglehead.counterclockwise.rotate.90")

    }
    
    enum Constants {
        static let historyItemKey = "HistoryItemKey"
        static let historyItemCellIdentifier = "HistoryItemCell"
        static let sortedBy = "relevant"
    }

    enum Fonts {
        static let pouf = UIFont.systemFont(ofSize: 22, weight: .bold)
        static let subheadFont = UIFont.systemFont(ofSize: 16, weight: .semibold)
        static let textFont = UIFont.systemFont(ofSize: 14, weight: .regular)
        static let dataFont = UIFont.systemFont(ofSize: 12, weight: .light)
    }
    
    enum StringsMessage {
        static let noDescription = "Описание отсутствует"
    }
    
}