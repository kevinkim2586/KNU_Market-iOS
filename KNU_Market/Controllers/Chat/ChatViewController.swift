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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = chatRoomTitle
        viewModel = ChatViewModel(room: room)
        initialize()
        
        
        // joinPost 해보고 문제 없으면 connect 해야 함.
        viewModel.joinPost()
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
                    
                    self.viewModel.exitPost()
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

//MARK: - ChatViewDelegate

extension ChatViewController: ChatViewDelegate {
    
    func didConnect() {
        viewModel.sendText("\(User.shared.nickname)님이 채팅방에 입장하셨습니다 🎉")
        messagesCollectionView.reloadData()
    }
    
    func didDisconnect() {
        print("✏️ ChatVC - didDisconnect delegate activated")
        navigationController?.popViewController(animated: true)
    }
    
    func didReceiveChat() {
        messagesCollectionView.reloadData()
       
    }
    
    func reconnectSuggested() {
        self.presentSimpleAlert(title: "일시적은 연결 오류입니다 🤔", message: "나갔다가 다시 채팅방으로 접속하시기 바랍니다.")
        navigationController?.popViewController(animated: true)
    }
    
    func failedConnection(with error: NetworkError) {
        
        self.showSimpleBottomAlert(with: error.errorDescription)
//        self.presentSimpleAlert(title: "채팅방에서 나가셨습니다 🤔", message: "채팅방을 나가고 다시 접속하시기 바랍니다.")
        
        //navigationController?.popViewController(animated: true)
    }
    
    func didExitPost() {
        print("✏️ 성공적으로 채팅방에서 나갔습니다.")
        navigationController?.popViewController(animated: true)
    }
    
    func didFetchChats() {
        
    }
    
    func failedFetchingChats(with error: NetworkError) {
        
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
        messagesCollectionView.scrollToLastItem()
    }
}


