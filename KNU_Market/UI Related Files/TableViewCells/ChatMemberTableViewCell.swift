import UIKit

class ChatMemberTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nicknameLabel: UILabel!
    
    private let group = DispatchGroup()
    
    private var imageCode: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(with userUID: String) {
        
        resetValues()
        
        fetchUserProfileInfo(userUID: userUID)
        initializeUI()
        
    }
    
    func resetValues() {
        
        profileImageView.image = nil
        nicknameLabel.text = nil
    }

    func fetchUserProfileInfo(userUID: String) {
        
        group.enter()
        
        UserManager.shared.loadOtherUsersProfile(userUID: userUID) { [weak self] result in
            
            switch result {
            
            case .success(let profileModel):
                self?.nicknameLabel.text = profileModel.nickname
                self?.imageCode = profileModel.profileImageCode
            case .failure:
                return
            }
            print("✏️ group.leave called")
            self?.group.leave()
        }
        
        group.notify(queue: .main) {
            print("✏️ DispatchGroup notify")
            self.fetchUserProfileImage(imageCode: self.imageCode!)
        }
    }
    
    func fetchUserProfileImage(imageCode: String) {
        
        MediaManager.shared.requestMedia(from: imageCode) { [weak self] result in
            
            switch result {
            
            case .success(let imageData):
                
                if let data = imageData {
                    self?.profileImageView.image = UIImage(data: data)
                } else {
                    self?.profileImageView.image = UIImage(named: Constants.Images.defaultProfileImage)
                }
            case .failure:
                self?.profileImageView.image = UIImage(named: Constants.Images.defaultProfileImage)
            }
        }
    }
    
    func initializeUI() {
        
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        
    }
}
