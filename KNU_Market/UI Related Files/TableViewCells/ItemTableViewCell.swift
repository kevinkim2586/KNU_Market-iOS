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
        viewModel.imageUID = model.imageUID ?? ""
        viewModel.currentlyGatheredPeople = model.currentlyGatheredPeople
        viewModel.date = model.date
        
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
    }

    func initializeImageView() {
        
        if viewModel.imageUID.isEmpty {
            itemImageView.image = viewModel.defaultImage
        } else {
            itemImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
            itemImageView.sd_setImage(with: viewModel.imageURL,
                                      placeholderImage: UIImage(named: Constants.Images.defaultItemIcon),
                                      options: .continueInBackground,
                                      completed: nil)
        }
        itemImageView.contentMode = .scaleAspectFill
        itemImageView.layer.cornerRadius = 5
    }
    
    func initializeGatheringLabel() {
        
        if viewModel.isGathering {
            gatheringLabel.text = "모집 중"
            gatheringLabel.backgroundColor = UIColor(named: Constants.Color.appColor)
        
        } else {
            gatheringLabel.text = "마감"
            gatheringLabel.backgroundColor = UIColor.lightGray
        }
        
        
        gatheringLabel.font = UIFont.systemFont(ofSize: 12.0, weight: .semibold)
        gatheringLabel.textColor = UIColor.white
        gatheringLabel.layer.masksToBounds = true
        gatheringLabel.layer.cornerRadius = gatheringLabel.frame.height / 2
    }
    
    func initializePersonImageView() {
        
        personImageView.image = UIImage(named: "people icon")
    }
    
    
    func initializeCurrentlyGatheredPeopleLabel() {
        
        let currentNum = viewModel.currentlyGatheredPeople
        let total = viewModel.totalGatheringPeople
        
        currentlyGatheredPeopleLabel.text = "\(currentNum)" + "/" + "\(total) 명"
        currentlyGatheredPeopleLabel.font = UIFont.systemFont(ofSize: 15.0, weight: .semibold)
        
    }
    
    func initializeLocationLabel() {
        
        locationLabel.text = viewModel.locationName
        
    }
    
    func initializeDateLabel() {
        
        dateLabel.text = viewModel.date
    }
    
    
    
    
}
