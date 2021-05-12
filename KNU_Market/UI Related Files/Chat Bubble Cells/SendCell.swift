import UIKit

class SendCell: UITableViewCell {

    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet weak var messageBubble: UIView!
    @IBOutlet weak var chatMessageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        initialize()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func initialize() {
        
        initializeMessageBubble()
        
    }
    
    func initializeMessageBubble() {
    
        messageBubble.layer.cornerRadius = messageBubble.frame.size.height / 5
    }
    
}
