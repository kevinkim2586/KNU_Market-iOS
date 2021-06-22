import UIKit
import SnackBar_swift
import SkeletonView
import SDWebImage
import ImageSlideshow

class ItemViewController: UIViewController {
    
    @IBOutlet weak var slideShow: ImageSlideshow!
    
    //@IBOutlet weak var itemImageView: UIImageView!
    //@IBOutlet weak var pageControl: UIPageControl!
    
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
    
    
    private let refreshControl = UIRefreshControl()
    
    var viewModel = ItemViewModel()
    
    var pageID: String = ""
    
    //MARK: - VC Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        slideShow.layer.cornerRadius = 25
        slideShow.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
    
        navigationController?.navigationBar.isHidden = true
        
        print("ItemVC - pageID: \(pageID)")
        
        viewModel.fetchItemDetails(for: pageID)
        
        initialize()
 
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
   
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        
        navigationController?.navigationBar.isHidden = false
    }

    
    //MARK: - IBActions & Methods
    
//    @IBAction func pageChanged(_ sender: UIPageControl) {
//        itemImageView.sd_setImage(with: viewModel.imageURLs[pageControl.currentPage],
//                                  placeholderImage: nil,
//                                  options: .continueInBackground)
//    }
    
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
        
        let reportUser = UIAlertAction(title: "게시글 신고하기",
                                       style: .default) { alert in
            
            let userToReport = self.viewModel.model?.nickname ?? ""
        
            guard let reportVC = self.storyboard?.instantiateViewController(identifier: Constants.StoryboardID.reportUserVC) as? ReportUserViewController else {
                return
            }
            
            reportVC.userToReport = userToReport
            
            self.present(reportVC, animated: true)
        }
        
        let cancelAction = UIAlertAction(title: "취소",
                                         style: .cancel,
                                         handler: nil)
        
        actionSheet.addAction(reportUser)
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
        
        print("ItemVC - failedFetchingPostDetails")
        self.scrollView.refreshControl?.endRefreshing()
        SnackBar.make(in: self.view,
                      message: error.errorDescription,
                      duration: .lengthLong).show()
    }
}

//MARK: - UI Configuration

extension ItemViewController {
    
    func initialize() {
        
        viewModel.delegate = self
        
        initializeScrollView()
        
        initializeProfileImageView()
        initializeTitleView()
        initializeItemExplanationLabel()
        initializeGatheringPeopleLabel()
        initializeEnterChatButton()
        initializeBottomView()
    }
    
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
        titleView.layer.shadowRadius = 3
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
        slideShow.pageIndicatorPosition = .init(horizontal: .center, vertical: .customTop(padding: 30))
    }
    
    @objc func pressedImage() {
        
        let fullScreenController = slideShow.presentFullScreenController(from: self)
        fullScreenController.slideshow.activityIndicator = DefaultActivityIndicator(style: .white, color: nil)
    }
    
//    func configurePageControl() {
//
//        itemImageView.isUserInteractionEnabled = true
//
//        if viewModel.imageURLs.count >= 2 {
//            pageControl.isHidden = false
//        }
//
//        pageControl.numberOfPages = viewModel.imageURLs.count
//        pageControl.currentPage = 0
//
//        pageControl.pageIndicatorTintColor = .lightGray
//        pageControl.currentPageIndicatorTintColor = .white
//
//        itemImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
//        itemImageView.sd_setImage(with: viewModel.imageURLs[0],
//                                  placeholderImage: nil,
//                                  options: .continueInBackground)
//
//        // Tap & Swipe gesture configuration
//
//        let tapGesture = UITapGestureRecognizer(target: self,
//                                                action: #selector(pressedImage))
//        itemImageView.addGestureRecognizer(tapGesture)
//
//        let swipeLeft = UISwipeGestureRecognizer(target: self,
//                                                 action: #selector(self.respondToSwipeGesture(_:)))
//        swipeLeft.direction = UISwipeGestureRecognizer.Direction.left
//
//
//        let swipeRight = UISwipeGestureRecognizer(target: self,
//                                                  action: #selector(self.respondToSwipeGesture(_:)))
//        swipeRight.direction = UISwipeGestureRecognizer.Direction.right
//
//        self.itemImageView.addGestureRecognizer(swipeLeft)
//        self.itemImageView.addGestureRecognizer(swipeRight)
//    }
    
//    @objc func pressedImage() {
//
//        guard let photoDetailVC = self.storyboard?.instantiateViewController(identifier: Constants.StoryboardID.photoDetailVC) as? PhotoDetailViewController else {
//            fatalError()
//        }
//
//        photoDetailVC.imageURLs = viewModel.imageURLs
//
//        self.navigationController?.pushViewController(photoDetailVC, animated: true)
//    }

//    @objc func respondToSwipeGesture(_ gesture: UIGestureRecognizer) {
//
//        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
//
//            switch swipeGesture.direction {
//
//            case UISwipeGestureRecognizer.Direction.left :
//                pageControl.currentPage += 1
//                itemImageView.sd_setImage(with: viewModel.imageURLs[pageControl.currentPage],
//                                          placeholderImage: nil,
//                                          options: .continueInBackground)
//
//            case UISwipeGestureRecognizer.Direction.right :
//                pageControl.currentPage -= 1
//                itemImageView.sd_setImage(with: viewModel.imageURLs[pageControl.currentPage],
//                                          placeholderImage: nil,
//                                          options: .continueInBackground)
//            default:
//                break
//            }
//        }
//    }
}
