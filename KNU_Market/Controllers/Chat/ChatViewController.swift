//import UIKit
//import MessageKit
//import InputBarAccessoryView
////import MessageInputBar
//import SwiftyJSON
//import IQKeyboardManagerSwift
//
//class ChatViewController: MessagesViewController {
//
//    private var viewModel: ChatViewModel!
//
//    @objc private let refreshControl = UIRefreshControl()
//
//    var roomUID: String = ""
//    var chatRoomTitle: String = ""
//    var postUploaderUID: String = ""
//    var isFirstEntrance: Bool = false
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        IQKeyboardManager.shared.enable = false
//
//        viewModel = ChatViewModel(room: roomUID,
//                                  isFirstEntrance: isFirstEntrance)
//
//        initialize()
//
//
//
//        print("✏️ pageID: \(roomUID)")
//        print("✏️ title: \(chatRoomTitle)")
//
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        viewModel.connect()
//    }
//
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        self.navigationController?.setNavigationBarHidden(false, animated: true)
//    }
//
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        dismissProgressBar()
//    }
//
//    override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidDisappear(animated)
//        print("✏️ viewDidDisappear")
//        IQKeyboardManager.shared.enable = true
//        viewModel.disconnect()
//    }
//
//    @objc func pressedTitle() {
//
//        let storyboard = UIStoryboard(name: "ItemList", bundle: nil)
//
//        guard let itemVC = storyboard.instantiateViewController(identifier: Constants.StoryboardID.itemVC) as? ItemViewController else { return }
//
//        itemVC.hidesBottomBarWhenPushed = true
//        itemVC.pageID = roomUID
//        itemVC.isFromChatVC = true
//
//        self.navigationController?.pushViewController(itemVC, animated: true)
//    }
//
//
//    @IBAction func pressedMoreButton(_ sender: UIBarButtonItem) {
//
//        viewModel.getRoomInfo()
//
//        guard let chatMemberVC = self.storyboard?.instantiateViewController(identifier: Constants.StoryboardID.chatMemberVC) as? ChatMemberViewController else { return }
//
//        chatMemberVC.roomInfo = viewModel.roomInfo
//        chatMemberVC.postUploaderUID = viewModel.postUploaderUID
//        presentPanModal(chatMemberVC)
//    }
//
//    func showChatPrecautionMessage() {
//
//        presentKMAlertOnMainThread(title: "채팅 에티켓 공지!",
//                                   message: "폭력적이거나 선정적인 말은 삼가 부탁드립니다. 타 이용자로부터 신고가 접수되면 서비스 이용이 제한될 수 있습니다.",
//                                   buttonTitle: "확인")
//
//    }
//}
//
//
////MARK: - ChatViewDelegate - Socket Delegate Methods
//
//extension ChatViewController: ChatViewDelegate {
//
//    func didConnect() {
//        dismissProgressBar()
//
//        messagesCollectionView.scrollToLastItem()
//
//        if viewModel.isFirstEntranceToChat {
//            viewModel.sendText("\(User.shared.nickname)\(Constants.ChatSuffix.enterSuffix)")
//            viewModel.isFirstEntranceToChat = false
//            showChatPrecautionMessage()
//        }
//        viewModel.getChatList()
//    }
//
//    func didDisconnect() {
//        dismissProgressBar()
//        navigationController?.popViewController(animated: true)
//    }
//
//    func didReceiveChat() {
//        dismissProgressBar()
//        messagesCollectionView.backgroundView = nil
//        messagesCollectionView.reloadDataAndKeepOffset()
//    }
//
//    func reconnectSuggested() {
//        dismissProgressBar()
//        viewModel.resetMessages()
//        viewModel.connect()
//    }
//
//    func failedConnection(with error: NetworkError) {
//        dismissProgressBar()
//        presentKMAlertOnMainThread(title: "일시적인 연결 문제 발생", message: error.errorDescription, buttonTitle: "확인")
//    }
//
//    func didSendText() {
//        DispatchQueue.main.async {
//            self.messageInputBar.inputTextView.text = ""
//            self.messagesCollectionView.scrollToLastItem()
//        }
//    }
//
//    func didReceiveBanNotification() {
//        messageInputBar.isUserInteractionEnabled = false
//        messageInputBar.isHidden = true
//        viewModel.disconnect()
//        viewModel.resetMessages()
//
//        messagesCollectionView.isScrollEnabled = false
//
//        presentKMAlertOnMainThread(title: "강퇴 당하셨습니다.", message: "방장에 의해 강퇴되었습니다. 더 이상 채팅에 참여가 불가능합니다.🤔", buttonTitle: "확인")
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//            self.navigationController?.popViewController(animated: true)
//        }
//    }
//    func failedUploadingImageToServer() {
//
//    }
//
//}
//
////MARK: - ChatViewDelegate - API Delegate Methods
//
//extension ChatViewController {
//
//    func didExitPost() {
//        navigationController?.popViewController(animated: true)
//    }
//
//    func didDeletePost() {
//
//        navigationController?.popViewController(animated: true)
//        NotificationCenter.default.post(name: .updateItemList, object: nil)
//    }
//
//    func didFetchPreviousChats() {
//
//        dismissProgressBar()
//        messagesCollectionView.backgroundView = nil
//        refreshControl.endRefreshing()
//
//        if viewModel.isFirstViewLaunch {
//
//            viewModel.isFirstViewLaunch = false
//            messagesCollectionView.reloadData()
//            messagesCollectionView.scrollToLastItem()
//
//        } else {
//            messagesCollectionView.reloadDataAndKeepOffset()
//        }
//
//        if viewModel.messages.count == 0 {
//            messagesCollectionView.showEmptyChatView()
//        }
//    }
//
//    func didFetchEmptyChat() {
//        refreshControl.endRefreshing()
//
//        if viewModel.messages.count == 0 {
//            messagesCollectionView.showEmptyChatView()
//        }
//    }
//
//    func failedFetchingPreviousChats(with error: NetworkError) {
//        presentKMAlertOnMainThread(title: "서비스 오류 발생", message: error.errorDescription, buttonTitle: "확인")
//        dismissProgressBar()
//        refreshControl.endRefreshing()
//    }
//}
//
////MARK: - InputBarAccessoryViewDelegate
//
//extension ChatViewController: InputBarAccessoryViewDelegate {
//
//    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
//        viewModel.sendText(text)
//        messagesCollectionView.scrollToLastItem()
//
//    }
//}
//
//
////MARK: - MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate, MessageCellDelegate
//
//extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate, MessageCellDelegate {
//
//    public func currentSender() -> SenderType {
//        return viewModel.mySelf
//    }
//
//    public func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
//
//        if viewModel.messages.count == 0 { return Message.defaultValue }
//        return viewModel.messages[indexPath.section]
//    }
//
//    public func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
//        return viewModel.messages.count
//    }
//
//    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
//        avatarView.isHidden = true
//    }
//
//    // Top Label
//    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
//
//        if viewModel.messages.count == 0 { return 0 }
//
//        if viewModel.messages[indexPath.section].userUID == User.shared.userUID { return 0 }
//        else { return 12 }
//    }
//
//    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
//
//        if viewModel.messages.count == 0 { return nil }
//        if viewModel.messages[indexPath.section].userUID == User.shared.userUID { return nil }
//        else {
//            return NSAttributedString(string: viewModel.messages[indexPath.section].usernickname,
//                                      attributes: [.font: UIFont.systemFont(ofSize: 12, weight: .medium),
//                                                   .foregroundColor : UIColor.darkGray])
//        }
//    }
//
//    // Bottom Label
//    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
//
//        if viewModel.messages.count == 0 { return nil }
//        return NSAttributedString(string: viewModel.messages[indexPath.section].date,
//                                  attributes: [.font: UIFont.systemFont(ofSize: 10), .foregroundColor: UIColor.lightGray])
//    }
//
//    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
//        return 10
//    }
//
//    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
//
//        if viewModel.messages.count == 0 { return #colorLiteral(red: 0.8771190643, green: 0.8736019731, blue: 0.8798522949, alpha: 1) }
//        if viewModel.messages[indexPath.section].userUID == User.shared.userUID {
//            return UIColor(named: Constants.Color.appColor)!
//        } else {
//            return #colorLiteral(red: 0.8771190643, green: 0.8736019731, blue: 0.8798522949, alpha: 1)
//        }
//    }
//
//    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
//        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
//        return .bubbleTail(corner, .curved)
//    }
//
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//
//        if scrollView.contentOffset.y <= 10 {
//
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
//
//                if !self.viewModel.isFetchingData &&
//                    self.viewModel.needsToFetchMoreData &&
//                    !self.viewModel.isFirstViewLaunch {
//                    self.refreshControl.beginRefreshing()
//                    self.viewModel.getChatList()
//
//                } else {
//                    self.refreshControl.endRefreshing()
//                    self.messagesCollectionView.refreshControl = nil
//                }
//            }
//        }
//    }
//}
//
////MARK: - Initialization & UI Configuration
//
//extension ChatViewController {
//
//    func initialize() {
//
//        viewModel.delegate = self
//
//        initializeNavigationItemTitle()
//        initializeRefreshControl()
//        initializeInputBar()
//        initializeCollectionView()
//        createObservers()
//    }
//
//    func initializeNavigationItemTitle() {
//
//        let titleButton = UIButton()
//        titleButton.setTitle(chatRoomTitle, for: .normal)
//
//        titleButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
//        titleButton.setTitleColor(.black, for: .normal)
//        titleButton.addTarget(self, action: #selector(pressedTitle), for: .touchUpInside)
//
//        navigationItem.titleView = titleButton
//    }
//
//    func initializeRefreshControl() {
//
//        messagesCollectionView.refreshControl = refreshControl
//        refreshControl.addTarget(self,
//                                 action: #selector(viewModel.getChatList),
//                                 for: .valueChanged)
//    }
//
//    func initializeCollectionView() {
//
//        messagesCollectionView.contentInset.top = 20
//
//        messagesCollectionView.messagesDataSource = self
//        messagesCollectionView.messagesLayoutDelegate = self
//        messagesCollectionView.messagesDisplayDelegate = self
//        messagesCollectionView.messageCellDelegate = self
//        messagesCollectionView.delegate = self
//        messagesCollectionView.backgroundColor = .white
//        scrollsToLastItemOnKeyboardBeginsEditing = true
//
//        if let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout {
//
//            layout.setMessageIncomingAvatarSize(.zero)
//            layout.setMessageOutgoingAvatarSize(.zero)
//
//            layout.setMessageIncomingMessageTopLabelAlignment(LabelAlignment.init(textAlignment: .left,
//                                                                                  textInsets: .init(top: 30, left: 15, bottom: 30, right: 10)))
//            layout.setMessageOutgoingMessageTopLabelAlignment(LabelAlignment.init(textAlignment: .right,
//                                                                                  textInsets: .init(top: 20, left: 10, bottom: 20, right: 10)))
//
//            layout.setMessageIncomingMessageBottomLabelAlignment(LabelAlignment.init(textAlignment: .left,
//                                                                                     textInsets: .init(top: 20, left: 15, bottom: 20, right: 10)))
//            layout.setMessageOutgoingMessageBottomLabelAlignment(LabelAlignment.init(textAlignment: .right,
//                                                                                     textInsets: .init(top: 20, left: 10, bottom: 20, right: 15)))
//        }
//    }
//
//    func initializeInputBar() {
//
//        messageInputBar.delegate = self
//        messageInputBar.sendButton.title = nil
//        let configuration = UIImage.SymbolConfiguration(pointSize: 28, weight: .regular)
//        let color = UIColor(named: Constants.Color.appColor)
//        let sendButtonImage = UIImage(systemName: "arrow.up.circle.fill",
//                                      withConfiguration: configuration)?.withTintColor(
//                                        color ?? .systemPink,
//                                        renderingMode: .alwaysOriginal
//                                      )
//
//        messageInputBar.sendButton.setImage(sendButtonImage, for: .normal)
//
//    }
//
//    @objc func didBlockUser() {
//        presentKMAlertOnMainThread(title: "차단 완료!",
//                                   message: "해당 사용자의 채팅이 더 이상 화면에 나타나지 않습니다.",
//                                   buttonTitle: "확인")
//
//    }
//
//    func createObservers() {
//
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(didBlockUser),
//                                               name: .didBlockUser,
//                                               object: nil)
//    }
//}



import UIKit
import MessageKit
import InputBarAccessoryView
import SafariServices
import SwiftyJSON
import SDWebImage
import IQKeyboardManagerSwift
import ImageSlideshow
import Hero

class ChatViewController: MessagesViewController {
    
    private var viewModel: ChatViewModel!

    @objc private let refreshControl = UIRefreshControl()

    var roomUID: String = ""
    var chatRoomTitle: String = ""
    var postUploaderUID: String = ""
    var isFirstEntrance: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        IQKeyboardManager.shared.enable = false

        viewModel = ChatViewModel(room: roomUID,
                                  isFirstEntrance: isFirstEntrance)

        initialize()
        print("✏️ pageID: \(roomUID)")
        print("✏️ title: \(chatRoomTitle)")
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

    @objc func pressedTitle() {

        let storyboard = UIStoryboard(name: "ItemList", bundle: nil)

        guard let itemVC = storyboard.instantiateViewController(identifier: Constants.StoryboardID.itemVC) as? ItemViewController else { return }

        itemVC.hidesBottomBarWhenPushed = true
        itemVC.pageID = roomUID
        itemVC.isFromChatVC = true

        self.navigationController?.pushViewController(itemVC, animated: true)
    }


    @IBAction func pressedMoreButton(_ sender: UIBarButtonItem) {

        viewModel.getRoomInfo()

        guard let chatMemberVC = self.storyboard?.instantiateViewController(identifier: Constants.StoryboardID.chatMemberVC) as? ChatMemberViewController else { return }

        chatMemberVC.roomInfo = viewModel.roomInfo
        chatMemberVC.postUploaderUID = viewModel.postUploaderUID
        presentPanModal(chatMemberVC)
    }
    
    @objc func pressedCheckButton() {

        let actionSheet = UIAlertController(title: "모집 상태 변경",
                                            message: nil,
                                            preferredStyle: .actionSheet)
        
        
        
        present(actionSheet, animated: true)
    }
    
    func showChatPrecautionMessage() {

        presentKMAlertOnMainThread(title: "채팅 에티켓 공지!",
                                   message: "폭력적이거나 선정적인 말은 삼가 부탁드립니다. 타 이용자로부터 신고가 접수되면 서비스 이용이 제한될 수 있습니다.",
                                   buttonTitle: "확인")

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
            showChatPrecautionMessage()
        }
    
        viewModel.getChatList()
    }

    func didDisconnect() {
        dismissProgressBar()
        navigationController?.popViewController(animated: true)
    }

    func didReceiveChat() {
        dismissProgressBar()
        messagesCollectionView.backgroundView = nil
        messagesCollectionView.reloadDataAndKeepOffset()
    }

    func reconnectSuggested() {
        dismissProgressBar()
        viewModel.resetMessages()
        viewModel.connect()
    }

    func failedConnection(with error: NetworkError) {
        dismissProgressBar()
        presentKMAlertOnMainThread(title: "일시적인 연결 문제 발생", message: error.errorDescription, buttonTitle: "확인")
    }

    func didSendText() {
        DispatchQueue.main.async {
            self.messageInputBar.inputTextView.text = ""
            self.messagesCollectionView.scrollToLastItem()
        }
    }

    func didReceiveBanNotification() {
        messageInputBar.isUserInteractionEnabled = false
        messageInputBar.isHidden = true
        viewModel.disconnect()
        viewModel.resetMessages()

        messagesCollectionView.isScrollEnabled = false

        presentKMAlertOnMainThread(title: "강퇴 당하셨습니다.", message: "방장에 의해 강퇴되었습니다. 더 이상 채팅에 참여가 불가능합니다.🤔", buttonTitle: "확인")

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.navigationController?.popViewController(animated: true)
        }
    }
}

//MARK: - ChatViewDelegate - API Delegate Methods

extension ChatViewController {

    func didExitPost() {
        navigationController?.popViewController(animated: true)
    }

    func didDeletePost() {

        navigationController?.popViewController(animated: true)
        NotificationCenter.default.post(name: .updateItemList, object: nil)
    }

    func didFetchPreviousChats() {

        dismissProgressBar()
        messagesCollectionView.backgroundView = nil
        refreshControl.endRefreshing()

        if viewModel.isFirstViewLaunch {

            viewModel.isFirstViewLaunch = false
            messagesCollectionView.reloadData()
            messagesCollectionView.scrollToLastItem()

        } else {
            messagesCollectionView.reloadDataAndKeepOffset()
        }

        if viewModel.messages.count == 0 {
            messagesCollectionView.showEmptyChatView()
        }
    }

    func didFetchEmptyChat() {
        refreshControl.endRefreshing()

        if viewModel.messages.count == 0 {
            messagesCollectionView.showEmptyChatView()
        }
    }

    func failedFetchingPreviousChats(with error: NetworkError) {
        presentKMAlertOnMainThread(title: "서비스 오류 발생",
                                   message: error.errorDescription,
                                   buttonTitle: "확인")
        dismissProgressBar()
        refreshControl.endRefreshing()
    }

    func failedUploadingImageToServer() {
        dismissProgressBar()
        presentKMAlertOnMainThread(title: "사진 업로드 실패",
                                   message: "사진 용량이 너무 크거나 일시적인 오류로 업로드에 실패하였습니다. 잠시 후 다시 시도해주세요.😥",
                                   buttonTitle: "확인")

    }
}

//MARK: - InputBarAccessoryViewDelegate

extension ChatViewController: InputBarAccessoryViewDelegate {

    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        viewModel.sendText(text)
        messagesCollectionView.scrollToLastItem()

    }
}


//MARK: - MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate, MessageCellDelegate

extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {

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

        if viewModel.messages.count == 0 { return 0 }

        if viewModel.messages[indexPath.section].userUID == User.shared.userUID { return 0 }
        else { return 12 }
    }

    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {

        if viewModel.messages.count == 0 { return nil }
        if viewModel.messages[indexPath.section].userUID == User.shared.userUID { return nil }
        else {
            return NSAttributedString(string: viewModel.messages[indexPath.section].usernickname,
                                      attributes: [.font: UIFont.systemFont(ofSize: 12, weight: .medium),
                                                   .foregroundColor : UIColor.darkGray])
        }
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
    
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
         
        if viewModel.messages.count == 0 { return }
        guard let message = message as? Message else { return }
        let filteredChat = viewModel.filterChat(text: message.chatContent)
        guard let url = URL(string: Constants.MEDIA_REQUEST_URL + filteredChat.chatMessage) else { return }
        
        let heroID = String(Int.random(in: 0...1000))
    
        viewModel.messages[indexPath.section].heroID = heroID
        imageView.heroID = heroID
        imageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
        imageView.sd_setImage(with: url,
                              placeholderImage: nil,
                              options: .continueInBackground,
                              completed: nil)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        if scrollView.contentOffset.y <= 10 {

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                
                if
                    !self.viewModel.isFetchingData &&
                    self.viewModel.needsToFetchMoreData &&
                    !self.viewModel.isFirstViewLaunch {
                    
                        self.refreshControl.beginRefreshing()
                        self.viewModel.getChatList()
                    
                } else {
                    self.refreshControl.endRefreshing()
                    self.messagesCollectionView.refreshControl = nil
                }
            }
        }
    }
}

//MARK: - MessageCellDelegate

extension ChatViewController: MessageCellDelegate {
    
//    func didTapMessage(in cell: MessageCollectionViewCell) {
//
//        guard let indexPath = messagesCollectionView.indexPath(for: cell) else { return }
//        let message = messageForItem(at: indexPath, in: messagesCollectionView)
//
//        #warning("수정 ")
//
//    }
    
    func detectorAttributes(for detector: DetectorType, and message: MessageType, at indexPath: IndexPath) -> [NSAttributedString.Key : Any] {
        
        if viewModel.messages.count == 0 { return [:] }
        switch detector {
        case .url:
            
            if viewModel.messages[indexPath.section].userUID == User.shared.userUID {
                return [.foregroundColor: UIColor.white,  .underlineStyle: NSUnderlineStyle.single.rawValue]
            } else {
                return [.foregroundColor: UIColor.black, .underlineStyle: NSUnderlineStyle.single.rawValue]
            }
            
        default:
            return MessageLabel.defaultAttributes
        }
    }
    
    func enabledDetectors(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> [DetectorType] {
        return [.url]
    }
    
    func didSelectURL(_ url: URL) {
        presentSafariView(with: url)
    }
    
    func didTapImage(in cell: MessageCollectionViewCell) {
        
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else { return }
        let message = messageForItem(at: indexPath, in: messagesCollectionView)
        let heroID = viewModel.messages[indexPath.section].heroID
    
        switch message.kind {
            case .photo(let photoItem):
                if let url = photoItem.url {
                    presentImageVC(url: url, heroID: heroID)
                } else {
                    self.presentKMAlertOnMainThread(title: "오류 발생",
                                                    message: "유효하지 않은 사진이거나 요청을 처리하지 못했습니다. 불편을 드려 죄송합니다.😥",
                                                    buttonTitle: "확인")
                }
            default: break
        }
    }
  
    func presentImageVC(url: URL, heroID: String) {
        
        guard let imageVC = storyboard?.instantiateViewController(identifier: Constants.StoryboardID.imageVC) as? ImageViewController else {
            return
        }
        imageVC.modalPresentationStyle = .overFullScreen
        imageVC.imageURL = url
        imageVC.heroID = heroID

        present(imageVC, animated: true)
    }


}

//MARK: - Initialization & UI Configuration

extension ChatViewController {

    func initialize() {

        viewModel.delegate = self

        initializeNavigationItemTitle()
//        initializeCheckBarButtonItem()
        initializeRefreshControl()
        initializeInputBar()
        initializeCollectionView()
        createObservers()
    }

    func initializeNavigationItemTitle() {

        let titleButton = UIButton()
        titleButton.setTitle(chatRoomTitle, for: .normal)

        titleButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        titleButton.setTitleColor(.black, for: .normal)
        titleButton.addTarget(self, action: #selector(pressedTitle), for: .touchUpInside)

        navigationItem.titleView = titleButton
    }
    
    func initializeCheckBarButtonItem() {
        
        if postUploaderUID == User.shared.userUID {
            
            let checkBarButton = UIBarButtonItem(image: UIImage(systemName: "checkmark.circle"),
                                                 style: .plain,
                                                 target: self,
                                                 action: #selector(pressedCheckButton))
            checkBarButton.tintColor = .black
            checkBarButton.isEnabled = true
            navigationItem.rightBarButtonItems?.insert(checkBarButton, at: 1)
            
        
        } else {
             
        }

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
        messagesCollectionView.messageCellDelegate = self
        scrollsToLastItemOnKeyboardBeginsEditing = true

        if let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout {

            layout.setMessageIncomingAvatarSize(.zero)
            layout.setMessageOutgoingAvatarSize(.zero)

            layout.setMessageIncomingMessageTopLabelAlignment(LabelAlignment.init(textAlignment: .left,
                                                                                  textInsets: .init(top: 30, left: 15, bottom: 30, right: 10)))
            layout.setMessageOutgoingMessageTopLabelAlignment(LabelAlignment.init(textAlignment: .right,
                                                                                  textInsets: .init(top: 20, left: 10, bottom: 20, right: 10)))

            layout.setMessageIncomingMessageBottomLabelAlignment(LabelAlignment.init(textAlignment: .left,
                                                                                     textInsets: .init(top: 20, left: 15, bottom: 20, right: 10)))
            layout.setMessageOutgoingMessageBottomLabelAlignment(LabelAlignment.init(textAlignment: .right,
                                                                                     textInsets: .init(top: 20, left: 10, bottom: 20, right: 15)))
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
//        initializeInputBarButton()
    }

    func initializeInputBarButton() {

        let button = InputBarButtonItem(type: .custom)
        button.setSize(CGSize(width: 35, height: 35), animated: false)
        button.setImage(UIImage(systemName: "plus"),
                        for: .normal)
        button.tintColor = UIColor(named: Constants.Color.appColor) ?? .black
        button.onTouchUpInside { [weak self] _ in
            self?.presentInputActionSheet()
        }

        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        messageInputBar.setStackViewItems([button], forStack: .left, animated: false)
    }

    func presentInputActionSheet() {

        let actionSheet = UIAlertController(title: nil,
                                            message: nil,
                                            preferredStyle: .actionSheet)

        let cameraAction = UIAlertAction(title: "사진 찍기",
                                         style: .default) { [weak self] _ in

            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate = self
            picker.allowsEditing = true
            self?.present(picker, animated: true)
        }
        let albumAction = UIAlertAction(title: "사진 앨범",
                                         style: .default) { [weak self] _ in

            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            picker.allowsEditing = true
            self?.present(picker, animated: true)
        }
        let cancelAction = UIAlertAction(title: "취소",
                                         style: .cancel)


        actionSheet.addAction(cameraAction)
        actionSheet.addAction(albumAction)
        actionSheet.addAction(cancelAction)
        present(actionSheet, animated: true)
    }

    @objc func didBlockUser() {
        presentKMAlertOnMainThread(title: "차단 완료!",
                                   message: "해당 사용자의 채팅이 더 이상 화면에 나타나지 않습니다.",
                                   buttonTitle: "확인")

    }

    func createObservers() {

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didBlockUser),
                                               name: .didBlockUser,
                                               object: nil)
    }

}

//MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate

extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        
        guard
            let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage,
            let imageData = image.jpegData(compressionQuality: 0.8) else {
            return
        }
        
        // Upload Message
        showProgressBar()
        viewModel.uploadImage(imageData: imageData)

    }
}
