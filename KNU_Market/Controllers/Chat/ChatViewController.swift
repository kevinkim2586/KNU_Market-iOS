import UIKit
import MessageKit
import InputBarAccessoryView
import IQKeyboardManagerSwift
import SwiftyJSON


class ChatViewController: MessagesViewController {
    
    private var viewModel: ChatViewModel!
    
    var room: String = ""
    var chatRoomTitle: String = ""
    
    deinit {
        print("❗️ ChatViewController has been DEINITIALIZED")
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        IQKeyboardManager.shared.enable = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        IQKeyboardManager.shared.enable = false
        viewModel.connect()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = chatRoomTitle
        
        viewModel = ChatViewModel(room: room)
        
        initialize()
    }
    
    @IBAction func pressedMoreButton(_ sender: UIBarButtonItem) {
        
        let actionSheet = UIAlertController(title: nil,
                                            message: nil,
                                            preferredStyle: .actionSheet)
        
        let exitAction = UIAlertAction(title: "채팅방 나가기",
                                       style: .destructive) { alert in
            
            self.presentAlertWithCancelAction(title: "정말 나가시겠습니까?",
                                              message: "") { selectedOk in
                if selectedOk {
                    
                    self.viewModel.disconnect()
                }
            }
        }
        let cancelAction = UIAlertAction(title: "취소",
                                         style: .cancel,
                                         handler: nil)
        
        actionSheet.addAction(exitAction)
        actionSheet.addAction(cancelAction)
        self.present(actionSheet, animated: true)
    }
    
}

//MARK: - Initialization

extension ChatViewController {
    
    func initialize() {
        
        viewModel.delegate = self
        initializeInputBar()
        initializeCollectionView()
    }
    
    func initializeCollectionView() {
        

        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.delegate = self
        
        if let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout {
            
            layout.setMessageIncomingAvatarSize(.zero)
            layout.setMessageOutgoingAvatarSize(.zero)
            
            layout.setMessageIncomingMessageTopLabelAlignment(LabelAlignment.init(textAlignment: .left, textInsets: .init(top: 10, left: 10, bottom: 10, right: 10)))
            layout.setMessageOutgoingMessageTopLabelAlignment(LabelAlignment.init(textAlignment: .right, textInsets: .init(top: 10, left: 10, bottom: 10, right: 10)))
        }
    }
    
    func initializeInputBar() {
        
        messageInputBar.delegate = self
    }
}

//MARK: - ChatViewDelegate

extension ChatViewController: ChatViewDelegate {
    
    func didConnect() {
        viewModel.sendText("\(User.shared.nickname)님이 채팅방에 입장하셨습니다.")
        messagesCollectionView.reloadData()
    }
    
    func didDisconnect() {
        navigationController?.popViewController(animated: true)
    }
    
    func didReceiveChat() {
        messagesCollectionView.reloadData()
    }
    
    func reconnectSuggested() {
        // snackbar 사용하면 가려보임
    }
    
    func failedConnection(with error: NetworkError) {

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
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 12
    }
    
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        
        return NSAttributedString(string: viewModel.messages[indexPath.section].sender.displayName,
                                  attributes: [.font: UIFont.systemFont(ofSize: 12)])
    }
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
    
        if viewModel.messages[indexPath.section].sender.senderId == User.shared.id {
            return UIColor(named: Constants.Color.appColor)!
        } else {
            return #colorLiteral(red: 0.8771190643, green: 0.8736019731, blue: 0.8798522949, alpha: 1)
        }
    }
}

//MARK: - InputBarAccessoryViewDelegate

extension ChatViewController: InputBarAccessoryViewDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        
        viewModel.sendText(text)
        
        inputBar.inputTextView.text = ""
        messagesCollectionView.reloadData()
        messagesCollectionView.scrollToLastItem(animated: true)
    }
}


