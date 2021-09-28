import UIKit

class KMAlertButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
    
    init(backgroundColor: UIColor, title: String) {
        super.init(frame: .zero)
        
        self.backgroundColor = backgroundColor
        self.setTitle(title, for: .normal)
        configure()
    }
    
    private func configure() {
        
        layer.cornerRadius = 10
        titleLabel?.textColor = .white
        titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
        translatesAutoresizingMaskIntoConstraints = false               // use autolayout
    }

}
