import UIKit

class KMBottomButton: UIButton {
    
    let heightConstantForKeyboardAppeared: CGFloat = 60
    let heightConstantForKeyboardHidden: CGFloat = 80
    
    var buttonTitle: String?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    init(buttonTitle: String) {
        super.init(frame: .zero)
        self.buttonTitle = buttonTitle
        configure()
    }
    
    private func configure() {
        setTitle(buttonTitle ?? "다음", for: .normal)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = UIColor(named: K.Color.appColor)
        setTitleColor(.white, for: .normal)
        setTitleColor(.lightGray, for: .highlighted)
        titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func updateTitleEdgeInsetsForKeyboardAppeared() {
        titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        setTitle(buttonTitle ?? "다음", for: .normal)
    }
    
    func updateTitleEdgeInsetsForKeyboardHidden() {
        self.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        setTitle(buttonTitle ?? "다음", for: .normal)
    }
}
