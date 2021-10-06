import UIKit

class KMTitleLabel: UILabel {
    
    private var fontSize: CGFloat?
    private var labelColor: UIColor?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    init(fontSize: CGFloat? = nil, textColor: UIColor) {
        super.init(frame: .zero)
        self.fontSize = fontSize
        self.labelColor = textColor
        configure()
    }
    
    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        textColor = labelColor ?? .darkGray
        font = .systemFont(ofSize: fontSize ?? 19, weight: .semibold)
        minimumScaleFactor = 0.80
    }
}
