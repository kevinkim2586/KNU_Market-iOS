import UIKit
import SDWebImage

class ChatTableViewCell: UITableViewCell {
    
    @IBOutlet weak var chatTitleLabel: UILabel!
    @IBOutlet weak var chatImageView: UIImageView!
    @IBOutlet weak var chatParticipatingCountLabel: UILabel!
    @IBOutlet weak var notificationImageView: UIImageView!
    
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
        notificationImageView.image = nil
        backgroundColor = .white
    }
    
    func configure(with model: Room) {
                
        if !model.imageCodes.isEmpty {
            
            let imageURL = URL(string: "\(Constants.API_BASE_URL)media/\(model.imageCodes[0])")
            chatImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
            chatImageView.sd_setImage(with: imageURL,
                                      placeholderImage: UIImage(named: Constants.Images.chatBubbleIcon),
                                      options: .continueInBackground,
                                      completed: nil)
            chatImageView.contentMode = .scaleToFill
        } else {
            chatImageView.image = UIImage(named: Constants.Images.chatBubbleIcon)
            chatImageView.contentMode = .scaleAspectFit
        }
        
        chatTitleLabel.text = model.title
        chatParticipatingCountLabel.text = "\(model.currentlyGatheredPeople)" + "/\(model.totalGatheringPeople) 명"
        
        notificationImageView.isHidden = true
        configureImageView()
        configureTitleLabel()
        configureChatParticipatingCountLabel()
        configureNotificationImageView()
        
        if ChatNotifications.list.contains(model.uuid) {
            configureUIWithNotification()
        }
     
    }
    
    func configureImageView() {
        chatImageView.layer.borderWidth = 1
        chatImageView.layer.borderColor = UIColor.clear.cgColor
        chatImageView.layer.cornerRadius = chatImageView.bounds.height / 2
    }
    
    func configureTitleLabel() {
        chatTitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
    }
    
    func configureChatParticipatingCountLabel() {
        chatParticipatingCountLabel.textColor = UIColor.darkGray
        chatParticipatingCountLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
    }
    
    func configureNotificationImageView() {
        notificationImageView.layer.cornerRadius = notificationImageView.bounds.height / 2
    }
    
    func configureUIWithNotification() {
        
        notificationImageView.isHidden = false
        chatTitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .heavy)
        chatParticipatingCountLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        backgroundColor = .systemGray6
    }
}
