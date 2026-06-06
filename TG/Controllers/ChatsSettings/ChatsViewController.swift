//
//  ChatsViewController.swift
//  Telegram
//
//  Created by Danil Chekantsev on 23/07/2025.
//

import Foundation
import UIKit


final class ChatsViewController: UIViewController {
    
    private let tableView = UITableView()
    private let searchController = UISearchController(searchResultsController: nil)
    private var chats: [Chat] = []
    private let service = ChatService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Chats"
        
        configureSearchBar()
        setupTableView()
        loadData()
    }
    
    private func loadData() {
        DispatchQueue.global().async {
            do {
                self.chats = try self.service.loadChats()
                print("Loaded chats:", self.chats.count)
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            catch {
                print("loadChats error: \(error)")
            }
        }
    }
    
    
    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.CellIdentifiers.default)
        tableView.register(ChatCell.self, forCellReuseIdentifier: ChatCell.reuseIndentifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = Constants.UI.tableViewRowHeight
        view.addSubview(tableView)
        

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }
    
}
    
// MARK: - SearchBar Setup

extension ChatsViewController: UISearchResultsUpdating, UISearchBarDelegate {
    private func configureSearchBar() {
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        
        let searchBar = searchController.searchBar
        searchBar.placeholder = "Search of messages or users"
        searchBar.autocapitalizationType = .none
        
        centerPlaceholder(in: searchBar)
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        definesPresentationContext = true
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.searchTextField.textAlignment = .left
        searchBar.setPositionAdjustment(.zero, for: .search)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if searchBar.text?.isEmpty ?? true {
        }
    }
    
     func centerPlaceholder(in searchBar: UISearchBar) {
        
    }
    
}

// MARK: - UITableView DataSource

extension ChatsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        chats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ChatCell.reuseIndentifier, for: indexPath) as! ChatCell
        cell.configure(with: chats[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chat = chats[indexPath.row]
        let vc = ChatVC(chat: chat)
        vc.title = chat.title
        vc.chat = chat
        vc.delegate = self
        vc.chatIndex = indexPath.row
        
        navigationController?.pushViewController(vc, animated: true)
    
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ChatVC,
           let row = tableView.indexPathForSelectedRow?.row {
            vc.chat = chats[row]
        }
    }
}

// MARK: - UITableView Delegate

extension ChatsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let mute = UIContextualAction(style: .normal, title: "Mute") { action, view, completion in
            print("Muted chat: \(self.chats[indexPath.row].title)")
            
            self.chats[indexPath.row].isMuted.toggle()
            tableView.reloadRows(at: [indexPath], with: .none)
            
            completion(true)
        }
        
        mute.image = UIImage(named: "muteIcon")
        mute.backgroundColor = Constants.Colors.muteBackgroundColor
        
        let delete = UIContextualAction(style: .destructive, title: "Delete") { action, view, completion in
            self.chats.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            completion(true)
        }
        
        delete.image = UIImage(named: "deleteIcon")
        delete.backgroundColor = Constants.Colors.deleteBackgroundColor
        
        let archive = UIContextualAction(style: .normal, title: "Archive") { action, view, completion in
            
        }
        archive.image = UIImage(named: "archiveIcon")
        archive.backgroundColor = Constants.Colors.archiveBackgroundColor
        
        return UISwipeActionsConfiguration(actions: [archive,delete,mute])
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let pin = UIContextualAction(style: .normal, title: "Pin") { action, view, completion in
            
        }
        pin.image = UIImage(named: "pinIcon")
        pin.backgroundColor = Constants.Colors.pinBackgroundColor
        
        let unread = UIContextualAction(style: .normal, title: "Unread") { action, view, completion in
            
        }
        unread.image = UIImage(named: "unreadIcon")
        unread.backgroundColor = Constants.Colors.unreadBackgroundColor
        
        return UISwipeActionsConfiguration(actions: [unread, pin])
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let chat = chats[indexPath.row]
        
        return UIContextMenuConfiguration(
            identifier: indexPath as NSCopying,
            previewProvider: {
                let previewVC = ChatVC(chat: chat)
                previewVC.isPreviewMode = true
                
                return UINavigationController(rootViewController: previewVC)
            },
            actionProvider: { _ in
                let markAsUnread = UIAction(title: "Mark as unread", image: UIImage(systemName: "message.badge.fill")) { _ in }
                let pinAction = UIAction(title: "Pin", image: UIImage(systemName: "pin")) { _ in }
                let muteAction = UIAction(title: "Mute", image: UIImage(systemName: "volume.slash.fill")) { _ in
                    self.chats[indexPath.row].isMuted.toggle()
                    tableView.reloadRows(at: [indexPath], with: .none)
                }
                let deleteAction = UIAction(title: "Delete", image: UIImage(systemName: "trash")) { _ in }
                deleteAction.attributes = [.destructive]
                
                return UIMenu(title: "", children: [markAsUnread, pinAction, muteAction, deleteAction])
            }
                
            )
    }
    
    func tableView(_ tableView: UITableView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: any UIContextMenuInteractionCommitAnimating) {
        animator.addCompletion {
            if let indexPath = configuration.identifier as? IndexPath {
                let chat = self.chats[indexPath.row]
                let vc = ChatVC(chat: chat)
                vc.isPreviewMode = false
                vc.delegate = self
                
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
}

extension ChatsViewController: ChatViewDelegate {
    func didReadChat(at index: Int) {
        guard index < chats.count else { return }
        chats[index].unreadCount = 0
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: index, section: 0)
            self.tableView.reloadRows(at: [indexPath], with: .none)
        }
    }
}


extension ChatsViewController {
    enum Constants {
        enum UI {
            static let tableViewRowHeight: CGFloat = 72
        }
        
        enum CellIdentifiers {
            static let `default` = "cell"
        }
        
        enum Colors {
            static let muteBackgroundColor: UIColor = .systemOrange
            static let deleteBackgroundColor: UIColor = .systemRed
            static let archiveBackgroundColor: UIColor = .systemGray
            static let pinBackgroundColor: UIColor = .systemGreen
            static let unreadBackgroundColor: UIColor = .systemBlue
        }
    }
}

    
