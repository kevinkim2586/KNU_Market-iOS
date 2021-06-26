import UIKit
import SnackBar_swift
import SkeletonView
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
    
    private let refreshControl = UIRefreshControl()
    
    var viewModel = ItemViewModel()
    
    var pageID: String = ""
    
    //MARK: - VC Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("ItemVC - pageID: \(pageID)")
        
        viewModel.fetchItemDetails(for: pageID)
        
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
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
 
    
    //MARK: - IBActions & Methods
    @IBAction func pressedBackButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func refreshPage() {
        viewModel.fetchItemDetails(for: pageID)
    }
    
    @IBAction func pressedMoreButton(_ sender: UIButton) {
        
        let actionSheet = UIAlertController(title: nil,
                                            message: nil,
                                            preferredStyle: .actionSheet)
        
        //본인이 작성한 글이면 Delete Action을 추가
        if viewModel.model?.nickname == User.shared.nickname {
            
            let deleteAction = UIAlertAction(title: "글 삭제하기",
                                             style: .destructive) { alert in
                
                self.presentAlertWithCancelAction(title: "정말 삭제하시겠습니까?",
                                                  message: "") { selectedOk in
                    
                    if selectedOk {
                        
                        self.viewModel.deletePost(for: self.pageID)
                    }
                }
                                             }
            actionSheet.addAction(deleteAction)
            
        }
        // 다른 사용자 글이면 Rerpot Action 만 추가
        else {
            let reportAction = UIAlertAction(title: "게시글 신고하기",
                                           style: .default) { alert in
                
                let userToReport = self.viewModel.model?.nickname ?? ""
                
                guard let reportVC = self.storyboard?.instantiateViewController(identifier: Constants.StoryboardID.reportUserVC) as? ReportUserViewController else {
                    return
                }
                
                reportVC.userToReport = userToReport
                
                self.present(reportVC, animated: true)
            }
            actionSheet.addAction(reportAction)
        }
        
        let cancelAction = UIAlertAction(title: "취소",
                                         style: .cancel,
                                         handler: nil)
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
        
        SnackBar.make(in: self.view,
                      message: "존재하지 않는 글입니다 🧐",
                      duration: .lengthLong).setAction(with: "홈으로", action: {
                        
                        self.navigationController?.popViewController(animated: true)
                        
                      }).show()
    }
    
    func didDeletePost() {
        
        SnackBar.make(in: self.view,
                      message: "게시글 삭제 완료 🎉",
                      duration: .lengthLong).show()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5) {
            
            GlobalVariable.needsToReloadData = true
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func failedDeletingPost(with error: NetworkError) {
        
        print("ItemVC - failedDeletingPost")
        SnackBar.make(in: self.view,
                      message: error.errorDescription,
                      duration: .lengthLong).setAction(with: "재시도", action: {
                        
                        self.viewModel.deletePost(for: self.pageID)
                        
                      }).show()
    }
    
}

//MARK: - UI Configuration

extension ItemViewController {
    
    func updateInformation() {
        
        itemTitleLabel.text = viewModel.model?.title
        
        // 프로필 이미지 설정
        let profileImageUID = viewModel.model?.profileImageUID ?? ""
        if profileImageUID.count > 1 {
            
            let url = URL(string: Constants.API_BASE_URL + "media/\(profileImageUID)")
            userProfileImageView.sd_setImage(with: url,
                                             placeholderImage: UIImage(named: "default avatar"),
                                             options: .continueInBackground)
        } else {
            userProfileImageView.image = UIImage(named: "default avatar")
        }
        
        // 사진 설정
        viewModel.imageURLs.isEmpty
            ? configureImageSlideShow(imageExists: false)
            : configureImageSlideShow(imageExists: true)
        
        locationLabel.text = viewModel.location
        userIdLabel.text = viewModel.model?.nickname
        itemDetailLabel.text = viewModel.model?.itemDetail
        
        initializeDateLabel()
        initializeGatheringPeopleLabel()
        initializeEnterChatButton()
        initializeSlideShow()
    }
    
    func initialize() {
        
        viewModel.delegate = self
        
        initializeScrollView()
        initializeProfileImageView()
        initializeTitleView()
        initializeBackButton()
        initializeMenuButton()
        initializeItemExplanationLabel()
        initializeGatheringPeopleLabel()
        initializeEnterChatButton()
        initializeBottomView()
        initializeSlideShow()
    }
    
    func initializeScrollView() {
        
        scrollView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshPage), for: .valueChanged)
    }
    
    func initializeProfileImageView() {
        
        userProfileImageView.image = UIImage(named: "default avatar")
        
        userProfileImageView.layer.cornerRadius = userProfileImageView.frame.width / 2
    }
    
    func initializeTitleView() {
        
        titleView.layer.cornerRadius = 10
        titleView.backgroundColor = .white
        
        titleView.layer.shadowColor = UIColor.black.cgColor
        
        titleView.layer.shadowOffset = CGSize(width: 3, height: 3)
        titleView.layer.shadowOpacity = 0.2
        titleView.layer.shadowRadius = 2
    }
    
    func initializeBackButton() {
        
        backButton.layer.cornerRadius = 10
        backButton.backgroundColor = .white
        backButton.layer.shadowColor = UIColor.black.cgColor
        backButton.layer.shadowOffset = CGSize(width: 2, height: 2)
        backButton.layer.shadowOpacity = 0.2
        backButton.layer.shadowRadius = 2
    }
    
    func initializeMenuButton() {
        
        menuButton.layer.cornerRadius = 10
        menuButton.backgroundColor = .white
        menuButton.layer.shadowColor = UIColor.black.cgColor
        menuButton.layer.shadowOffset = CGSize(width: 2, height: 2)
        menuButton.layer.shadowOpacity = 0.2
        backButton.layer.shadowRadius = 2
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
        
        // 수정 필요
        let currentNum = viewModel.currentlyGatheredPeople
        let total = viewModel.model?.totalGatheringPeople ?? 2
        
        if viewModel.isGathering {
            gatheringPeopleLabel.text = "모집 중     \(currentNum)" + "/" + "\(total)"
            
        } else {
            gatheringPeopleLabel.text = "마감     \(currentNum)" + "/" + "\(total)"
        }
        gatheringPeopleLabel.font = UIFont.systemFont(ofSize: 15.0,
                                                      weight: .semibold)
    }
    
    func initializeEnterChatButton() {
        
        if viewModel.isGathering {
            enterChatButton.backgroundColor = UIColor(named: Constants.Color.appColor)
        } else {
            enterChatButton.isUserInteractionEnabled = false
            enterChatButton.backgroundColor = UIColor.lightGray
        }
        
        enterChatButton.layer.cornerRadius = 7
        enterChatButton.setTitle("채팅방 입장", for: .normal)
        enterChatButton.titleLabel?.font = UIFont.systemFont(ofSize: 15.0,
                                                             weight: .semibold)
    }
    
    func initializeLocationLabel() {
        let index = viewModel.model?.location ?? Location.listForCell.count
        locationLabel.text = Location.listForCell[index]
    }
    
    func initializeBottomView() {
        
        bottomView.layer.borderWidth = 1
        bottomView.layer.borderColor = #colorLiteral(red: 0.9119567871, green: 0.912109673, blue: 0.9119365811, alpha: 1)
    }
    
    func initializeSlideShow() {
        
        slideShow.layer.cornerRadius = 25
        slideShow.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    }
}

//MARK: - Image Slide Show

extension ItemViewController {
    
    func configureImageSlideShow(imageExists: Bool) {
        
        if imageExists {
            
            slideShow.setImageInputs(viewModel.imageSources)
            let recognizer = UITapGestureRecognizer(target: self, action: #selector(self.pressedImage))
            slideShow.addGestureRecognizer(recognizer)
        } else {
            slideShow.setImageInputs([ImageSource(image: UIImage(named: "default item image")!)])
        }
        
        slideShow.contentScaleMode = .scaleAspectFill
        slideShow.slideshowInterval = 2
        slideShow.pageIndicatorPosition = .init(horizontal: .center, vertical: .customTop(padding: 50))
    }
    
    @objc func pressedImage() {
        
        let fullScreenController = slideShow.presentFullScreenController(from: self)
        fullScreenController.slideshow.activityIndicator = DefaultActivityIndicator(style: .white, color: nil)
    }
}
