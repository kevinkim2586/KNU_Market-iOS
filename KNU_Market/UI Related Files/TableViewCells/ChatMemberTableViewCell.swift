import UIKit
import SDWebImage

class ChatMemberTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nicknameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(with userUID: String) {
        
        resetValues()
        
        
    }
    
    func resetValues() {
        
        profileImageView.image = nil
        nicknameLabel.text = nil
    }

}
