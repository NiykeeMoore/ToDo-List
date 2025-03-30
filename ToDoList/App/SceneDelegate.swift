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
        
        let todoListModule = TodoRouter.createModule()
        let window = UIWindow(windowScene: windowScene)
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .appBlack
        appearance.titleTextAttributes = [.foregroundColor: UIColor.appWhite]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.appWhite]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        
        window.rootViewController = UINavigationController(rootViewController: todoListModule)
        
        self.window = window
        window.makeKeyAndVisible()
    }
}

