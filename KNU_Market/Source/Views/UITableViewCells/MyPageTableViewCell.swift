import UIKit

class MyPageTableViewCell: UITableViewCell {

    @IBOutlet weak var leftImageView: UIImageView!
    @IBOutlet weak var settingsTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configure()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    private func configure() {
        settingsTitleLabel.font = .systemFont(ofSize: 16, weight: .medium)
    }

}
