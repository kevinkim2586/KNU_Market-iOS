import UIKit

class ChatTableViewCell: UITableViewCell {
    
    @IBOutlet weak var chatTitleLabel: UILabel!
    @IBOutlet weak var chatImageView: UIImageView!
    @IBOutlet weak var chatParticipatingCountLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func resetValues() {
        
        chatTitleLabel.text = nil
        chatImageView.image = nil
        chatParticipatingCountLabel.text = nil
    }


    func configure(with pid: String) {
        
        resetValues()
        
        
        
    }
    
    
    func configureImageView() {

        //chatImageView.layer.cornerRadius = chatImageView.frame.width / ?
        
    }
}
