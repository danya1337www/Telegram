//
//  TabBarController.swift
//  Telegram
//
//  Created by Danil Chekantsev on 23/07/2025.
//

import UIKit

final class TabBarController: UITabBarController {
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupTabs()
    }
    
    
    // MARK: - Private methods
    
    private func setupTabs() {
        let contactsVC = self.setupNavController(
            with: "Contacts",
            and: UIImage(systemName: "person.crop.circle.fill"),
            vc: ContactsViewController()
        )
        
        let callsVC = self.setupNavController(
            with: "Calls",
            and: UIImage(systemName: "phone.fill"),
            vc: CallsViewController()
        )
        
        let chatsVC = self.setupNavController(
            with: "Chats",
            and: UIImage(systemName: "message.fill"),
            leftBarButton: UIBarButtonItem(
                barButtonSystemItem: .edit,
                target: self,
                action: nil
            ),
            rightBarButton: UIBarButtonItem(
                image: UIImage(systemName: "square.and.pencil"),
                style: .plain,
                target: self,
                action: nil
            ),
            vc: ChatsViewController()
        )
        
        let settingsVC = self.setupNavController(
            with: "Settings",
            and: UIImage(systemName: "gear"),
            vc: SettingsViewController()
        )
        
        self.setViewControllers([contactsVC, callsVC, chatsVC, settingsVC], animated: true)
    }
    
    private func setupNavController(
        with title: String,
        and image: UIImage?,
        leftBarButton: UIBarButtonItem? = nil,
        rightBarButton: UIBarButtonItem? = nil,
        badge: String? = nil,
        vc: UIViewController
    ) -> UINavigationController {
        
        vc.navigationItem.title = title
        vc.navigationItem.rightBarButtonItem = rightBarButton
        vc.navigationItem.leftBarButtonItem = leftBarButton
        
        let nav = UINavigationController(rootViewController: vc)
        
        nav.tabBarItem = UITabBarItem(title: title, image: image, selectedImage: nil)
        nav.tabBarItem.badgeValue = badge        
        
        return nav
    }
}







