import UIKit
import SDWebImage

class ChatTableViewCell: UITableViewCell {
    
    @IBOutlet weak var chatTitleLabel: UILabel!
    @IBOutlet weak var chatImageView: UIImageView!
    @IBOutlet weak var chatParticipatingCountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        chatTitleLabel.text = nil
        chatImageView.image = nil
        chatParticipatingCountLabel.text = nil
    }

    func configure(with model: Room) {
                
        if !model.imageCodes.isEmpty {
            
            let imageURL = URL(string: "\(Constants.API_BASE_URL)media/\(model.imageCodes[0])")
            chatImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
            chatImageView.sd_setImage(with: imageURL,
                                      placeholderImage: UIImage(named: Constants.Images.chatBubbleIcon),
                                      options: .continueInBackground,
                                      completed: nil)
        } else {
            chatImageView.image = UIImage(named: Constants.Images.chatBubbleIcon)
        }
        
        chatTitleLabel.text = model.title
        chatParticipatingCountLabel.text = "\(model.currentlyGatheredPeople)" + "/\(model.totalGatheringPeople) 명"
        
        configureImageView()
        configureTitleLabel()
        configureChatParticipatingCountLabel()
    }
    
    func configureImageView() {
        
        chatImageView.contentMode = .scaleAspectFit
        chatImageView.layer.cornerRadius = chatImageView.frame.height / 2
        
    }
    
    func configureTitleLabel() {
        
    }
    
    func configureChatParticipatingCountLabel() {
        
        chatParticipatingCountLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        
    }
}
