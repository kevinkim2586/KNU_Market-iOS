import UIKit

class ChatTableViewCell: UITableViewCell {
    
    @IBOutlet weak var chatTitleLabel: UILabel!
    @IBOutlet weak var chatImageView: UIImageView!
    @IBOutlet weak var chatParticipatingCountLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        //configureImageView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    
    //
    //    func configure(with model: []) {
    //
    //    }
    
    
    func configureImageView() {

        //chatImageView.layer.cornerRadius = chatImageView.frame.width / ?
        
    }
}
