import UIKit

class EmptyView: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    private let xibName = "EmptyView"

    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    func initialize() {
        Bundle.main.loadNibNamed(
            xibName,
            owner: self,
            options: nil
        )
        contentView.fixInView(self)
        configureTitleLabel()
        configureImageView()
        
    }
    
    func configureTitleLabel() {
        titleLabel.font = UIFont.systemFont(ofSize: 19, weight: .semibold)
        titleLabel.textColor = .darkGray
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 3
        titleLabel.sizeToFit()
    }
    
    func configureImageView() {
        imageView.contentMode = .scaleAspectFit
    }
    
    func configure(imageName: String, text: String) {
        imageView.image = UIImage(named: imageName) ?? UIImage(named: "default item icon")!
        titleLabel.text = text
    }
    
}

