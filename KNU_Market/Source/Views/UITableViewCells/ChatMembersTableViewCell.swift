import UIKit
import SDWebImage
import SnapKit

protocol ChatMembersTableViewCellDelegate: AnyObject {
    func presentActionSheetForMembers(blockUID: String, reportNickname: String)
    func presentActionSheetForPostUploader(userUID: String, nickname: String)
}

class ChatMembersTableViewCell: UITableViewCell {

    //MARK: - Properties
    
    private var userUid: String?
    private var postUploaderUid: String?
    private var nickname: String?
    private var userManager: UserManager?
    
    weak var delegate: ChatMembersTableViewCellDelegate?
    
    //MARK: - Constants
    
    static let cellId: String = "ChatMembersTableViewCell"
    
    fileprivate struct Metrics {
        static let profileImageViewSize: CGFloat = 45
    }
    
    //MARK: - UI
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = Metrics.profileImageViewSize / 2
        imageView.clipsToBounds = true
        imageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
        return imageView
    }()
    
    let nicknameLabel: UILabel = {
        let label = UILabel()
        label.text = "로딩 중.."
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    lazy var crownImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        if #available(iOS 14.0, *) {
            imageView.image = UIImage(systemName: "crown.fill")?
                .withRenderingMode(.alwaysOriginal)
                .withTintColor(.systemYellow)
        } else {
            imageView.image = UIImage(systemName: "checkmark.circle")?
                .withRenderingMode(.alwaysOriginal)
                .withTintColor(UIColor(named: K.Color.appColor) ?? .black)
        }
        return imageView
    }()
    
    lazy var reportUserButton: UIButton = {
        let button = UIButton()
        button.setImage(
            UIImage(systemName: "exclamationmark.octagon"),
            for: .normal
        )
        button.addTarget(
            self,
            action: #selector(pressedReportUserButton),
            for: .touchUpInside
        )
        button.isHidden = false
        button.tintColor = .black
        return button
    }()
    
    
    //MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        profileImageView.image = nil
        nicknameLabel.text = nil
    }
    
    //MARK: - UI Setup
    
    private func setupLayout() {
        
        contentView.addSubview(profileImageView)
        contentView.addSubview(nicknameLabel)
        contentView.addSubview(crownImageView)
        contentView.addSubview(reportUserButton)
    }
    
    private func setupConstraints() {
        
        profileImageView.snp.makeConstraints { make in
            make.width.height.equalTo(Metrics.profileImageViewSize)
            make.left.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
        }
        
        nicknameLabel.snp.makeConstraints { make in
            make.left.equalTo(profileImageView.snp.right).offset(15)
            make.centerY.equalToSuperview()
        }
        
        crownImageView.snp.makeConstraints { make in
            make.left.equalTo(nicknameLabel.snp.right).offset(15)
            make.centerY.equalToSuperview()
        }
        
        reportUserButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
        }
    }
    
    //MARK: - Data Configuration
    
    func configure(userManager: UserManager, userUid: String, postUploaderUid: String) {
        self.userManager = userManager
        self.postUploaderUid = postUploaderUid
        self.fetchUserProfileInfo(userUid: userUid)
    }
}


//MARK: - Target Methods
extension ChatMembersTableViewCell {
    
    @objc private func pressedReportUserButton() {
        guard
            let postUploaderUid = postUploaderUid,
            let nickname = nickname,
            let userUid = userUid
        else { return }
        
        postUploaderUid == User.shared.userUID
        ? delegate?.presentActionSheetForPostUploader(userUID: userUid, nickname: nickname)
        : delegate?.presentActionSheetForMembers(blockUID: userUid, reportNickname: nickname)
    }
    
    private func fetchUserProfileInfo(userUid: String) {
        
        userManager?.loadOtherUsersProfile(userUID: userUid) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let profileModel):
                
                self.nickname = User.shared.bannedChatMembers.contains(profileModel.uid)
                ? "내가 차단한 유저"
                : profileModel.nickname
                
                self.userUid = profileModel.uid
                self.nicknameLabel.text = self.nickname
                
                let imageURL = URL(string: "\(K.MEDIA_REQUEST_URL)\(profileModel.profileImageCode)")
                
                self.profileImageView.sd_setImage(
                    with: imageURL,
                    placeholderImage: UIImage(named: K.Images.chatMemberDefaultImage),
                    options: .continueInBackground,
                    completed: nil
                )
                self.profileImageView.contentMode = .scaleToFill
                
                // 만약 본인 Cell 이거나 내가 차단한 유저면 신고하기 버튼 숨김 처리
                if self.userUid == User.shared.userUID || User.shared.bannedChatMembers.contains(profileModel.uid) {
                    self.reportUserButton.isHidden = true
                }
                
                // 공구를 올린 "방장"이면 왕관 표시 보여주기
                self.crownImageView.isHidden = self.userUid == self.postUploaderUid
                ? false
                : true
                
            case .failure(let error):
                self.nicknameLabel.text = error == .E108 ? "탈퇴한 유저" : "정보 불러오기 실패"
                self.profileImageView.image = UIImage(named: K.Images.chatMemberDefaultImage)
                self.crownImageView.isHidden = true
                self.reportUserButton.isHidden = true
                return
            }
        }
    }
    
}
