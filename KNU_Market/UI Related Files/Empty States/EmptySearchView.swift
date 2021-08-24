import UIKit

class EmptySearchView: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    private let xibName = "EmptySearchView"

    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    func initialize() {
        
        Bundle.main.loadNibNamed(xibName,
                                 owner: self,
                                 options: nil)
        contentView.fixInView(self)
        configureTitleLabel()
        configureImageView()
        
    }
    
    func configureTitleLabel() {
        
        titleLabel.text = "검색 결과가 없습니다."
        titleLabel.font = UIFont.systemFont(ofSize: 19, weight: .semibold)
        titleLabel.textColor = .darkGray
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        titleLabel.sizeToFit()
    }
    
    func configureImageView() {
        
        imageView.image = UIImage(named: "search")
        imageView.contentMode = .scaleAspectFit
    }
    
    func configure(imageName: String, text: String) {
        
        imageView.image = UIImage(named: imageName) ?? UIImage(named: "default item icon")!
        titleLabel.text = text
    }
    
}

extension UIView {
    
    func fixInView(_ container: UIView!) -> Void {
        self.translatesAutoresizingMaskIntoConstraints = false;
        self.frame = container.frame;
        container.addSubview(self);
        NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: container, attribute: .leading, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: container, attribute: .trailing, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: container, attribute: .top, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: container, attribute: .bottom, multiplier: 1.0, constant: 0).isActive = true
    }
}
