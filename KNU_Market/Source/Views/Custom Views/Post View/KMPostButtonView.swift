import Foundation
import SnapKit
import UIKit

protocol KMPostButtonViewDelegate: AnyObject {
    func didPressBackButton()
    func didPressGatheringStatusButton()
    func didPressMenuButton()
}

class KMPostButtonView: UIView {
    
    //MARK: - Properties

    weak var delegate: KMPostButtonViewDelegate?

    //MARK: - Constants
    
    //MARK: - UI
    
    // 뒤로가기 버튼
    lazy var backButton: KMPostControlButton = {
        let button = KMPostControlButton(buttonImageSystemName: "arrow.left")
        button.addTarget(
            self,
            action: #selector(pressedBackButton),
            for: .touchUpInside
        )
        return button
    }()
    
    lazy var shareButton: KMPostControlButton = {
        let button = KMPostControlButton(customImage: "shareButton")
        return button
    }()

    
    // 더보기 버튼
    lazy var menuButton: KMPostControlButton = {
        let button = KMPostControlButton(customImage: "menuButton")
        return button
    }()
    
    //MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        setupLayout()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    

    func configure(isPostUserUploaded: Bool, isCompletelyDone: Bool) {

    }
    
    //MARK: - UI Setup
    
    private func setupLayout() {
        
        addSubview(backButton)
        addSubview(menuButton)
        addSubview(shareButton)
    }
    
    private func setupConstraints() {
     
        backButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.left.equalToSuperview().offset(15)
        }
        
        menuButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.right.equalToSuperview().offset(-15)
        }
        
        shareButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.right.equalTo(menuButton.snp.left).offset(-15)
        }
    }
}

//MARK: - Target Methods

extension KMPostButtonView {
    
    @objc private func pressedBackButton() {
        delegate?.didPressBackButton()
    }
    
    @objc private func pressedGatheringStatusButton() {
        delegate?.didPressGatheringStatusButton()
    }
    
    @objc private func pressedMenuButton() {
        delegate?.didPressMenuButton()
    }
}
