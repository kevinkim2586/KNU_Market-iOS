import UIKit

class ItemTableViewCell: UITableViewCell {
    
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemTitleLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var gatheringLabel: UILabel!
    @IBOutlet weak var personImageView: UIImageView!
    @IBOutlet weak var currentlyGatheredPeopleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
  
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
