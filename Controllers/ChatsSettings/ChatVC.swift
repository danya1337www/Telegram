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
            forCellWithReuseIdentifier:
                Constants.CellIdentifiers.textMessageCell
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
    
    private func setupAvatarImageView() -> UIImageView {
        let imageView = UIImageView()
        if let sender = chat.lastMessage?.sender as? Sender {
            imageView.load(from: sender.avatarURL)
        } else {
            imageView.image = UIImage(named: "avatar-placeholder")
        }
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = Constants.UI.avatarCornerRadius
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false 
        imageView.isUserInteractionEnabled = true
        
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: Constants.UI.avatarImageSize),
            imageView.heightAnchor.constraint(equalToConstant: Constants.UI.avatarImageSize)
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
        
        let appeareance = UINavigationBarAppearance()
        appeareance.backgroundColor = Constants.Colors.appeareanceBackgroundColor
        
        let rightBarButton = UIBarButtonItem(customView: setupAvatarImageView())
        let chatName = setupChatNameLabel()
        let lastSeen = setupLastSeenLabel()
        
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
        messageInputBar.inputTextView.layer.borderColor = Constants.Colors.inputTextViewBorderColor
        messageInputBar.inputTextView.layer.borderWidth = Constants.UI.inputTextViewBorderWidth
        messageInputBar.inputTextView.placeholder = "Message"
        
        messageInputBar.inputTextView.textContainerInset = Constants.UI.inputTextViewTextContainerInset
        messageInputBar.inputTextView.placeholderLabelInsets = Constants.UI.inputTextViewPlaceholderLabelInsets
        
        messageInputBar.backgroundView.backgroundColor = Constants.Colors.incomingMessage
        messageInputBar.separatorLine.isHidden = true

        configureInputBarItems()
        configureSendButtonAppeareance(forText: "")
    }
    
    private func configureSendMessageButton() {
        messageInputBar.sendButton.setSize(Constants.UI.sendButtonSize, animated: false)
        animateSendButtonImage(to: UIImage(named: "ic_up"))
        messageInputBar.setRightStackViewWidthConstant(to: 32, animated: false)
        messageInputBar.middleContentViewPadding = Constants.UI.middleContentViewPadding
    }
    
    private func configureAudioMessageButton() {
        animateSendButtonImage(to: UIImage(named: "microphone"))
    
        messageInputBar.sendButton.setSize(Constants.UI.sendButtonSize, animated: false)
        messageInputBar.setRightStackViewWidthConstant(to: 32, animated: false)
        messageInputBar.middleContentViewPadding = Constants.UI.middleContentViewPadding
    }
    
    private func animateSendButtonImage(to newImage: UIImage?) {
        guard let imageView = messageInputBar.sendButton.imageView else { return }
    
        if imageView.image === newImage { return }
        
        UIView.transition(
            with: messageInputBar.sendButton,
            duration: Constants.UI.UIViewDuration,
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
    
    private func configureInputBarItems() {
        let attachButton = InputBarButtonItem()
        attachButton.image = UIImage(named: "attach")
        attachButton.setSize(Constants.UI.sendButtonSize, animated: false)
        attachButton.tintColor = Constants.Colors.attachButtonTintColor
        attachButton.touchUpInsideAction()
        
        messageInputBar.setLeftStackViewWidthConstant(to: Constants.UI.messageInputBarSetLeftStackViewWidthConstant, animated: false)
        messageInputBar.setStackViewItems([attachButton], forStack: .left, animated: false)
        messageInputBar.setStackViewItems([messageInputBar.sendButton], forStack: .right, animated: false)

        let textView = messageInputBar.inputTextView
        textView.layer.cornerRadius = Constants.UI.textViewCornerRadius
        textView.backgroundColor = Constants.Colors.textViewBackgroundColor


        configureInputBarPadding()
    }
    
    private func configureInputBarPadding() {
        messageInputBar.padding.bottom = Constants.UI.messageInputBarPadding
        messageInputBar.inputTextView.textContainerInset.bottom = Constants.UI.messageInputBarInputTextViewTextContainerInset
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
                               in _: MessagesCollectionView) -> CGFloat { Constants.UI.messageTopLabelHeight }
    
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
        ? Constants.Colors.outgoingMessage  // исходящие
        : Constants.Colors.incomingMessage  // входящие
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

// MARK: - Constants

private extension ChatVC{
    enum Constants {
        enum UI {
            static let cellHeight: CGFloat = 72
            static let avatarSize: CGFloat = 36
            static let avatarCornerRadius: CGFloat = 18
            static let avatarImageSize: CGFloat = 36
            
            static let sendButtonSize = CGSize(width: 36, height: 36)
            static let inputTextViewBorderWidth: CGFloat = 1
            static let textViewCornerRadius: CGFloat = 20
            static let middleContentViewPadding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 16)
            static let inputTextViewTextContainerInset = UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 44)
            static let inputTextViewPlaceholderLabelInsets = UIEdgeInsets(top: 8, left: 22, bottom: 8, right: 42)
            static let messageInputBarPadding: CGFloat = 8
            static let messageInputBarInputTextViewTextContainerInset: CGFloat = 8
            static let messageInputBarSetLeftStackViewWidthConstant: CGFloat = 36
            static let messageTopLabelHeight: CGFloat = 16
            
            static let UIViewDuration: CGFloat = 0.15
        }
        
        enum CellIdentifiers {
            static let `default` = "cell"
            static let textMessageCell = "TextMessageCell"
        }
        
        enum Colors {
            static let outgoingMessage = UIColor(red: 0.25, green: 0.77, blue: 0.96, alpha: 1)
            static let attachButtonTintColor = UIColor(red: 133/255, green: 142/255, blue: 153/255, alpha: 1.0)
            static let incomingMessage: UIColor = .secondarySystemBackground
            static let inputTextViewBorderColor = UIColor.systemGray4.cgColor
            static let appeareanceBackgroundColor: UIColor = .systemBackground
            static let textViewBackgroundColor: UIColor = .white
        }
    }
}

