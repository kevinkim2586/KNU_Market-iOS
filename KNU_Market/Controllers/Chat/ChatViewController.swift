import UIKit
import MessageKit
import InputBarAccessoryView
import IQKeyboardManagerSwift
import SwiftyJSON

class ChatViewController: MessagesViewController {
    
    private var viewModel: ChatViewModel!
    
    private let headerSpinner = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
    
    var room: String = ""
    var chatRoomTitle: String = ""
    var postUploaderUID: String = ""
    
    var chatMemberViewDelegate: ChatMemberViewDelegate?
    
    deinit {
        print("❗️ ChatViewController has been DEINITIALIZED")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = chatRoomTitle
        viewModel = ChatViewModel(room: room)
        initialize()
        
        print("✏️ pageID: \(room)")

        // joinPost 해보고 문제 없으면 connect 해야 함.
        viewModel.joinPost()
        viewModel.connect()

    }

    @IBAction func pressedMoreButton(_ sender: UIBarButtonItem) {
        
        guard let chatMemberVC = self.storyboard?.instantiateViewController(identifier: Constants.StoryboardID.chatMemberVC) as? ChatMemberViewController else { return }
        
        chatMemberVC.delegate = self
        chatMemberVC.roomInfo = viewModel.roomInfo
        chatMemberVC.postUploaderUID = self.postUploaderUID
        presentPanModal(chatMemberVC)
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath)
            header.addSubview(headerSpinner)
            headerSpinner.frame = CGRect(x: 0, y: 0, width: collectionView.bounds.width, height: 50)
            return header
        }
        return UICollectionReusableView()
    }
    
}


//MARK: - ChatViewDelegate - Socket Delegate Methods

extension ChatViewController: ChatViewDelegate {
    
    func didConnect() {
        
        // Connect 했다가 바로 아래 phrase 보내지말고 내 pid 목록 비교해서 없으면 보내는 로직으로 수정
        viewModel.sendText("\(User.shared.nickname) 님이 채팅방에 입장하셨습니다.")
        messagesCollectionView.reloadDataAndKeepOffset()
        messagesCollectionView.scrollToLastItem()
    }
    
    func didDisconnect() {
        print("✏️ ChatVC - didDisconnect delegate activated")
        navigationController?.popViewController(animated: true)
    }
    
    func didReceiveChat() {
        messagesCollectionView.reloadDataAndKeepOffset()
       
    }
    
    func reconnectSuggested() {
        self.presentSimpleAlert(title: "일시적은 연결 오류입니다 🤔", message: "나갔다가 다시 채팅방으로 접속하시기 바랍니다.")
        navigationController?.popViewController(animated: true)
    }
    
    func failedConnection(with error: NetworkError) {
        self.presentSimpleAlert(title: "일시적인 연결 문제 발생", message: error.errorDescription)
//        self.showSimpleBottomAlert(with: error.errorDescription)
    }
}

//MARK: - ChatViewDelegate - API Delegate Methods

extension ChatViewController {
    
    func didExitPost() {
        navigationController?.popViewController(animated: true)
    }
    
    func didDeletePost() {
        
        navigationController?.popViewController(animated: true)
       
        let name = Notification.Name(rawValue: Constants.NotificationKey.updateItemList)
        NotificationCenter.default.post(name: name, object: nil)
    }
    
    func didFetchChats() {
        
        headerSpinner.stopAnimating()
        
        if viewModel.isFirstViewLaunch {
            viewModel.isFirstViewLaunch = false
            messagesCollectionView.scrollToLastItem()
            messagesCollectionView.reloadData()
            
        } else {
            messagesCollectionView.reloadDataAndKeepOffset()
        }
    }
    
    func failedFetchingChats(with error: NetworkError) {
        
        headerSpinner.stopAnimating()
        
    }
}

//MARK: - ChatMemberViewDelegate - for PanModal

extension ChatViewController: ChatMemberViewDelegate {
    
    func didChooseToExitPost() {
        viewModel.exitPost()
    }
    
    func didChooseToDeletePost() {
        viewModel.deletePost(for: self.room)
    }
}

//MARK: - MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate, MessageCellDelegate

extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate, MessageCellDelegate {
    
    public func currentSender() -> SenderType {
        return viewModel.mySelf
    }
    
    public func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
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
        return NSAttributedString(string: viewModel.messages[indexPath.section].sender.displayName,
                                  attributes: [.font: UIFont.systemFont(ofSize: 12)])
    }
    
    // Bottom Label
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        return NSAttributedString(string: viewModel.messages[indexPath.section].date,
                                  attributes: [.font: UIFont.systemFont(ofSize: 10), .foregroundColor: UIColor.lightGray])
    }
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 10
    }
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
    
        if viewModel.messages[indexPath.section].chat.chat_userUID == User.shared.userUID {
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
        
        if scrollView.contentOffset.y <= 20 {
            
            if !viewModel.isFetchingData && viewModel.needsToFetchMoreData {
                headerSpinner.startAnimating()
                self.viewModel.getChatList()
            }
        }
    }
}

//MARK: - InputBarAccessoryViewDelegate

extension ChatViewController: InputBarAccessoryViewDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        
        viewModel.sendText(text)
        
        inputBar.inputTextView.text = ""
        messagesCollectionView.reloadDataAndKeepOffset()
        messagesCollectionView.scrollToLastItem()
    }
}

//MARK: - Initialization & UI Configuration

extension ChatViewController {
    
    func initialize() {
       
        viewModel.delegate = self
        chatMemberViewDelegate = self
        
        initializeInputBar()
        initializeCollectionView()
    }
    
    func initializeCollectionView() {
        
        messagesCollectionView.register(CollectionViewFooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "Header")
        (messagesCollectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.headerReferenceSize = CGSize(width: messagesCollectionView.bounds.width, height: 50)
    
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


public class CollectionViewFooterView: UICollectionReusableView {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
