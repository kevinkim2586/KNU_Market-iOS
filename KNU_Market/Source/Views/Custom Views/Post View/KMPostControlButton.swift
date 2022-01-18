import UIKit

//MARK: - 공구글 상단에 위치한 "뒤로 가기", "삭제하기", "더보기" 버튼 공통 클래스

class KMPostControlButton: UIButton {
    
    static let buttonSize: CGFloat      = 30
    private let buttonFontSize: CGFloat = 24
    
    private var buttonImageSystemName: String?
    private var customImageName: String?
    
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
    
    init(customImage: String) {
        super.init(frame: .zero)
        self.customImageName = customImage
        configure()
    }
    
    private func configure() {
        
        let font = UIFont.systemFont(ofSize: buttonFontSize)
        let configuration = UIImage.SymbolConfiguration(font: font)
        
        if let buttonImageSystemName = buttonImageSystemName {
            let buttonImage = UIImage(
                systemName: buttonImageSystemName,
                withConfiguration: configuration
            )
            setImage(buttonImage, for: .normal)
        }
        
        if let customImageName = customImageName {
            let buttonImage = UIImage(named: customImageName)
            setImage(buttonImage, for: .normal)
        }
        
        backgroundColor = .clear
        widthAnchor.constraint(equalToConstant: KMPostControlButton.buttonSize).isActive = true
        heightAnchor.constraint(equalToConstant: KMPostControlButton.buttonSize).isActive = true
        tintColor = .white
    }
}
