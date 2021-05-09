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

//MARK: - UI Configuration

extension ItemViewController {
    
    func initialize() {
        
        userProfileImageView.image = viewModel.userProfileImage
        
        configurePageControl()
        
    }
    
    
}
