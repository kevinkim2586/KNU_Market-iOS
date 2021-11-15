import UIKit

//MARK: - 공구글 상단에 위치한 "뒤로 가기", "삭제하기", "더보기" 버튼 공통 클래스

class KMPostControlButton: UIButton {
    
    static let buttonSize: CGFloat     = 35
    private let buttonFontSize: CGFloat = 15
    
    private var buttonImageSystemName: String?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    init(buttonImageSystemName: String) {
        super.init(frame: .zero)
        self.buttonImageSystemName = buttonImageSystemName
        configure()
    }
    
    private func configure() {
        
        let font = UIFont.systemFont(ofSize: buttonFontSize)
        let configuration = UIImage.SymbolConfiguration(font: font)
        let buttonImage = UIImage(
            systemName: self.buttonImageSystemName ?? "",
            withConfiguration: configuration
        )
        setImage(buttonImage, for: .normal)
        
        layer.cornerRadius = KMPostControlButton.buttonSize / 2
        backgroundColor = .white
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 2, height: 2)
        layer.shadowOpacity = 0.2
        layer.shadowRadius = 2
        widthAnchor.constraint(equalToConstant: KMPostControlButton.buttonSize).isActive = true
        heightAnchor.constraint(equalToConstant: KMPostControlButton.buttonSize).isActive = true
        tintColor = .black
    }

}
