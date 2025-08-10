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
        configureNavController()
        tabBarController?.tabBar.isHidden = true
        
        if let offset = chat.lastOffset {
            DispatchQueue.main.async {
                self.messagesCollectionView.setContentOffset(offset, animated: false)
            }
        } else {
            scrollToLastMessage(animated: true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
        chat.lastOffset = messagesCollectionView.contentOffset
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self

        messagesCollectionView.register(
            TimeTextMessageCell.self,
            forCellWithReuseIdentifier: "TextMessageCell"
        )

        if let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout {
            layout.textMessageSizeCalculator = TimeTextMessageSizeCalculator(layout: layout)
        }

        configureMessageInputBar()
        configureInputBarItems()

        messages = chat.messages
        messagesCollectionView.reloadData()
        messagesCollectionView.backgroundView = UIImageView(image: UIImage(named: "backgroundImage"))
    }
    
    // MARK: - Private methods
    
    private func setupAvatarImageView() -> UIImageView{
        let imageView = UIImageView()
        if let sender = chat.lastMessage?.sender as? Sender{
            imageView.load(from: sender.avatarURL)
        } else {
            imageView.image = UIImage(named: "avatar-placeholder")
        }
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 18
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false 
        imageView.isUserInteractionEnabled = true
        
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 36),
            imageView.heightAnchor.constraint(equalToConstant: 36)
        ])
        
        return imageView
    }
    
    private func setupLastSeenLabel() -> UILabel {
        let lastSeen = UILabel()
        lastSeen.text = "last seen recently"
        lastSeen.font = .systemFont(ofSize: 13, weight: .regular)
        lastSeen.textColor = .systemGray
        
        return lastSeen
    }
    
    private func setupChatNameLabel() -> UILabel {
        let chatName = UILabel()
        chatName.text = chat.title
        chatName.font = .systemFont(ofSize: 16, weight: .bold)
        chatName.textColor = .label
        
        return chatName
    }
    
    private func configureNavController() {
        
        // MARK: - Appeareance
        let appeareance = UINavigationBarAppearance()
        appeareance.backgroundColor = .systemBackground
        
        // MARK: - RightBarButton
        let rightBarButton = UIBarButtonItem(customView: setupAvatarImageView())
        
        // MARK: - ChatName
        let chatName = setupChatNameLabel()
        
        // MARK: - LastSeen
        let lastSeen = setupLastSeenLabel()
        
        // MARK: - StackView
        let stackView = UIStackView(arrangedSubviews: [chatName, lastSeen])
        stackView.axis = .vertical
        stackView.alignment = .center
        
        self.navigationController?.navigationBar.standardAppearance = appeareance
        self.navigationController?.navigationBar.scrollEdgeAppearance = appeareance
        self.navigationController?.isNavigationBarHidden = false
        self.navigationItem.rightBarButtonItem = rightBarButton
        self.navigationItem.titleView = stackView
    }
    
    @objc private func avatarTapped() {
        
    }
    
    private func scrollToLastMessage(animated: Bool) {
        DispatchQueue.main.async {
            self.messagesCollectionView.layoutIfNeeded()
            if !self.messages.isEmpty {
                self.messagesCollectionView.scrollToLastItem(animated: animated)
            }
        }
    }
    
    private func configureMessageInputBar() {
        messageInputBar.inputTextView.layer.borderColor = UIColor.systemGray4.cgColor
        messageInputBar.inputTextView.layer.borderWidth = 1
        messageInputBar.inputTextView.placeholder = "Message"
        
        messageInputBar.inputTextView.textContainerInset = UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 44)
        messageInputBar.inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 8, left: 22, bottom: 8, right: 42)
        
        messageInputBar.backgroundView.backgroundColor = .secondarySystemBackground
        messageInputBar.separatorLine.isHidden = true

        configureInputBarItems()
        configureSendButtonAppeareance(forText: "")
    }
    
    private func configureSendMessageButton() {
        messageInputBar.sendButton.setSize(CGSize(width: 36, height: 36), animated: false)
        animateSendButtonImage(to: UIImage(named: "ic_up"))
        messageInputBar.setRightStackViewWidthConstant(to: 32, animated: false)
        messageInputBar.middleContentViewPadding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 16)
    }
    
    private func configureAudioMessageButton() {
        animateSendButtonImage(to: UIImage(named: "microphone"))
    
        messageInputBar.sendButton.setSize(CGSize(width: 36, height: 36), animated: false)
        messageInputBar.setRightStackViewWidthConstant(to: 32, animated: false)
        messageInputBar.middleContentViewPadding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 16)
    }
    
    private func animateSendButtonImage(to newImage: UIImage?) {
        guard let imageView = messageInputBar.sendButton.imageView else { return }
    
        if imageView.image === newImage { return }
        
        UIView.transition(
            with: messageInputBar.sendButton,
            duration: 0.15,
            options: .transitionCrossDissolve,
            animations: {
                self.messageInputBar.sendButton.setImage(newImage, for: .normal)
            },
            completion: nil)
    }
    
    private func configureSendButtonAppeareance(forText text: String?) {
        messageInputBar.sendButton.title = nil
        messageInputBar.sendButton.setImage(UIImage(named: "microphone"), for: .normal)
        if let text, text.isEmpty {
                configureAudioMessageButton()
        } else {
                configureSendMessageButton()
            }
    }
    
//    private func addStickersButtonToInputTextView() {
//        let buttonSize: CGFloat = 24
//
//        let stickersButton = UIButton(type: .system)
//        stickersButton.setImage(UIImage(named: "stickers"), for: .normal)
//        stickersButton.tintColor = UIColor(red: 133/255, green: 142/255, blue: 153/255, alpha: 1.0)
//
//        stickersButton.translatesAutoresizingMaskIntoConstraints = false
//        let textView = messageInputBar.inputTextView
//        textView.addSubview(stickersButton)
//
//        NSLayoutConstraint.activate([
//            stickersButton.trailingAnchor.constraint(equalTo: textView.trailingAnchor, constant: -8),
//            stickersButton.centerYAnchor.constraint(equalTo: textView.centerYAnchor),
//            stickersButton.widthAnchor.constraint(equalToConstant: buttonSize),
//            stickersButton.heightAnchor.constraint(equalToConstant: buttonSize)
//        ])
//        let inset = buttonSize + 12
//        textView.textContainerInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: inset)
//        textView.placeholderLabelInsets = UIEdgeInsets(top: 8, left: 20, bottom: 8, right: inset)
//    }
    
    
    private func configureInputBarItems() {
        let attachButton = InputBarButtonItem()
        attachButton.image = UIImage(named: "attach")
        attachButton.setSize(.init(width: 36, height: 36), animated: false)
        attachButton.tintColor = UIColor(red: 133/255, green: 142/255, blue: 153/255, alpha: 1.0)
        attachButton.touchUpInsideAction()
        
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        messageInputBar.setStackViewItems([attachButton], forStack: .left, animated: false)
        messageInputBar.setStackViewItems([messageInputBar.sendButton], forStack: .right, animated: false)

        let textView = messageInputBar.inputTextView
        textView.layer.cornerRadius = 20
        textView.backgroundColor = .white


        configureInputBarPadding()
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

extension ChatVC: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {
        configureSendButtonAppeareance(forText: text)
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        let newMessage = Message(
            sender: currentUser,
            messageId: UUID().uuidString,
            sentDate: Date(),
            kind: .text(text)
        )
        
        messages.append(newMessage)
        messagesCollectionView.reloadData()
        messagesCollectionView.scrollToLastItem(animated: true)
        
        inputBar.inputTextView.text = ""
    }
}

