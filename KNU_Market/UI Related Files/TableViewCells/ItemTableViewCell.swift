import UIKit

class ItemTableViewCell: UITableViewCell {
    
    @IBOutlet weak var itemImageView: ItemImageView!
    @IBOutlet weak var itemTitleLabel: UILabel!
    @IBOutlet weak var gatheringLabel: UILabel!
    @IBOutlet weak var personImageView: UIImageView!
    @IBOutlet weak var currentlyGatheredPeopleLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    var isGathering: Bool = true
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        initialize()
  
    }

    func initialize() {
        
        
        initializeImageView()
        initializeLabels()
        
    
    }

    
    func initializeImageView() {
        
        itemImageView.layer.cornerRadius = 5
    }
    
    func initializeLabels() {
        
        gatheringLabel.text = "모집 중"
        gatheringLabel.font = gatheringLabel.font.withSize(12)
        gatheringLabel.textColor = UIColor.white
        gatheringLabel.backgroundColor = UIColor(named: Constants.Color.appColor)
        gatheringLabel.layer.masksToBounds = true
        gatheringLabel.layer.cornerRadius = gatheringLabel.frame.height / 2
        
    }
    
    
    
    
}
