//
//  SceneDelegate.swift
//  ToDoList
//
//  Created by Niykee Moore on 29.03.2025.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        
        window.rootViewController = TodoListViewController()
        
        self.window = window
        window.makeKeyAndVisible()
    }
}

