import UIKit
import SDWebImage

protocol ChatMemberTableViewCellDelegate: AnyObject {
    
    func presentActionSheetForMembers(blockUID: String, reportNickname: String)
    func presentActionSheetForPostUploader(userUID: String, nickname: String)
}

class ChatMemberTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var reportUserButton: UIButton!
    @IBOutlet weak var crownImageView: UIImageView!
    
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
            self.delegate?.presentActionSheetForPostUploader(userUID: userUID, nickname: nickname)
        } else {
            self.delegate?.presentActionSheetForMembers(blockUID: userUID, reportNickname: nickname)
        }
    }
    
    func fetchUserProfileInfo(userUID: String) {
        
        UserManager.shared.loadOtherUsersProfile(userUID: userUID) { [weak self] result in
            
            switch result {
            case .success(let profileModel):
            
                self?.nickname = User.shared.bannedChatMembers.contains(profileModel.uid) ? "내가 차단한 유저" : profileModel.nickname
                self?.userUID = profileModel.uid
                self?.nicknameLabel.text = self?.nickname
                
                let imageURL = URL(string: "\(Constants.API_BASE_URL)media/\(profileModel.profileImageCode)")
                self?.profileImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
                                
                self?.profileImageView.sd_setImage(with: imageURL,
                                                   placeholderImage: UIImage(named: Constants.Images.chatMemberDefaultImage),
                                                   options: .continueInBackground,
                                                   completed: nil)
                self?.profileImageView.contentMode = .scaleToFill
                
                // 만약 본인 Cell 이면 신고하기 버튼 숨김 처리
                if self?.userUID == User.shared.userUID || User.shared.bannedChatMembers.contains(profileModel.uid) {
                    self?.reportUserButton.isHidden = true
                }
                
                self?.crownImageView.isHidden = self?.userUID == self?.postUploaderUID ? false : true
        
            case .failure(let error):
                
                self?.nicknameLabel.text = error == .E108 ? "탈퇴한 유저" : "정보 불러오기 실패"
                self?.profileImageView.image = UIImage(named: Constants.Images.chatMemberDefaultImage)
                self?.crownImageView.isHidden = true
                self?.reportUserButton.isHidden = true
                return
            }
        }
    }

    func initializeUI() {
        
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        
        if #available(iOS 14.0, *) {
            crownImageView.image = UIImage(systemName: "crown.fill")
            crownImageView.image?.withTintColor(.systemYellow)
        } else {
            crownImageView.image = UIImage(systemName: "checkmark.circle")
            crownImageView.image?.withTintColor(UIColor(named: Constants.Color.appColor) ?? .black)
        }
    }
}

