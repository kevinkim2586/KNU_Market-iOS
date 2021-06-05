import UIKit

class ItemViewController: UIViewController {
    
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var itemTitleLabel: UILabel!
    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var userIdLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var locationImageView: UIImageView!

    @IBOutlet weak var itemExplanationLabel: UILabel!
    @IBOutlet weak var gatheringPeopleLabel: UILabel!
    @IBOutlet weak var gatheringPeopleImageView: UIImageView!
    @IBOutlet weak var enterChatButton: UIButton!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var dateLabel: UILabel!
    
    
    private let refreshControl = UIRefreshControl()
    
    var images = ["bubble1", "bubble2", "bubble3"]
    
    private var viewModel = ItemViewModel()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    
        navigationController?.navigationBar.isHidden = true
        

        
        initialize()
 
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        
        navigationController?.navigationBar.isHidden = false
    }
    

    
    @IBAction func pageChanged(_ sender: UIPageControl) {
        itemImageView.image = UIImage(named: images[pageControl.currentPage])
    }
    
    @IBAction func pressedMoreButton(_ sender: UIBarButtonItem) {
        
        //Action Sheet - 유저 신고하기
    }
    
    @IBAction func pressedBackButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    
    
    @objc func refreshScrollView() {
        
        
        //label 하고 버튼 둘다 회색으로 바꾸기
        
        
        
        scrollView.refreshControl?.endRefreshing()
    }
    
    
    
    
}

//MARK: - UI Configuration

extension ItemViewController {
    
    func initialize() {
        
        initializeScrollView()
        
        initializeProfileImageView()
        initializeTitleView()
        initializeItemExplanationLabel()
        initializeGatheringPeopleLabel()
        initializeEnterChatButton()
        initializeBottomView()
        configurePageControl()
        
    }
    
    func initializeScrollView() {
        
        scrollView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshScrollView), for: .valueChanged)
    }
    
    func initializeProfileImageView() {
        
        userProfileImageView.image = viewModel.userProfileImage
        
        userProfileImageView.layer.cornerRadius = userProfileImageView.frame.width / 2
//        userProfileImageView.layer.borderWidth = 1
//        userProfileImageView.layer.borderColor = UIColor.black.cgColor
//
    }
    
    func initializeTitleView() {
        
        titleView.layer.cornerRadius = 10
        titleView.backgroundColor = .white
        
        titleView.layer.shadowColor = UIColor.black.cgColor
        
        titleView.layer.shadowOffset = CGSize(width: 3, height: 3)
        titleView.layer.shadowOpacity = 0.2
        titleView.layer.shadowRadius = 3
        
        
        
    }

    
    func initializeItemExplanationLabel() {
        
        let labelStyle = NSMutableParagraphStyle()
        labelStyle.lineSpacing = 5
        let attributes = [NSAttributedString.Key.paragraphStyle : labelStyle]
        itemExplanationLabel.attributedText = NSAttributedString(string: viewModel.itemExplanation,
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
        locationLabel.text = viewModel.location
    }
    
    func initializeBottomView() {
        
        bottomView.layer.borderWidth = 1
        bottomView.layer.borderColor = #colorLiteral(red: 0.9119567871, green: 0.912109673, blue: 0.9119365811, alpha: 1)
    }

    
}

//MARK: - Page Control

extension ItemViewController {
    
    func configurePageControl() {
        
        itemImageView.isUserInteractionEnabled = true
        
        pageControl.numberOfPages = images.count
        pageControl.currentPage = 0
        
        pageControl.pageIndicatorTintColor = .lightGray
        pageControl.currentPageIndicatorTintColor = .white
        // 나중에는 viewModel.images[] 이런식으로 해야할듯
        itemImageView.image = UIImage(named: images[0])
        
        let swipeLeft = UISwipeGestureRecognizer(target: self,
                                                 action: #selector(self.respondToSwipeGesture(_:)))
        swipeLeft.direction = UISwipeGestureRecognizer.Direction.left

        
        let swipeRight = UISwipeGestureRecognizer(target: self,
                                                  action: #selector(self.respondToSwipeGesture(_:)))
        swipeRight.direction = UISwipeGestureRecognizer.Direction.right
        
        self.itemImageView.addGestureRecognizer(swipeLeft)
        self.itemImageView.addGestureRecognizer(swipeRight)
    }

    @objc func respondToSwipeGesture(_ gesture: UIGestureRecognizer) {

        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
        
            switch swipeGesture.direction {
            
            case UISwipeGestureRecognizer.Direction.left :
                pageControl.currentPage += 1
                itemImageView.image = UIImage(named: images[pageControl.currentPage])
                
            case UISwipeGestureRecognizer.Direction.right :
                pageControl.currentPage -= 1
                itemImageView.image = UIImage(named: images[pageControl.currentPage])
            default:
                break
            }
        }
    }
}
