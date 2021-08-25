import UIKit
import SDWebImage

class ItemTableViewCell: UITableViewCell {
    
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemTitleLabel: UILabel!
    @IBOutlet weak var gatheringLabel: UILabel!
    @IBOutlet weak var personImageView: UIImageView!
    @IBOutlet weak var currentlyGatheredPeopleLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    private var viewModel = ItemTableViewModel()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func resetValues() {
        
        itemImageView.image = nil
        itemTitleLabel.text = nil
        gatheringLabel.text = nil
        personImageView.image = nil
        currentlyGatheredPeopleLabel.text = nil
        locationLabel.text = nil
        
    }
    
    func configure(with model: ItemListModel) {

        resetValues()

        viewModel.uuid = model.uuid
        viewModel.title = model.title
        viewModel.location = model.location
        viewModel.totalGatheringPeople = model.totalGatheringPeople
        viewModel.currentlyGatheredPeople = model.currentlyGatheredPeople
        viewModel.isFull = model.isFull
        viewModel.isCompletelyDone = model.isCompletelyDone
        viewModel.date = model.date
        
        viewModel.imageUID = model.imageUIDs.isEmpty ? nil : model.imageUIDs[0].uid
        
        initialize()
    }

    func initialize() {
        
        initializeTitleLabel()
        initializeImageView()
        initializeGatheringLabel()
        initializePersonImageView()
        initializeCurrentlyGatheredPeopleLabel()
        initializeLocationLabel()
        initializeDateLabel()
    }
    
    func initializeTitleLabel() {
        
        itemTitleLabel.text = viewModel.title
        itemTitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
    }

    func initializeImageView() {
        
        if viewModel.imageUID != nil {
       
            itemImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
            itemImageView.sd_setImage(with: viewModel.imageURL,
                                      placeholderImage: UIImage(named: Constants.Images.defaultItemIcon),
                                      options: .continueInBackground,
                                      completed: nil)
        } else {
            itemImageView.image = viewModel.defaultImage
        }
    
        itemImageView.contentMode = .scaleAspectFill
        itemImageView.layer.cornerRadius = 5
    }
    
    func initializeGatheringLabel() {
        
        if viewModel.isCompletelyDone {
            
            gatheringLabel.text = "모집 완료"
            gatheringLabel.backgroundColor = UIColor.lightGray
            currentlyGatheredPeopleLabel.isHidden = true
            personImageView.isHidden = true
            
        }  else {
    
            gatheringLabel.text = "모집 중"
            gatheringLabel.backgroundColor = UIColor(named: Constants.Color.appColor)
            currentlyGatheredPeopleLabel.isHidden = false
            personImageView.isHidden = false
        }
        
        gatheringLabel.font = UIFont.systemFont(ofSize: 12.0, weight: .semibold)
        gatheringLabel.textColor = UIColor.white
        gatheringLabel.layer.masksToBounds = true
        gatheringLabel.layer.cornerRadius = gatheringLabel.frame.height / 2
    }
    
    func initializePersonImageView() {
        
        personImageView.image = UIImage(named: Constants.Images.peopleIcon)
    }
    
    
    func initializeCurrentlyGatheredPeopleLabel() {
        
        let currentNum = viewModel.currentlyGatheredPeople
        let total = viewModel.totalGatheringPeople
        
        currentlyGatheredPeopleLabel.textColor = UIColor.darkGray
        currentlyGatheredPeopleLabel.text = "\(currentNum)" + "/" + "\(total) 명"
        currentlyGatheredPeopleLabel.font = UIFont.systemFont(ofSize: 15.0, weight: .semibold)
        
    }
    
    func initializeLocationLabel() {
        
        locationLabel.text = viewModel.locationName
        
    }
    
    func initializeDateLabel() {
        dateLabel.text = viewModel.date
        dateLabel.textAlignment = .right
    }
}
