import UIKit
import MessageKit
import InputBarAccessoryView
import SafariServices
import SDWebImage
import IQKeyboardManagerSwift
import ImageSlideshow
import Hero
import SnapKit

class ChatViewController: MessagesViewController {
    
    //MARK: - Properties

    var viewModel: ChatViewModel!

    var roomUID: String = ""
    var chatRoomTitle: String = ""
    var postUploaderUID: String = ""
    var isFirstEntrance: Bool = false

    //MARK: - UI
    
    lazy var moreBarButtonItem: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.image = UIImage(systemName: "line.horizontal.3")
        button.style = .done
        button.tintColor = .black
        button.target = self
        button.action = #selector(pressedMoreBarButtonItem)
        return button
    }()
  
    let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .darkGray
        return indicator
    }()
    
    //MARK: - Initialization

    
    //MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.startAnimating()
        navigationItem.rightBarButtonItem = moreBarButtonItem
        
        IQKeyboardManager.shared.enable = false
        
        viewModel = ChatViewModel(
            room: roomUID,
            isFirstEntrance: isFirstEntrance
        )
        
        initialize()
        setupLayout()
        setupConstraints()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.connect()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        NotificationCenter.default.post(
            name: .reconnectAndFetchFromLastChat,
            object: nil
        )
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
    
    deinit {
        print("❗️ ChatViewController DEINITIALIZED")
    }
    
    //MARK: - UI Setup
    
    private func setupLayout() {
        view.addSubview(activityIndicator)
    }
    
    private func setupConstraints() {
        activityIndicator.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
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

    // Message Top Label
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if viewModel.messages.count == 0 { return 0 }
        if viewModel.messages[indexPath.section].userUID == User.shared.userUID { return 0 }
        else { return 20 }
    }

    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {

        if viewModel.messages.count == 0 { return nil }
        if viewModel.messages[indexPath.section].userUID == User.shared.userUID { return nil }
        else {
            return NSAttributedString(
                string: viewModel.messages[indexPath.section].usernickname,
                attributes: [.font: UIFont.systemFont(ofSize: 12, weight: .medium),
                             .foregroundColor : UIColor.darkGray])
        }
    }

    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {

        if viewModel.messages.count == 0 { return #colorLiteral(red: 0.8771190643, green: 0.8736019731, blue: 0.8798522949, alpha: 1) }
        if viewModel.messages[indexPath.section].userUID == User.shared.userUID {
            return UIColor(named: K.Color.appColor) ?? .systemPink
        } else {
            return #colorLiteral(red: 0.8771190643, green: 0.8736019731, blue: 0.8798522949, alpha: 1)
        }
    }
    
    // Message Accessory View -> date label
    
    func configureAccessoryView(_ accessoryView: UIView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        
        if viewModel.messages.count == 0 { return }
        accessoryView.subviews.forEach { $0.removeFromSuperview() }
        accessoryView.backgroundColor = .clear
        let label = UILabel()
        label.font = .systemFont(ofSize: 10, weight: .medium)
        label.textColor = .lightGray
        label.text = viewModel.messages[indexPath.section].date
        label.textAlignment = viewModel.messages[indexPath.section].userUID == User.shared.userUID ? .right : .left
        accessoryView.addSubview(label)
        label.frame = accessoryView.bounds
    }
    
    // Message Style

    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(corner, .curved)
    }
    
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
         
        if viewModel.messages.count == 0 { return }
        guard let message = message as? Message else { return }
        let filteredChat = viewModel.filterChat(text: message.chatContent)
        guard let url = URL(string: K.MEDIA_REQUEST_URL + filteredChat.chatMessage) else { return }
        
        let heroID = String(Int.random(in: 0...1000))
    
        viewModel.messages[indexPath.section].heroID = heroID
        imageView.heroID = heroID
        imageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
        imageView.sd_setImage(
            with: url,
            placeholderImage: nil,
            options: .continueInBackground,
            completed: nil
        )
    }
    
    // UIScrollView Methods
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        if scrollView.contentOffset.y <= 10 {
         
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                if !self.viewModel.isFetchingData &&
                    self.viewModel.hasMorePreviousChatToFetch &&
                    !self.viewModel.isFirstViewLaunch {
                    self.viewModel.getPreviousChats()

                }
            }
        }
    }
    
}


//MARK: - Initialization & UI Configuration

extension ChatViewController {

    func initialize() {

        viewModel.delegate = self

        initializeNavigationItemTitle()

        initializeInputBar()
        initializeCollectionView()
        createObservers()
    }

    func initializeNavigationItemTitle() {

        let titleButton = UIButton(type: .system)
        titleButton.setTitle(chatRoomTitle, for: .normal)

        titleButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        titleButton.setTitleColor(.black, for: .normal)
        titleButton.addTarget(
            self,
            action: #selector(pressedTitle),
            for: .touchUpInside
        )
        
        navigationItem.titleView = titleButton
    }

    func initializeCollectionView() {

        messagesCollectionView.contentInset.top = 20

        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.delegate = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.backgroundColor = .white
        scrollsToLastItemOnKeyboardBeginsEditing = true
        
        guard let layout = messagesCollectionView.collectionViewLayout
                as? MessagesCollectionViewFlowLayout else { return }
        
        layout.setMessageIncomingAvatarSize(.zero)
        layout.setMessageOutgoingAvatarSize(.zero)
        
        layout.setMessageIncomingAccessoryViewSize(CGSize(width: 70, height: 10))
        layout.setMessageIncomingAccessoryViewPadding(HorizontalEdgeInsets(left: 5, right: 0))
        layout.setMessageIncomingAccessoryViewPosition(.messageBottom)
        
        layout.setMessageOutgoingAccessoryViewSize(CGSize(width: 70, height: 10))
        layout.setMessageOutgoingAccessoryViewPadding(HorizontalEdgeInsets(left: 0, right: 5))
        layout.setMessageOutgoingAccessoryViewPosition(.messageBottom)

        
        layout.setMessageIncomingMessageTopLabelAlignment(LabelAlignment.init(textAlignment: .left,
                                                                              textInsets: .init(top: 30, left: 15, bottom: 30, right: 10)))



    }

    func initializeInputBar() {
        
        messageInputBar.delegate = self
        messageInputBar.sendButton.title = nil
        let configuration = UIImage.SymbolConfiguration(pointSize: 28, weight: .regular)
        let color = UIColor(named: K.Color.appColor)
        let sendButtonImage = UIImage(systemName: "arrow.up.circle.fill",
                                      withConfiguration: configuration)?.withTintColor(
                                        color ?? .systemPink,
                                        renderingMode: .alwaysOriginal
                                      )
        
        messageInputBar.sendButton.setImage(sendButtonImage, for: .normal)
        initializeImageInputBarButton()
    }

    func initializeImageInputBarButton() {

        let button = InputBarButtonItem(type: .custom)
        button.setSize(CGSize(width: 35, height: 35), animated: false)
        button.setImage(UIImage(systemName: "plus"),
                        for: .normal)
        button.tintColor = .darkGray
        button.onTouchUpInside { [weak self] _ in
            self?.presentInputActionSheet()
        }

        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        messageInputBar.setStackViewItems([button], forStack: .left, animated: false)
    }

    func presentInputActionSheet() {
        
        let cameraAction = UIAlertAction(
            title: "사진 찍기",
            style: .default
        ) { [weak self] _ in
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate = self
            picker.allowsEditing = true
            self?.present(picker, animated: true)
        }
        let albumAction = UIAlertAction(
            title: "사진 앨범",
            style: .default
        ) { [weak self] _ in
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            picker.allowsEditing = true
            self?.present(picker, animated: true)
        }
     
        let actionSheet = UIHelper.createActionSheet(
            with: [cameraAction, albumAction],
            title: nil
        )
        present(actionSheet, animated: true)
    }
    
    @objc func didBlockUser() {
        presentKMAlertOnMainThread(
            title: "차단 완료!",
            message: "해당 사용자의 채팅이 더 이상 화면에 나타나지 않습니다.",
            buttonTitle: "확인"
        )
    }
    
    func createObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didBlockUser),
            name: .didBlockUser,
            object: nil
        )
    }

}
