import UIKit

class ItemViewController: UIViewController {
    
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var userIdLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var itemTitleLabel: UILabel!
    @IBOutlet weak var itemExplanationLabel: UILabel!
    @IBOutlet weak var gatheringPeopleLabel: UILabel!
    @IBOutlet weak var enterChatButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    private let refreshControl = UIRefreshControl()
    var images = ["bubble1", "bubble2", "bubble3"]
    
    private var viewModel = ItemViewModel()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        initialize()

    

 
    }
    
    @IBAction func pageChanged(_ sender: UIPageControl) {
        itemImageView.image = UIImage(named: images[pageControl.currentPage])
    }
    
    @IBAction func pressedMoreButton(_ sender: UIBarButtonItem) {
        
        //Action Sheet - 유저 신고하기
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
        
        initializeItemExplanationLabel()
        initializeGatheringPeopleLabel()
        initializeEnterChatButton()
        
        configurePageControl()
        
    }
    
    func initializeScrollView() {
        
        scrollView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshScrollView), for: .valueChanged)
    }
    
    func initializeProfileImageView() {
        
        userProfileImageView.image = viewModel.userProfileImage
        
        userProfileImageView.layer.cornerRadius = userProfileImageView.frame.width / 2
        userProfileImageView.layer.borderWidth = 1
        userProfileImageView.layer.borderColor = UIColor.black.cgColor
        
    }
    
    func initializeItemExplanationLabel() {
        
        let labelStyle = NSMutableParagraphStyle()
        labelStyle.lineSpacing = 5
        let attributes = [NSAttributedString.Key.paragraphStyle : labelStyle]
        itemExplanationLabel.attributedText = NSAttributedString(string: viewModel.itemExplanation, attributes: attributes)
        
    }
    
    func initializeGatheringPeopleLabel() {
        
        let currentNum = viewModel.currentlyGatheredPeople
        let total = viewModel.totalGatheringPeople
        
        if viewModel.isGathering {
            gatheringPeopleLabel.text = "모집 중     \(currentNum)" + "/" + "\(total) 명"
            gatheringPeopleLabel.backgroundColor = UIColor(named: Constants.Color.appColor)
        } else {
            gatheringPeopleLabel.text = "마감     \(currentNum)" + "/" + "\(total) 명"
            gatheringPeopleLabel.backgroundColor = UIColor.lightGray
        }
        gatheringPeopleLabel.clipsToBounds = true
        gatheringPeopleLabel.layer.cornerRadius = gatheringPeopleLabel.frame.height / 2
        gatheringPeopleLabel.font = UIFont.systemFont(ofSize: 15.0, weight: .semibold)
        
    }
    
    func initializeEnterChatButton() {
        
        if viewModel.isGathering {
            enterChatButton.backgroundColor = UIColor(named: Constants.Color.appColor)
        } else {
            enterChatButton.isUserInteractionEnabled = false
            enterChatButton.backgroundColor = UIColor.lightGray
        }

        enterChatButton.layer.cornerRadius = enterChatButton.frame.height / 2
        enterChatButton.setTitle("채팅방 입장 💬", for: .normal)
        enterChatButton.titleLabel?.font = UIFont.systemFont(ofSize: 15.0, weight: .semibold)
    }
    
    func initializeLocationLabel() {
        locationLabel.text = viewModel.location
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
