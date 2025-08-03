//
//  ChatVC.swift
//  Telegram
//
//  Created by Danil Chekantsev on 26/07/2025.
//

import UIKit
import MessageKit
import InputBarAccessoryView

final class ChatVC: MessagesViewController {
    
    init(chat: Chat!) {
        self.chat = chat
        super.init(nibName: nil, bundle: nil)
       }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Properties
    
    var currentSender: SenderType {
        currentUser
    }
    var currentUser = Sender(
        senderId: "self",
        displayName: "me",
        lastSeenDate: .now,
        avatarURL: URL(string: "https://placehold.co/100")!
    )
    
    var messages = [Message]()
    var chat: Chat!
    var isPreviewMode: Bool = false
    
    // MARK: - LifeCycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureMessageInputBar()
        messages = chat.messages

        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
        messagesCollectionView.reloadData()
        if !messages.isEmpty {
            messagesCollectionView.scrollToLastItem(animated: false)
        }
    }
    
    // MARK: - Private methods
    
    private func configureMessageInputBar() {
        messageInputBar.inputTextView.layer.cornerRadius = 20
        messageInputBar.inputTextView.backgroundColor = .white
        messageInputBar.inputTextView.placeholder = "Message"
        messageInputBar.inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 20)
        messageInputBar.inputTextView.textContainerInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)

        messageInputBar.backgroundView.backgroundColor = .secondarySystemBackground
        messageInputBar.separatorLine.isHidden = true

        messageInputBar.middleContentViewPadding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 16)

        configureInputBarItems()
    }
    
    private func configureInputBarItems() {
        let attachButton = InputBarButtonItem()
        
        attachButton.image = UIImage(systemName: "paperclip")
        attachButton.setSize(.init(width: 36, height: 36), animated: false)
        attachButton.tintColor = .gray
        attachButton.touchUpInsideAction()
        
        messageInputBar.setLeftStackViewWidthConstant(to: 24, animated: false)
        messageInputBar.setStackViewItems([attachButton], forStack: .left, animated: false)
        
        messageInputBar.sendButton.setSize(CGSize(width: 36, height: 36), animated: false)
        messageInputBar.sendButton.image = UIImage(named: "ic_up")
        messageInputBar.sendButton.layer.cornerRadius = 8
        messageInputBar.sendButton.title = nil
        messageInputBar.sendButton.imageView?.layer.cornerRadius = 18
        messageInputBar.setRightStackViewWidthConstant(to: 32, animated: false)
        messageInputBar.middleContentViewPadding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 16)
        messageInputBar.setStackViewItems([messageInputBar.sendButton], forStack: .right, animated: false)
        
        configureInputBarPadding()
        
        messageInputBar.sendButton
            .onEnabled { item in
                UIView.animate(withDuration: 0.1, animations: {
                    item.imageView?.backgroundColor = .systemBlue
                })
            }.onDisabled { item in
                UIView.animate(withDuration: 0.1, animations: {
                    item.imageView?.backgroundColor = UIColor(white: 0.85, alpha: 1)
                })
        }
    }
    
    private func configureInputBarPadding() {
      messageInputBar.padding.bottom = 8
      messageInputBar.inputTextView.textContainerInset.bottom = 8
    }

}

// MARK: - MessagesDataSource

extension ChatVC: MessagesDataSource {
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessageKit.MessagesCollectionView) -> any MessageKit.MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessageKit.MessagesCollectionView) -> Int {
        return messages.count
    }
}

// MARK: - MessagesLayoutDelegate

extension ChatVC: MessagesLayoutDelegate {
    func avatarSize(for message: any MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize? { .zero }
    
    func messageTopLabelHeight(for _: MessageType,
                               at _: IndexPath,
                               in _: MessagesCollectionView) -> CGFloat { 16 }

    func messageBottomLabelHeight(for _: MessageType,
                                  at _: IndexPath,
                                  in _: MessagesCollectionView) -> CGFloat { 14 }
}

// MARK: - MessagesDisplayDelegate 

extension ChatVC: MessagesDisplayDelegate {
    func configureAvatarView(_ avatarView: AvatarView, for message: any MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        avatarView.isHidden = true
    }
    
    func backgroundColor(for message: MessageType,
                             at _: IndexPath,
                             in _: MessagesCollectionView) -> UIColor {
            message.sender.senderId == currentUser.senderId
            ? UIColor(red: 0.25, green: 0.77, blue: 0.96, alpha: 1)   // исходящие
            : .secondarySystemBackground                                // входящие
        }
    
    func messageStyle(for message: any MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        
        let tail: MessageStyle.TailCorner = message.sender.senderId == currentUser.senderId ? .bottomRight : .bottomLeft
        
        return .bubbleTail(tail, .curved)
    }
}

