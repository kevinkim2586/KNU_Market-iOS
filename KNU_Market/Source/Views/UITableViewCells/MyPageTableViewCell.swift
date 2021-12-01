import UIKit
import SnapKit

class MyPageTableViewCell: UITableViewCell {
    
    //MARK: - Constants
    
    static let cellId: String = "MyPageTableViewCell"
    
    fileprivate struct Metrics {
        static let notificationBadgeSize: CGFloat = 10
    }
    
    //MARK: - UI
    
    let leftImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .black
        return imageView
    }()
    
    let settingsTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .black
        return label
    }()
    
    let notificationBadgeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = Metrics.notificationBadgeSize / 2
        imageView.backgroundColor = .systemRed
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        return imageView
    }()
    
    //MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        notificationBadgeImageView.isHidden = true
    }
    
    //MARK: - Configuration
    
    func configure() {
        
        accessoryType = .disclosureIndicator
        contentView.addSubview(leftImageView)
        contentView.addSubview(settingsTitleLabel)
        contentView.addSubview(notificationBadgeImageView)
        makeConstraints()
    }
    
    func makeConstraints() {
        
        leftImageView.snp.makeConstraints { make in
            make.width.height.equalTo(25)
            make.left.equalTo(self.snp.left).offset(20)
            make.top.bottom.equalToSuperview()
        }
    
        settingsTitleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(self.snp.centerY)
            make.left.equalTo(leftImageView.snp.right).offset(12)
        }
        
        notificationBadgeImageView.snp.makeConstraints {
            $0.width.height.equalTo(Metrics.notificationBadgeSize)
            $0.centerY.equalTo(self.snp.centerY)
            $0.left.equalTo(settingsTitleLabel.snp.right).offset(10)
        }
    }

}
