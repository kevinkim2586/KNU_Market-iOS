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
    
    func addInnerShadow() {
        let innerShadow = CALayer()
        innerShadow.frame = bounds
        // Shadow path (1pt ring around bounds)
        let path = UIBezierPath(rect: innerShadow.bounds.insetBy(dx: -1, dy: -1))
        let cutout = UIBezierPath(rect: innerShadow.bounds).reversing()
        path.append(cutout)
        innerShadow.shadowPath = path.cgPath
        innerShadow.masksToBounds = true
        // Shadow properties
        innerShadow.shadowColor = UIColor.black.cgColor
        innerShadow.shadowOffset = CGSize(width: 0, height: 3)
        innerShadow.shadowOpacity = 0.05
        innerShadow.shadowRadius = 3
        innerShadow.cornerRadius = self.frame.size.height/2
        layer.addSublayer(innerShadow)
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

