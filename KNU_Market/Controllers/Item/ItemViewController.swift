import UIKit
import SDWebImage
import ImageSlideshow
import SafariServices

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
    
    @IBOutlet weak var checkView: UIView!
    @IBOutlet weak var checkButtonDetail: UIButton!
    
    @IBOutlet var topBarButtons: [UIButton]!
    
    @IBOutlet weak var slideShowHeight: NSLayoutConstraint!
    
    private let refreshControl = UIRefreshControl()
    
    var viewModel = ItemViewModel()
    
    var pageID: String = "" {
        didSet { viewModel.pageID = pageID }
    }
    
    var isFromChatVC: Bool = false
    
    //MARK: - VC Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print("✏️ ItemVC - pageID: \(pageID)")
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
    
    @objc private func pressedURLLabel() {
        guard let url = viewModel.userIncludedURL else { return }
        presentSafariView(with: url)
    }
    
    //MARK: - IBActions & Methods
    
    @IBAction func pressedEnterChatButton(_ sender: UIButton) {
        enterChatButton.loadingIndicator(true)
        
        if isFromChatVC {
            navigationController?.popViewController(animated: true)
        }
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
                                             style: .destructive) { [weak self] _ in
                
                guard let self = self else { return }
                
                self.presentAlertWithCancelAction(title: "정말 삭제하시겠습니까?",
                                                  message: "") { selectedOk in
                    if selectedOk {
                        showProgressBar()
                        self.viewModel.deletePost(for: self.pageID)
                    }
                }
                                             }
            
            let editAction = UIAlertAction(title: "글 수정하기",
                                           style: .default) { [weak self] _ in
                
                guard let self = self else { return }
            
                DispatchQueue.main.async {
                    
                    showProgressBar()
                    
                    guard let editVC = self.storyboard?.instantiateViewController(
                            identifier: Constants.StoryboardID.uploadItemVC
                    ) as? UploadItemViewController else { return }
                    
                    editVC.editModel = self.viewModel.modelForEdit
                    
                    dismissProgressBar()
                    
                    self.navigationController?.pushViewController(editVC, animated: true)
                }
            }
            actionSheet.addAction(editAction)
            actionSheet.addAction(deleteAction)
            
        } else {
            
            let reportAction = UIAlertAction(title: "게시글 신고하기",
                                           style: .default) { [weak self] _ in
                
                guard let self = self else { return }
                
                guard let nickname = self.viewModel.model?.nickname,
                      let postUID = self.viewModel.pageID else {
                    return
                }
            
                self.presentReportUserVC(userToReport: nickname,
                                         postUID: postUID)
            }
            
            let blockAction = UIAlertAction(title: "이 사용자의 글 보지 않기",
                                            style: .default) { [weak self] _ in
                
                guard let self = self else { return }
                self.askToBlockUser()
            }
            actionSheet.addAction(reportAction)
            actionSheet.addAction(blockAction)
        }
        
        let cancelAction = UIAlertAction(title: "취소",
                                         style: .cancel,
                                         handler: nil)
        actionSheet.addAction(cancelAction)
        self.present(actionSheet, animated: true)
    }
    
    // 내가 작성한 글일 경우 check 버튼 활성화
    @IBAction func pressedCheckButton(_ sender: UIButton) {
        
        let actionSheet = UIAlertController(title: "모집 상태 변경",
                                            message: nil,
                                            preferredStyle: .actionSheet)
        
        
        if let isCompletelyDone = viewModel.model?.isCompletelyDone {
            
            if isCompletelyDone {
                
                let cancelMarkDoneAction = UIAlertAction(title: "다시 모집하기",
                                                         style: .default) { alert in
                    
                    self.viewModel.cancelMarkPostDone(for: self.pageID)
                    
                }
                actionSheet.addAction(cancelMarkDoneAction)
                
            } else {
                let doneAction = UIAlertAction(title: "모집 완료하기",
                                               style: .default) { [weak self] _ in
                    guard let self = self else { return }
                    
                    self.viewModel.markPostDone(for: self.pageID)
      
                }
                actionSheet.addAction(doneAction)
            }
        }
        let cancelAction = UIAlertAction(title: "취소",
                                         style: .cancel,
                                         handler: nil)
        
        actionSheet.addAction(cancelAction)
        self.present(actionSheet, animated: true)
    }
    
    func askToBlockUser() {
        
        guard let reportNickname = viewModel.model?.nickname,
              let reportUID = viewModel.model?.userUID else {
            showSimpleBottomAlert(with: "현재 해당 기능을 사용할 수 없습니다.😥")
            return
        }
    
        guard !User.shared.bannedPostUploaders.contains(reportUID) else {
            showSimpleBottomAlert(with: "이미 \(reportNickname)의 글을 안 보기 처리하였습니다.🧐")
            return
        }

        presentAlertWithCancelAction(title: "\(reportNickname)님의 글 보지 않기",
                                          message: "홈화면에서 위 사용자의 게시글이 더는 보이지 않도록 설정하시겠습니까? 한 번 설정하면 해제할 수 없습니다.") { selectedOk in
            if selectedOk {
                self.viewModel.blockUser(userUID: reportUID)
            }
        }
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
        
        showSimpleBottomAlertWithAction(message: "존재하지 않는 글입니다 🧐",
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
            NotificationCenter.default.post(name: .updateItemList, object: nil)
            
        }
    }
    
    func failedDeletingPost(with error: NetworkError) {
        
        dismissProgressBar()
        
        showSimpleBottomAlertWithAction(message: error.errorDescription,
                                        buttonTitle: "재시도") {
            self.viewModel.deletePost(for: self.pageID)
        }
    }
    
    func didMarkPostDone() {
        showSimpleBottomAlert(with: "모집 완료를 축하합니다.🎉")
        refreshPage()
    }
    
    func failedMarkingPostDone(with error: NetworkError) {
        
        dismissProgressBar()

        showSimpleBottomAlert(with: error.errorDescription)
    }
    
    func didCancelMarkPostDone() {
        refreshPage()
    }
    
    func failedCancelMarkPostDone(with error: NetworkError) {
    
        showSimpleBottomAlert(with: error.errorDescription)
    }
    
    func didEnterChat(isFirstEntrance: Bool) {
        
        let storyboard = UIStoryboard(name: "Chat", bundle: nil)
        guard let vc = storyboard.instantiateViewController(identifier: Constants.StoryboardID.chatVC) as? ChatViewController else { return }
        
        vc.roomUID = pageID
        vc.chatRoomTitle = viewModel.model?.title ?? ""
        
        vc.isFirstEntrance = isFirstEntrance ? true : false
        
        navigationController?.pushViewController(vc, animated: true)
        enterChatButton.loadingIndicator(false)
        
    }
    
    func failedJoiningChat(with error: NetworkError) {
        
        presentKMAlertOnMainThread(title: "채팅방 참여 불가",
                                   message: error.errorDescription,
                                   buttonTitle: "확인")

        enterChatButton.loadingIndicator(false)
    }
    
    func didBlockUser() {
        showSimpleBottomAlert(with: "앞으로 \(viewModel.model?.nickname ?? "해당 유저")의 게시글이 목록에서 보이지 않습니다.")
        navigationController?.popViewController(animated: true)
    }
    
    func didDetectURL(with string: NSMutableAttributedString) {
        itemDetailLabel.attributedText = string
        itemDetailLabel.isUserInteractionEnabled = true
        itemDetailLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(pressedURLLabel)))
    }
    
    func failedLoadingData(with error: NetworkError) {
        showSimpleBottomAlert(with: error.errorDescription)
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
        viewModel.detectURL()
    }
    
    func initialize() {
        
        viewModel.fetchItemDetails(for: pageID)
        viewModel.fetchEnteredRoomInfo()
        
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
        
        createObserversForPresentingEmailVerification()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(refreshPage),
                                               name: .didUpdatePost,
                                               object: nil)
    }
    
    func initializeScrollView() {
        
        scrollView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshPage), for: .valueChanged)
    }
    
    func initializeProfileImageView() {
        
        userProfileImageView.contentMode = .scaleAspectFill
        userProfileImageView.image = UIImage(named: Constants.Images.defaultAvatar)
        userProfileImageView.layer.cornerRadius = userProfileImageView.frame.width / 2
    }
    
    func initializeTitleView() {
        
        titleView.layer.cornerRadius = 10
        titleView.backgroundColor = .white
        
        titleView.layer.shadowColor = UIColor.darkGray.cgColor
        
        titleView.layer.shadowOffset = CGSize(width: 1, height: 1)
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
        
        checkView.layer.cornerRadius = menuButton.frame.height / 2
        checkView.backgroundColor = .white
        checkView.layer.shadowColor = UIColor.black.cgColor
        checkView.layer.shadowOffset = CGSize(width: 2, height: 2)
        checkView.layer.shadowOpacity = 0.2
        checkView.layer.shadowRadius = 2
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
            
            checkView.isHidden = false
            
            if let isCompletelyDone = viewModel.model?.isCompletelyDone {
                
                if isCompletelyDone {
                    
                    checkView.backgroundColor = .lightGray
                    checkButtonDetail.setTitleColor(.white, for: .normal)
                    checkButtonDetail.setTitle("모집 완료  ⌵", for: .normal)
                  
                } else {
                    checkView.backgroundColor = UIColor(named: Constants.Color.appColor)
                    
                    checkButtonDetail.setTitle("모집 중  ⌵", for: .normal)
                }
            }
            
        } else {
            checkView.isHidden = true
        }
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
        
        if viewModel.isCompletelyDone {
            gatheringPeopleLabel.text = "모집 완료"
            gatheringPeopleImageView.isHidden = true
        } else {
            gatheringPeopleLabel.text = "모집 중     \(currentNum)" + "/" + "\(total)"
            gatheringPeopleImageView.isHidden = false
        }
        gatheringPeopleLabel.font = UIFont.systemFont(ofSize: 15.0,
                                                      weight: .semibold)
    }
    
    func initializeEnterChatButton() {
        
        if viewModel.postIsUserUploaded || viewModel.isGathering || viewModel.userAlreadyJoinedPost {
            enterChatButton.isUserInteractionEnabled = true
            enterChatButton.backgroundColor = UIColor(named: Constants.Color.appColor)
            enterChatButton.setTitle("채팅방 입장", for: .normal)
            
        } else {
            enterChatButton.isUserInteractionEnabled = false
            enterChatButton.setTitle("모집 완료", for: .normal)
            enterChatButton.backgroundColor = UIColor.lightGray
        }
        
        enterChatButton.layer.cornerRadius = 7
        enterChatButton.titleLabel?.font = UIFont.systemFont(ofSize: 15.0,
                                                             weight: .semibold)
        enterChatButton.titleLabel?.textColor = UIColor.white
        enterChatButton.addBounceAnimation()
    }
    
    func initializeLocationLabel() {
        locationLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
    }
    
    func initializeBottomView() {
        
        bottomView.layer.addBorder([.top], color: #colorLiteral(red: 0.9119567871, green: 0.912109673, blue: 0.9119365811, alpha: 1), width: 1.0)
    }
    
    func initializeSlideShow() {
        
        slideShowHeight.constant = view.bounds.height / 2.2
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
            slideShow.contentMode = .scaleAspectFit
        } else {
            slideShow.setImageInputs([ImageSource(image: UIImage(named: Constants.Images.defaultItemImage)!)])
        }
        
        slideShow.contentScaleMode = .scaleAspectFill
        slideShow.slideshowInterval = 5
        slideShow.pageIndicatorPosition = .init(horizontal: .center, vertical: .customBottom(padding: 50))
    }
    
    
    @objc func pressedImage() {
        
        let fullScreenController = slideShow.presentFullScreenController(from: self)
        fullScreenController.slideshow.activityIndicator = DefaultActivityIndicator(style: .gray, color: nil)
    }
}
