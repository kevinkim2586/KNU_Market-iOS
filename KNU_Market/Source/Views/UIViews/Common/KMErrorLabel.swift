import UIKit

class KMErrorLabel: UILabel {
    
    let fontSize: CGFloat = 14.0
    
    var labelMessage: String = "알 수 없는 오류가 발생했어요."
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    init() {
        super.init(frame: .zero)
        configure()
    }
    
    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        textColor = UIColor(named: K.Color.appColor)
        font = .systemFont(ofSize: fontSize, weight: .semibold)
    }
    
    func showErrorMessage(message: String) {
        isHidden = false
        text = message
        textColor = UIColor(named: K.Color.appColor) ?? .systemPink
    }
}
