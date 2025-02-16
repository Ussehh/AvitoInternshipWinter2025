//
//  SceneDelegate.swift
//  AvitoInternshipWinter2025
//
//  Created by Никита Абаев on 10.02.2025.
//

import UIKit

class NavigationBuilder {
    static func createSearchNC() -> UIViewController {
        let presenter = SearchPresenter()
        let searchViewController = SearchViewController(presenter: presenter)
        return searchViewController
    }
    
    static func createNavController() -> UINavigationController {
        let navController = UINavigationController()
        if #available(iOS 15, *) {
            let navigationBarAppearance = UINavigationBarAppearance()
            navigationBarAppearance.configureWithOpaqueBackground()
            navigationBarAppearance.titleTextAttributes = [
                NSAttributedString.Key.foregroundColor : R.Colors.black
            ]
            navigationBarAppearance.backgroundColor = R.Colors.backgroungColor
            UINavigationBar.appearance().standardAppearance   = navigationBarAppearance
            UINavigationBar.appearance().compactAppearance    = navigationBarAppearance
            UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
        }
        navController.viewControllers = [createSearchNC()]
        return navController
    }
}

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = NavigationBuilder.createNavController()
        window?.makeKeyAndVisible()
    }
}

