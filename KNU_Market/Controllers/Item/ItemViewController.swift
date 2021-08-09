import UIKit
import SnackBar_swift
import SDWebImage
import ImageSlideshow

class ItemViewController: UIViewController {
    
    @IBOutlet weak var slideShow: ImageSlideshow!
    
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var itemTitleLabel: UILabel!
    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var userIdLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var locationImageView: UIImageView!
    
    @IBOutlet weak var itemDetailLabel: UILabel!
    @IBOutlet weak var gatheringPeopleLabel: UILabel!
    @IBOutlet weak var gatheringPeopleImageView: UIImageView!
    @IBOutlet weak var enterChatButton: UIButton!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet var topBarButtons: [UIButton]!
    
    @IBOutlet weak var slideShowHeight: NSLayoutConstraint!
    
    private let refreshControl = UIRefreshControl()
    
    var viewModel = ItemViewModel()
    
    var pageID: String = "" {
        didSet { viewModel.pageID = pageID }
    }
    
    //MARK: - VC Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("✏️ ItemVC - pageID: \(pageID)")
        
        viewModel.fetchItemDetails(for: pageID)
        
        slideShowHeight.constant = view.bounds.height / 2.5
        
        initialize()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillDisappear(animated)
     
        navigationController?.setNavigationBarHidden(true, animated: true)
        navigationController?.interactivePopGestureRecognizer?.delegate = nil

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        dismissProgressBar()
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    //MARK: - IBActions & Methods
    
    @IBAction func pressedEnterChatButton(_ sender: UIButton) {
        
        enterChatButton.loadingIndicator(true)
        
        viewModel.joinPost()
    }
    
    @objc func refreshPage() {
        viewModel.fetchItemDetails(for: pageID)
    }
    
    @IBAction func pressedBackButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    // 더보기 버튼
    @IBAction func pressedMoreButton(_ sender: UIButton) {
        
        let actionSheet = UIAlertController(title: nil,
                                            message: nil,
                                            preferredStyle: .actionSheet)
        
        if viewModel.postIsUserUploaded {
            let deleteAction = UIAlertAction(title: "공구 삭제하기",
                                             style: .destructive) { alert in
                
                self.presentAlertWithCancelAction(title: "정말 삭제하시겠습니까?",
                                                  message: "") { selectedOk in
                    
                    if selectedOk {
                        
                        showProgressBar()
                        self.viewModel.deletePost(for: self.pageID)
                    }
                }
                                             }
            
            let editAction = UIAlertAction(title: "글 수정하기",
                                           style: .default) { alert in
            
                DispatchQueue.main.async {
                    
                    guard let editVC = self.storyboard?.instantiateViewController(identifier: Constants.StoryboardID.uploadItemVC) as? UploadItemViewController else { return }
                    
                    editVC.editModel = self.viewModel.modelForEdit
                    
                    self.navigationController?.pushViewController(editVC, animated: true)
                }
            }
            actionSheet.addAction(editAction)
            actionSheet.addAction(deleteAction)
            
        } else {
            
            let reportAction = UIAlertAction(title: "게시글 신고하기",
                                           style: .default) { alert in
                
                self.presentReportUserVC(userToReport: self.viewModel.model?.nickname ?? "")

            }
            actionSheet.addAction(reportAction)
        }
        
        let cancelAction = UIAlertAction(title: "취소",
                                         style: .cancel,
                                         handler: nil)
        actionSheet.addAction(cancelAction)
        self.present(actionSheet, animated: true)
    }
    
    // 내가 작성한 글일 경우 check 버튼 활성화
    @IBAction func pressedCheckButton(_ sender: UIButton) {
        
        let actionSheet = UIAlertController(title: "상태 변경",
                                            message: nil,
                                            preferredStyle: .actionSheet)
        
        let checkAction = UIAlertAction(title: "모집완료",
                                        style: .default) { alert in
            
            self.viewModel.markPostDone(for: self.pageID)
            DispatchQueue.main.async {
                self.checkButton.isUserInteractionEnabled = false
            }
            
        }
        let cancelAction = UIAlertAction(title: "취소",
                                         style: .cancel,
                                         handler: nil)
        
        actionSheet.addAction(checkAction)
        actionSheet.addAction(cancelAction)
        self.present(actionSheet, animated: true)
    }
}

//MARK: - ItemViewModelDelegate

extension ItemViewController: ItemViewModelDelegate {
    
    func didFetchItemDetails() {
        
        print("ItemVC - didFetchPostDetails activated")
        
        DispatchQueue.main.async {
            self.scrollView.refreshControl?.endRefreshing()
            self.updateInformation()
        }
    }
    
    func failedFetchingItemDetails(with error: NetworkError) {
        
        print("ItemVC - failedFetchingPostDetails with error: \(error.errorDescription)")
        self.scrollView.refreshControl?.endRefreshing()
        
        scrollView.isHidden = true
        bottomView.isHidden = true
        
        self.showSimpleBottomAlertWithAction(message: "존재하지 않는 글입니다 🧐",
                                             buttonTitle: "홈으로",
                                             action: {
                                                self.navigationController?.popViewController(animated: true)
                                             })
    }
    
    func didDeletePost() {
        
        dismissProgressBar()
        
        showSimpleBottomAlert(with: "게시글 삭제 완료 🎉")
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.2) {
            
            self.navigationController?.popViewController(animated: true)
            NotificationCenter.default.post(name: Notification.Name.updateItemList, object: nil)
            
        }
    }
    
    func failedDeletingPost(with error: NetworkError) {
        
        print("ItemVC - failedDeletingPost")
        
        dismissProgressBar()
        
        showSimpleBottomAlertWithAction(message: error.errorDescription,
                                        buttonTitle: "재시도") {
            self.viewModel.deletePost(for: self.pageID)
        }
    }
    
    func didMarkPostDone() {
        
        dismissProgressBar()
        self.checkButton.isUserInteractionEnabled = true
        
        self.checkButton.setImage(UIImage(systemName: "checkmark.circle.fill"),
                                  for: .normal)
        
        //
        
    }
    
    func failedMarkingPostDone(with error: NetworkError) {
        
        dismissProgressBar()
        self.checkButton.isUserInteractionEnabled = true

        self.showSimpleBottomAlert(with: error.errorDescription)
        
    }
    
    func didEnterChat() {
        
        let storyboard = UIStoryboard(name: "Chat", bundle: nil)
        guard let vc = storyboard.instantiateViewController(identifier: Constants.StoryboardID.chatVC) as? ChatViewController else { return }
        
        vc.room = pageID
        vc.chatRoomTitle = viewModel.model?.title ?? ""
        
        navigationController?.pushViewController(vc, animated: true)
        enterChatButton.loadingIndicator(false)
        
    }
    
    func failedJoiningChat(with error: NetworkError) {
        
        self.showSimpleBottomAlert(with: error.errorDescription)
        enterChatButton.loadingIndicator(false)
    }
    
}

//MARK: - UI Configuration & Initialization

extension ItemViewController {
    
    func updateInformation() {
        
        itemTitleLabel.text = viewModel.model?.title
        
        // 프로필 이미지 설정
        let profileImageUID = viewModel.model?.profileImageUID ?? ""
        if profileImageUID.count > 1 {
            
            let url = URL(string: Constants.API_BASE_URL + "media/\(profileImageUID)")
            userProfileImageView.sd_setImage(with: url,
                                             placeholderImage: UIImage(named: Constants.Images.defaultAvatar),
                                             options: .continueInBackground)
        } else {
            userProfileImageView.image = UIImage(named: Constants.Images.defaultAvatar)
        }
        
        // 사진 설정
        viewModel.imageURLs.isEmpty
            ? configureImageSlideShow(imageExists: false)
            : configureImageSlideShow(imageExists: true)
        
        locationLabel.text = viewModel.location
        userIdLabel.text = viewModel.model?.nickname
        itemDetailLabel.text = viewModel.model?.itemDetail
        
        initializeDateLabel()
        initializeCheckButton()
        initializeGatheringPeopleLabel()
        initializeEnterChatButton()
        initializeLocationLabel()
        initializeSlideShow()
    }
    
    func initialize() {
        
        viewModel.delegate = self
        
        createObservers()
        initializeScrollView()
        initializeProfileImageView()
        initializeTitleView()
        initializeTopBarButtons()
        initializeBackButton()
        initializeMenuButton()
        initializeCheckButton()
        initializeItemExplanationLabel()
        initializeGatheringPeopleLabel()
        initializeEnterChatButton()
        initializeLocationLabel()
        initializeBottomView()
        initializeSlideShow()
    }
    
    func createObservers() {
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(refreshPage),
                                               name: Notification.Name.didUpdatePost,
                                               object: nil)
    }
    
    func initializeScrollView() {
        
        scrollView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshPage), for: .valueChanged)
    }
    
    func initializeProfileImageView() {
        
        userProfileImageView.image = UIImage(named: Constants.Images.defaultAvatar)
        userProfileImageView.layer.cornerRadius = userProfileImageView.frame.width / 2
    }
    
    func initializeTitleView() {
        
        titleView.layer.cornerRadius = 10
        titleView.backgroundColor = .white
        
        titleView.layer.shadowColor = UIColor.black.cgColor
        
        titleView.layer.shadowOffset = CGSize(width: 2, height: 2)
        titleView.layer.shadowOpacity = 0.15
        titleView.layer.shadowRadius = 1
    }
    
    func initializeTopBarButtons() {
        
        topBarButtons.forEach { buttons in
            
            buttons.layer.cornerRadius = menuButton.frame.height / 2
            buttons.backgroundColor = .white
            buttons.layer.shadowColor = UIColor.black.cgColor
            buttons.layer.shadowOffset = CGSize(width: 2, height: 2)
            buttons.layer.shadowOpacity = 0.2
            buttons.layer.shadowRadius = 2
        }
    }
    
    func initializeBackButton() {

        let font = UIFont.systemFont(ofSize: 15)
        let configuration = UIImage.SymbolConfiguration(font: font)
        let buttonImage = UIImage(systemName: "arrow.left", withConfiguration: configuration)
        backButton.setImage(buttonImage, for: .normal)
    }
    
    func initializeMenuButton() {

        let font = UIFont.systemFont(ofSize: 15)
        let configuration = UIImage.SymbolConfiguration(font: font)
        let buttonImage = UIImage(systemName: "ellipsis", withConfiguration: configuration)
        menuButton.setImage(buttonImage, for: .normal)
    }
    
    func initializeCheckButton() {
        
        if viewModel.postIsUserUploaded {
            checkButton.isHidden = false
        } else {
            checkButton.isHidden = true
        }
        
        let font = UIFont.systemFont(ofSize: 15)
        let configuration = UIImage.SymbolConfiguration(font: font)
        let buttonImage = UIImage(systemName: "checkmark.circle", withConfiguration: configuration)
        checkButton.setImage(buttonImage, for: .normal)
    }
    

    func initializeDateLabel() {
        dateLabel.text = viewModel.date
    }
    
    func initializeItemExplanationLabel() {
        
        let labelStyle = NSMutableParagraphStyle()
        labelStyle.lineSpacing = 5
        let attributes = [NSAttributedString.Key.paragraphStyle : labelStyle]
        itemDetailLabel.attributedText = NSAttributedString(string: viewModel.model?.title ?? "",
                                                            attributes: attributes)
    }
    
    func initializeGatheringPeopleLabel() {
        
        let currentNum = viewModel.currentlyGatheredPeople
        let total = viewModel.totalGatheringPeople
        
        if viewModel.isGathering {
            gatheringPeopleLabel.text = "모집 중     \(currentNum)" + "/" + "\(total)"
            
        } else {
            gatheringPeopleLabel.text = "마감     \(currentNum)" + "/" + "\(total)"
        }
        gatheringPeopleLabel.font = UIFont.systemFont(ofSize: 15.0,
                                                      weight: .semibold)
    }
    
    func initializeEnterChatButton() {
        
        if viewModel.isGathering || viewModel.postIsUserUploaded || viewModel.userAlreadyJoinedPost {
            enterChatButton.isUserInteractionEnabled = true
            enterChatButton.backgroundColor = UIColor(named: Constants.Color.appColor)
            enterChatButton.setTitle("채팅방 입장", for: .normal)
            
        } else {
            enterChatButton.isUserInteractionEnabled = false
            enterChatButton.setTitle("마감", for: .normal)
            enterChatButton.backgroundColor = UIColor.lightGray
        }
        
        enterChatButton.layer.cornerRadius = 7
        enterChatButton.titleLabel?.font = UIFont.systemFont(ofSize: 15.0,
                                                             weight: .semibold)
        enterChatButton.titleLabel?.textColor = UIColor.white
    }
    
    func initializeLocationLabel() {
        locationLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
    }
    
    func initializeBottomView() {
        
        bottomView.layer.borderWidth = 1
        bottomView.layer.borderColor = #colorLiteral(red: 0.9119567871, green: 0.912109673, blue: 0.9119365811, alpha: 1)
    }
    
    func initializeSlideShow() {
        
        slideShow.layer.cornerRadius = 15
        slideShow.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    }
}

//MARK: - Image Slide Show

extension ItemViewController {
    
    func configureImageSlideShow(imageExists: Bool) {
        
        if imageExists {
            
            slideShow.setImageInputs(viewModel.imageSources)
            let recognizer = UITapGestureRecognizer(target: self,
                                                    action: #selector(self.pressedImage))
            slideShow.addGestureRecognizer(recognizer)
        } else {
            slideShow.setImageInputs([ImageSource(image: UIImage(named: Constants.Images.defaultItemImage)!)])
        }
        
        slideShow.contentScaleMode = .scaleAspectFill
        slideShow.slideshowInterval = 5
        slideShow.pageIndicatorPosition = .init(horizontal: .center, vertical: .customTop(padding: 60))
    }
    
    @objc func pressedImage() {
        
        let fullScreenController = slideShow.presentFullScreenController(from: self)
        fullScreenController.slideshow.activityIndicator = DefaultActivityIndicator(style: .white, color: nil)
    }
}
