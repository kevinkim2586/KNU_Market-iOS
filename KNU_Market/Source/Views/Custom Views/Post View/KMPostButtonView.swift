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
    
    // gatheringStatusButton 이 들어갈 UIView
    let gatheringStatusView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray
        view.layer.cornerRadius = KMPostControlButton.buttonSize / 2
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 2, height: 2)
        view.layer.shadowOpacity = 0.2
        view.layer.shadowRadius = 2
        view.isHidden = true
        return view
    }()
    
    // 모집 중, 모집완료 설정 버튼
    lazy var gatheringStatusButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(
            self,
            action: #selector(pressedGatheringStatusButton),
            for: .touchUpInside
        )
        button.setTitle("모집 완료 ⌵", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        return button
    }()
    
    // 더보기 버튼
    lazy var menuButton: KMPostControlButton = {
        let button = KMPostControlButton(buttonImageSystemName: "ellipsis")
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

        if isPostUserUploaded {
            gatheringStatusView.isHidden = false
            
            if isCompletelyDone {
                
                gatheringStatusView.backgroundColor = .lightGray
                gatheringStatusButton.setTitleColor(.white, for: .normal)
                gatheringStatusButton.setTitle("모집 완료  ⌵", for: .normal)
            } else {
                gatheringStatusView.backgroundColor = UIColor(named: K.Color.appColor)
                gatheringStatusButton.setTitle("모집 중  ⌵", for: .normal)
            }
            
        } else {
            gatheringStatusView.isHidden = true
        }
    }
    
    //MARK: - UI Setup
    
    private func setupLayout() {
        
        addSubview(backButton)
//        addSubview(gatheringStatusView)
//        gatheringStatusView.addSubview(gatheringStatusButton)
        addSubview(menuButton)
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
        
     
//        gatheringStatusView.snp.makeConstraints {
//            $0.width.equalTo(100)
//            $0.height.equalTo(35)
//            $0.right.equalTo(trashButton.snp.left).offset(-20)
//            $0.top.equalToSuperview().offset(10)
//        }
//
//        gatheringStatusButton.snp.makeConstraints {
//            $0.center.equalToSuperview()
//        }
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
