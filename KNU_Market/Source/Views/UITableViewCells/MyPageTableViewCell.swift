import UIKit
import SnapKit

class MyPageTableViewCell: UITableViewCell {
    
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
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
    
    func configure() {
        
        accessoryType = .disclosureIndicator
        contentView.addSubview(leftImageView)
        contentView.addSubview(settingsTitleLabel)
        makeConstraints()
    }
    
    func makeConstraints() {
        
        leftImageView.snp.makeConstraints { make in
            make.width.height.equalTo(25)
            make.top.left.bottom.equalToSuperview()
        }
    
        settingsTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top).offset(9)
            make.left.equalTo(leftImageView.snp.right).offset(10)
            
        }
        
    }

}
