import UIKit
import SDWebImage

protocol ChatMemberTableViewCellDelegate: AnyObject {
    
    func presentUserReportVC(userToReport: String)
    func failedPresentingUserReportVC()
    
    func presentPostUploaderActionSheet(userUID: String, nickname: String)
}

class ChatMemberTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var reportUserButton: UIButton!
    
    private var imageCode: String?
    private var nickname: String?
    private var userUID: String?
    private var postUploaderUID: String?

    
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
    
    func configure(with userUID: String, postUploaderUID: String) {
        
        self.postUploaderUID = postUploaderUID
        fetchUserProfileInfo(userUID: userUID)
        initializeUI()
    }
    
    @IBAction func pressedReportUserButton(_ sender: UIButton) {
        
        guard let postUploaderUID = postUploaderUID else { return }
        guard let nickname = nickname else { return }
        guard let userUID = userUID else { return }

        if postUploaderUID == User.shared.userUID {
            self.delegate?.presentPostUploaderActionSheet(userUID: userUID, nickname: nickname)
        } else {
            self.delegate?.presentUserReportVC(userToReport: nickname)
        }
    }
    
    func fetchUserProfileInfo(userUID: String) {
        
        UserManager.shared.loadOtherUsersProfile(userUID: userUID) { [weak self] result in
            
            switch result {
            case .success(let profileModel):
                
                self?.nickname = profileModel.nickname
                self?.userUID = profileModel.uid
                
                self?.nicknameLabel.text = profileModel.nickname
                
                let imageURL = URL(string: "\(Constants.API_BASE_URL)media/\(profileModel.profileImageCode)")
                self?.profileImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
                                
                self?.profileImageView.sd_setImage(with: imageURL,
                                                   placeholderImage: UIImage(named: Constants.Images.chatMemberDefaultImage),
                                                   options: .continueInBackground,
                                                   completed: nil)
                self?.profileImageView.contentMode = .scaleAspectFit
                
                // 만약 본인 Cell 이면 신고하기 버튼 숨김 처리
                DispatchQueue.main.async {
                    if self?.userUID == User.shared.userUID {
                        self?.reportUserButton.isHidden = true
                    }
                }
            case .failure:
                return
            }
        }
    }

    func initializeUI() {
        
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        profileImageView.contentMode = .scaleAspectFill
    }
}
