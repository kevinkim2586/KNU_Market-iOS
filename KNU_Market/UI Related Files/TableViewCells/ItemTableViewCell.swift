import UIKit

class ItemTableViewCell: UITableViewCell {
    
    @IBOutlet weak var itemImageView: ItemImageView!
    @IBOutlet weak var itemTitleLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var gatheringLabel: UILabel!
    @IBOutlet weak var personImageView: UIImageView!
    @IBOutlet weak var currentlyGatheredPeopleLabel: UILabel!
    
    var isGathering: Bool = true
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        initialize()
  
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    //
    //    func configure(with model: []) {
    //
    //    }
    
    func initialize() {
        
        itemImageView.layer.cornerRadius = 10.0
    }

}
