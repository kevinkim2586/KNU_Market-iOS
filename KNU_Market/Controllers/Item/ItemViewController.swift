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
    
    var images = ["bubble1", "bubble2", "bubble3"]
    
    private var viewModel: ItemViewModel = ItemViewModel()
    
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
    
}

//MARK: - UI Configuration

extension ItemViewController {
    
    func initialize() {
        
        initializeProfileImageView()
        
        initializeItemExplanationLabel()
        initializeGatheringPeopleLabel()
        initializeEnterChatButton()
        
        configurePageControl()
        
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
        itemExplanationLabel.attributedText = NSAttributedString(string: "누리관 레드돔인데 같이 시키실 분? 저녁 7시에 시킬 예정입니다.누리관 레드돔인데 같이 시키실 분? 저녁 7시에 시킬 예정입니다.누리관 레드돔인데 같이 시키실 분? 저녁 7시에 시킬레드돔인데 같이 시키실 분? 저녁 7시에 시", attributes: attributes)
        
    }
    
    func initializeGatheringPeopleLabel() {
        
        gatheringPeopleLabel.clipsToBounds = true
        gatheringPeopleLabel.backgroundColor = UIColor(named: Constants.Color.appColor)
        gatheringPeopleLabel.layer.cornerRadius = gatheringPeopleLabel.frame.height / 2
        gatheringPeopleLabel.text = "모집 중    " + "2" + "/" + "3 명"
        gatheringPeopleLabel.font = UIFont.systemFont(ofSize: 15.0, weight: .semibold)
        
    }
    
    func initializeEnterChatButton() {
        
        
        enterChatButton.backgroundColor = UIColor(named: Constants.Color.appColor)
        enterChatButton.layer.cornerRadius = enterChatButton.frame.height / 2
        enterChatButton.setTitle("채팅방 입장 💬", for: .normal)
        enterChatButton.titleLabel?.font = UIFont.systemFont(ofSize: 15.0, weight: .semibold)
        
        
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
