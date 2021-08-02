import UIKit
import SDWebImage

protocol ChatMemberTableViewCellDelegate: AnyObject {
    
    func presentUserReportVC(userToReport: String)
    func failedPresentingUserReportVC()
}

class ChatMemberTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nicknameLabel: UILabel!
    
    private var imageCode: String?
    private var nickname: String?
    
    weak var delegate: ChatMemberTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        profileImageView.image = nil
        nicknameLabel.text = nil
    }
    
    @IBAction func pressedReportUserButton(_ sender: UIButton) {
        
        guard let nickname = self.nickname else {
            self.delegate?.failedPresentingUserReportVC()
            return
        }
        self.delegate?.presentUserReportVC(userToReport: nickname)
    }
    
    func configure(with userUID: String) {
        
        fetchUserProfileInfo(userUID: userUID)
        initializeUI()
    }

    func fetchUserProfileInfo(userUID: String) {
        
        UserManager.shared.loadOtherUsersProfile(userUID: userUID) { [weak self] result in
            
            switch result {
            case .success(let profileModel):
                
                self?.nickname = profileModel.nickname
                self?.nicknameLabel.text = profileModel.nickname
                let imageURL = URL(string: "\(Constants.API_BASE_URL)media/\(profileModel.profileImageCode)")
                self?.profileImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
                self?.profileImageView.sd_setImage(with: imageURL,
                                                   placeholderImage: UIImage(named: Constants.Images.defaultProfileImage),
                                                   options: .continueInBackground,
                                                   completed: nil)
            case .failure:
                return
            }
        }
    }

    func initializeUI() {
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
    }
}
