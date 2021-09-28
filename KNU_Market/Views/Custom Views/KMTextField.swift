import UIKit
import TextFieldEffects

class KMTextField: HoshiTextField {
    
    private var fontSize: CGFloat?
    private var placeHolderText: String?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    init(fontSize: CGFloat? = nil, placeHolderText: String) {
        super.init(frame: .zero)
        self.fontSize = fontSize
        self.placeHolderText = placeHolderText
        configure()
    }
    
    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        font = .systemFont(ofSize: fontSize ?? 18, weight: .semibold)
        placeholder = placeHolderText ?? "여기에 입력해주세요."
        placeholderFontScale = 1
        placeholderColor = .lightGray
        borderActiveColor = UIColor(named: Constants.Color.appColor) ?? .systemPink
        borderInactiveColor = .lightGray


    }
}


