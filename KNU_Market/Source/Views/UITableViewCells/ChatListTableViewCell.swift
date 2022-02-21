import UIKit
import SnapKit
import SDWebImage

class ChatListTableViewCell: UITableViewCell {

    //MARK: - Properties
    
    //MARK: - Constants
    
    static let cellId: String = "ChatListTableViewCell"
    
    fileprivate struct Metrics {
        
        static let chatImageViewSize: CGFloat       = 50
        static let notificationBadgeSize: CGFloat   = 10
        static let personImageViewSize: CGFloat     = 20
    }
    
    //MARK: - UI
    
    let chatRoomImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.borderWidth = 0.3
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        imageView.layer.cornerRadius = Metrics.chatImageViewSize / 2
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
        return imageView
    }()
    
    let notificationBadgeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = Metrics.notificationBadgeSize / 2
        imageView.backgroundColor = .systemRed
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        return imageView
    }()
    
    let chatRoomTitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .black
        return label
    }()
    
    let personImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "people icon")
        return imageView
    }()
    
    let currentlyParticipatingCountLabel: UILabel = {
        let label = UILabel()
        label.text = "- 명"
        label.textColor = UIColor.darkGray
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        return label
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
        chatRoomTitleLabel.text = nil
        chatRoomImageView.image = nil
        currentlyParticipatingCountLabel.text = nil
        chatRoomTitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        backgroundColor = .white
        notificationBadgeImageView.image = nil
        notificationBadgeImageView.isHidden = true
    }
    
    //MARK: - UI Setup
    
    private func setupLayout() {
        
        contentView.addSubview(chatRoomImageView)
        contentView.addSubview(notificationBadgeImageView)
        contentView.addSubview(chatRoomTitleLabel)
        contentView.addSubview(personImageView)
        contentView.addSubview(currentlyParticipatingCountLabel)
    }
    
    private func setupConstraints() {
        
        chatRoomImageView.snp.makeConstraints { make in
            make.width.height.equalTo(Metrics.chatImageViewSize)
            make.left.equalToSuperview().offset(15)
            make.centerY.equalToSuperview()
        }
        
        notificationBadgeImageView.snp.makeConstraints { make in
            make.width.height.equalTo(Metrics.notificationBadgeSize)
            make.left.equalToSuperview().offset(55)
            make.top.equalToSuperview().offset(15)
        }
        
        chatRoomTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(15)
            make.left.equalTo(chatRoomImageView.snp.right).offset(20)
            make.right.equalToSuperview().offset(-20)
        }
        
        personImageView.snp.makeConstraints { make in
            make.width.height.equalTo(Metrics.personImageViewSize)
            make.left.equalTo(chatRoomImageView.snp.right).offset(20)
            make.bottom.equalToSuperview().offset(-15)
        }
        
        currentlyParticipatingCountLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-15)
            make.left.equalTo(personImageView.snp.right).offset(10)
        }
    }
    
    //MARK: - Data Configuration
    
    func configure(with model: Room) {
        
        if let imagePath = model.postInfo.postFile?.files[0].location {
            
            let imageURL = URL(string: imagePath)
            
            chatRoomImageView.sd_setImage(
                with: imageURL,
                placeholderImage: UIImage(named: K.Images.chatBubbleIcon),
                options: .continueInBackground,
                completed: nil
            )
            chatRoomImageView.contentMode = .scaleAspectFill
        } else {
            chatRoomImageView.image = UIImage(named: K.Images.chatBubbleIcon)
            chatRoomImageView.contentMode = .scaleAspectFit
        }
        
        chatRoomTitleLabel.text = model.title
        currentlyParticipatingCountLabel.text = "\(model.channelMembersCount)" + "/\(model.headCount) 명"
        
        
        let currentChatNotificationList: [String] = UserDefaultsGenericService.shared.get(key: UserDefaults.Keys.notificationList) ?? []
        
        if currentChatNotificationList.contains(model.channelId) {
            configureUIWithNotification()
        }
    }
    
    // 읽지 않은 채팅이 있을 경우 UI 변경 적용 함수
    func configureUIWithNotification() {
        notificationBadgeImageView.isHidden = false
        chatRoomTitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .heavy)
        currentlyParticipatingCountLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        backgroundColor = .systemGray6
    }
    
}
