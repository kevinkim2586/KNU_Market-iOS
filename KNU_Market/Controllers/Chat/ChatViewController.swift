import UIKit
import MessageKit
import InputBarAccessoryView
import SwiftyJSON
import IQKeyboardManagerSwift

class ChatViewController: MessagesViewController {
    
    private var viewModel: ChatViewModel!
    
    @objc private let refreshControl = UIRefreshControl()
    
    var roomUID: String = ""
    var chatRoomTitle: String = ""
    var postUploaderUID: String = ""
    var isFirstEntrance: Bool = false
    
//    weak var chatMemberViewDelegate: ChatMemberViewDelegate?
    
    deinit {
        print("❗️ ChatViewController has been DEINITIALIZED")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        IQKeyboardManager.shared.enable = false
        
        viewModel = ChatViewModel(room: roomUID,
                                  isFirstEntrance: isFirstEntrance)
    
        initialize()
        
        print("✏️ pageID: \(roomUID)")
        print("✏️ title: \(chatRoomTitle)")

    }
    
    @objc func pressedTitle() {
        print("✏️ pressedTitle")
        
        let storyboard = UIStoryboard(name: "ItemList", bundle: nil)
        
        guard let itemVC = storyboard.instantiateViewController(identifier: Constants.StoryboardID.itemVC) as? ItemViewController else { return }
        
        itemVC.hidesBottomBarWhenPushed = true
        itemVC.pageID = roomUID
        itemVC.isFromChatVC = true
        
        self.navigationController?.pushViewController(itemVC, animated: true)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.connect()
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        dismissProgressBar()
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        IQKeyboardManager.shared.enable = true
        viewModel.disconnect()
    }

    @IBAction func pressedMoreButton(_ sender: UIBarButtonItem) {
        
        viewModel.getRoomInfo()
        
        guard let chatMemberVC = self.storyboard?.instantiateViewController(identifier: Constants.StoryboardID.chatMemberVC) as? ChatMemberViewController else { return }
        
//        chatMemberVC.delegate = self
        chatMemberVC.roomInfo = viewModel.roomInfo
        chatMemberVC.postUploaderUID = viewModel.postUploaderUID
        presentPanModal(chatMemberVC)
    }
}
   

//MARK: - ChatViewDelegate - Socket Delegate Methods

extension ChatViewController: ChatViewDelegate {
    
    func didConnect() {
        dismissProgressBar()
        
        messagesCollectionView.scrollToLastItem()
        
        if viewModel.isFirstEntranceToChat {
            viewModel.sendText("\(User.shared.nickname)\(Constants.ChatSuffix.enterSuffix)")
            viewModel.isFirstEntranceToChat = false
        }
        viewModel.getChatList()
    }
    
    func didDisconnect() {
        dismissProgressBar()
        navigationController?.popViewController(animated: true)
    }
    
    func didReceiveChat() {
        dismissProgressBar()
        messagesCollectionView.reloadDataAndKeepOffset()
    }
    
    func reconnectSuggested() {
        dismissProgressBar()
        viewModel.resetMessages()
        viewModel.connect()
    }
    
    func failedConnection(with error: NetworkError) {
        dismissProgressBar()
        self.presentSimpleAlert(title: "일시적인 연결 문제 발생", message: error.errorDescription)
    }
    
    func didSendText() {
        DispatchQueue.main.async {
            self.messageInputBar.inputTextView.text = ""
            self.messagesCollectionView.scrollToLastItem()
        }
    }
    
    func didReceiveBanNotification() {
        
        messageInputBar.isUserInteractionEnabled = false
        viewModel.disconnect()
        self.presentSimpleAlert(title: "방장으로부터 강퇴 처리를 당하셨습니다.🤔", message: "")
    }

}

//MARK: - ChatViewDelegate - API Delegate Methods

extension ChatViewController {
    
    func didExitPost() {
        navigationController?.popViewController(animated: true)
    }
    
    func didDeletePost() {
        
        navigationController?.popViewController(animated: true)
        NotificationCenter.default.post(name: Notification.Name.updateItemList, object: nil)
    }
    
    func didFetchPreviousChats() {
        dismissProgressBar()

        refreshControl.endRefreshing()
        if viewModel.isFirstViewLaunch {
            
            viewModel.isFirstViewLaunch = false

            messagesCollectionView.reloadData()
            messagesCollectionView.scrollToLastItem()

        } else {
            messagesCollectionView.reloadDataAndKeepOffset()
        }

    }
    
    func didFetchEmptyChat() {
        refreshControl.endRefreshing()
    }
    
    func failedFetchingPreviousChats(with error: NetworkError) {
        dismissProgressBar()
        refreshControl.endRefreshing()
        
    }
}

////MARK: - ChatMemberViewDelegate - for PanModal
//
//extension ChatViewController: ChatMemberViewDelegate {
//
////    @objc func exitPost() {
////        viewModel.exitPost()
////
////    }
////
////    @objc func deletePost() {
////
////    }
////
////    @objc func sendBanMessageToSocket(notification: Notification) {
////
////    }
////
////
////    @objc func getChatList() {
////        viewModel.getChatList()
////    }
//
//
//
////    func didChooseToExitPost() {
////        print("✏️ didChooseToExitPost")
////        viewModel.exitPost()
////    }
////
////    func didChooseToDeletePost() {
////        viewModel.deletePost(for: self.roomUID)
////    }
////
////    func didBanUser(uid: String, nickname: String) {
////        viewModel.sendBanMessageToSocket(uid: uid, nickname: nickname)
////    }
////
////    func didDismissPanModal() {
////        viewModel.getChatList()
////    }
//}

//MARK: - InputBarAccessoryViewDelegate

extension ChatViewController: InputBarAccessoryViewDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        viewModel.sendText(text)
    }
}


//MARK: - MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate, MessageCellDelegate

extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate, MessageCellDelegate {
    
    public func currentSender() -> SenderType {
        return viewModel.mySelf
    }

    public func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        
        if viewModel.messages.count == 0 { return Message.defaultValue }

        return viewModel.messages[indexPath.section]
    }
    
    public func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return viewModel.messages.count
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        avatarView.isHidden = true
    }
    
    // Top Label
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 12
    }
    
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        
        if viewModel.messages.count == 0 { return nil }
        
        return NSAttributedString(string: viewModel.messages[indexPath.section].usernickname,
                                  attributes: [.font: UIFont.systemFont(ofSize: 12, weight: .medium)])
    }
    
    // Bottom Label
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        
        if viewModel.messages.count == 0 { return nil }
        
        return NSAttributedString(string: viewModel.messages[indexPath.section].date,
                                  attributes: [.font: UIFont.systemFont(ofSize: 10), .foregroundColor: UIColor.lightGray])
    }
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 10
    }
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        
        if viewModel.messages.count == 0 { return #colorLiteral(red: 0.8771190643, green: 0.8736019731, blue: 0.8798522949, alpha: 1) }
    
        if viewModel.messages[indexPath.section].userUID == User.shared.userUID {
            return UIColor(named: Constants.Color.appColor)!
        } else {
            return #colorLiteral(red: 0.8771190643, green: 0.8736019731, blue: 0.8798522949, alpha: 1)
        }
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(corner, .curved)
    }

    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView.contentOffset.y <= 10 {
            
            self.refreshControl.beginRefreshing()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                
                if !self.viewModel.isFetchingData &&
                    self.viewModel.needsToFetchMoreData &&
                    !self.viewModel.isFirstViewLaunch {
                    self.viewModel.getChatList()
                    
                } else {
                    self.refreshControl.endRefreshing()
                    self.messagesCollectionView.refreshControl = nil
                }
            }
        }
    }
}

//MARK: - Initialization & UI Configuration

extension ChatViewController {
    
    func initialize() {
       
        viewModel.delegate = self
//        chatMemberViewDelegate = self

        initializeNavigationItemTitle()
        initializeRefreshControl()
        initializeInputBar()
        initializeCollectionView()
    }
    
    func initializeNavigationItemTitle() {
    
        let titleButton = UIButton()
        titleButton.setTitle(chatRoomTitle, for: .normal)
    
        titleButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        titleButton.setTitleColor(.black, for: .normal)
        titleButton.addTarget(self, action: #selector(pressedTitle), for: .touchUpInside)
        
        navigationItem.titleView = titleButton
    }
    
    func initializeRefreshControl() {
        
        messagesCollectionView.refreshControl = refreshControl
        refreshControl.addTarget(self,
                                 action: #selector(viewModel.getChatList),
                                 for: .valueChanged)
    }
    
    func initializeCollectionView() {
        

        messagesCollectionView.contentInset.top = 20

        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.delegate = self
        messagesCollectionView.backgroundColor = .white
        self.scrollsToLastItemOnKeyboardBeginsEditing = true
        
        
        if let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout {
            
            layout.setMessageIncomingAvatarSize(.zero)
            layout.setMessageOutgoingAvatarSize(.zero)
            
            layout.setMessageIncomingMessageTopLabelAlignment(LabelAlignment.init(textAlignment: .left,
                                                                                  textInsets: .init(top: 20, left: 10, bottom: 20, right: 10)))
            layout.setMessageOutgoingMessageTopLabelAlignment(LabelAlignment.init(textAlignment: .right,
                                                                                  textInsets: .init(top: 20, left: 10, bottom: 20, right: 10)))
            
            layout.setMessageIncomingMessageBottomLabelAlignment(LabelAlignment.init(textAlignment: .left,
                                                                                     textInsets: .init(top: 20, left: 10, bottom: 20, right: 10)))
            layout.setMessageOutgoingMessageBottomLabelAlignment(LabelAlignment.init(textAlignment: .right,
                                                                                     textInsets: .init(top: 20, left: 10, bottom: 20, right: 10)))
        }
    }
    
    func initializeInputBar() {
        
        
        messageInputBar.delegate = self
        messageInputBar.sendButton.title = nil
        let configuration = UIImage.SymbolConfiguration(pointSize: 28, weight: .regular)
        let color = UIColor(named: Constants.Color.appColor)
        let sendButtonImage = UIImage(systemName: "arrow.up.circle.fill",
                                      withConfiguration: configuration)?.withTintColor(
                                        color ?? .systemPink,
                                        renderingMode: .alwaysOriginal
                                      )
        
        messageInputBar.sendButton.setImage(sendButtonImage, for: .normal)
    }

}
