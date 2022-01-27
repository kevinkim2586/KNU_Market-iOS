import UIKit

class KMDetailLabel: UILabel {
    
    private var fontSize: CGFloat?
    private var numberOfTotalLines: Int?
    
    private let minimumNumberOfLines: Int = 1
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    init(fontSize: CGFloat? = nil, numberOfTotalLines: Int) {
        super.init(frame: .zero)
        self.fontSize = fontSize
        self.numberOfTotalLines = numberOfTotalLines
        configure()
    }
    
    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        font = .systemFont(ofSize: fontSize ?? 14, weight: .medium)
        textColor = .lightGray
        numberOfLines = numberOfTotalLines ?? minimumNumberOfLines
    }
    
}
