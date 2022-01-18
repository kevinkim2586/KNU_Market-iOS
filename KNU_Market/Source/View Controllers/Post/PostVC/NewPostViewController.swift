//
//  NewPostViewController.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2022/01/18.
//

import UIKit
import SDWebImage
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit
import LabelSwitch

class NewPostViewController: BaseViewController {
    
//    typealias Reactor = PostViewReactor
    
    //MARK: - Properties
    
    private lazy var upperImageViewHeight = view.frame.height / 2
    private lazy var upperImageViewMaxHeight = view.frame.height / 2
    private lazy var upperImageViewMinHeight = 100.f
    private lazy var startingUpperImageViewHeight = upperImageViewMaxHeight
    
    //MARK: - Constants
    
    fileprivate struct Metrics {
        static let profileImageViewSize = 15.f
        static let defaultOffSet        = 25.f
    }
    
    fileprivate struct Colors {
        static let labelLightGrayColor = UIColor.convertUsingHexString(hexValue: "#9D9D9D")
    }
    
    //MARK: - UI
    
    let upperImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.sd_imageIndicator = SDWebImageActivityIndicator.gray
        $0.backgroundColor = UIColor(named: K.Color.appColor)
    }
    
    let bottomContainerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 25
        $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    let profileImageView = UIImageView().then {
        $0.image = UIImage(named: K.Images.defaultUserPlaceholder)
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.cornerRadius = Metrics.profileImageViewSize / 2
    }
    
    let userNicknameLabel = UILabel().then {
        $0.text = "참치러버"
        $0.textColor = Colors.labelLightGrayColor
        $0.numberOfLines = 1
        $0.font = UIFont(name: K.Fonts.notoSansKRRegular, size: 12)
    }
    
    let bulletPointLabel = UILabel().then {
        $0.textColor = Colors.labelLightGrayColor
        $0.text = "•"
        $0.numberOfLines = 1
        $0.font = UIFont(name: K.Fonts.notoSansKRRegular, size: 12)
    }
    
    let dateLabel = UILabel().then {
        $0.text = "1일 전"
        $0.textColor = Colors.labelLightGrayColor
        $0.numberOfLines = 1
        $0.font = UIFont(name: K.Fonts.notoSansKRRegular, size: 12)
    }
    
    let userInfoStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fill
        $0.alignment = .fill
        $0.spacing = 7
    }
    
    let postTitleLabel = UILabel().then {
        $0.text = "Leep 천연 수제비누 5개입"
        $0.textColor = .black
        $0.numberOfLines = 2
        $0.adjustsFontSizeToFitWidth = true
        $0.minimumScaleFactor = 0.8
        $0.font = UIFont(name: K.Fonts.notoSansKRMedium, size: 21)
    }
    
    let gatherStatusView = KMGatherStatusView(frame: CGRect(x: 0, y: 0, width: 69, height: 30)).then {
        $0.backgroundColor = UIColor(named: K.Color.appColor)
        $0.layer.cornerRadius = 15
        $0.toggleAsDoneGathering()
    }
    
    lazy var leftSwitchConfig = LabelSwitchConfig(
        text: "모집완료",
        textColor: .white,
        font: UIFont(name: K.Fonts.notoSansKRMedium, size: 12)!,
        backgroundColor: Colors.labelLightGrayColor
    )
    
    lazy var rightSwitchConfig = LabelSwitchConfig(
        text: "모집중 1/9",
        textColor: .white,
        font: UIFont(name: K.Fonts.notoSansKRMedium, size: 10)!,
        backgroundColor: UIColor(named: K.Color.appColor)!
    )
    
    lazy var gatherStatusToggleSwitch = LabelSwitch(
        center: .zero,
        leftConfig: leftSwitchConfig,
        rightConfig: rightSwitchConfig
    ).then {
        $0.circleShadow = false
        $0.circleColor = .white
        $0.fullSizeTapEnabled = true
    }
    
    let perPersonLabel = UILabel().then {
        $0.text = "1인당"
        $0.adjustsFontSizeToFitWidth = true
        $0.textAlignment = .right
        $0.textColor = UIColor.lightGray
        $0.font = UIFont(name: K.Fonts.notoSansKRRegular, size: 14)
    }
    
    let priceLabel = UILabel().then {
        $0.text = "10,000"
        $0.textColor = .black
        $0.font = UIFont(name: K.Fonts.robotoBold, size: 26)
    }
    
    let wonLabel = UILabel().then {
        $0.text = "원"
        $0.textColor = UIColor.lightGray
        $0.font = UIFont(name: K.Fonts.notoSansKRRegular, size: 14)
    }
    
    let divider = UIView().then {
        $0.backgroundColor = UIColor.convertUsingHexString(hexValue: "#E7E7E7")
    }
    
    let postDetailLabel = UILabel().then {
        $0.font = UIFont(name: K.Fonts.notoSansKRLight, size: 14)
        $0.textColor = .black
        $0.numberOfLines = 0
        $0.text = "leep에서 판매하는 천연 수제비누입니다. 성분도 좋고 양도 많아서 꾸준히 사용하고 있어요. 이번에 세일해서 구매하려고 하는데 같이 사실 분 구합니다~~~"
    }
    
    let enterChatButton = KMShadowButton(buttonTitle: "채팅방 입장하기")
    
    let urlLinkButton = UIButton(type: .system).then {
        $0.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOffset = CGSize(width: 1, height: 1)
        $0.layer.shadowOpacity = 0.4
        $0.layer.shadowRadius = 5
        $0.layer.cornerRadius = 10
        $0.layer.cornerRadius = 20
        $0.setTitle("링크 보러가기", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.titleLabel?.font = UIFont(name: K.Fonts.notoSansKRMedium, size: 13)
        let buttonImage = UIImage(
            systemName: "arrow.up.right",
            withConfiguration: UIImage.SymbolConfiguration(font: .systemFont(ofSize: 12))
        )
        $0.tintColor = .black
        $0.setImage(buttonImage, for: .normal)
        $0.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        $0.titleLabel?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        $0.imageView?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
    }
    
    let postControlButtonView = KMPostButtonView()
    

    //MARK: - Initialization
    
    override init() {
        super.init()
        hidesBottomBarWhenPushed = true
    }
    
//    init(reactor: Reactor) {
//        super.init()
//        hidesBottomBarWhenPushed = true
//        self.reactor = reactor
//    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurePanGestureRecognizer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    //MARK: - UI Setup

    
    override func setupLayout() {
        super.setupLayout()
        
        view.addSubview(upperImageView)
        view.addSubview(bottomContainerView)
        view.addSubview(urlLinkButton)
        view.addSubview(postControlButtonView)
        
        [profileImageView, userNicknameLabel, bulletPointLabel, dateLabel].forEach {
            userInfoStackView.addArrangedSubview($0)
        }
        
        bottomContainerView.addSubview(userInfoStackView)
        bottomContainerView.addSubview(postTitleLabel)
        bottomContainerView.addSubview(gatherStatusView)
        bottomContainerView.addSubview(gatherStatusToggleSwitch)
        bottomContainerView.addSubview(wonLabel)
        bottomContainerView.addSubview(priceLabel)
        bottomContainerView.addSubview(perPersonLabel)
        bottomContainerView.addSubview(divider)
        bottomContainerView.addSubview(postDetailLabel)
        bottomContainerView.addSubview(enterChatButton)
    
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        upperImageView.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.height.equalTo(view.frame.height / 2)
        }
        
        postControlButtonView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.height.equalTo(50)
            $0.left.right.equalToSuperview()
        }
        
        bottomContainerView.snp.makeConstraints {
            $0.top.equalTo(upperImageView.snp.bottom).offset(-15)
            $0.bottom.left.right.equalToSuperview()
        }
        
        urlLinkButton.snp.makeConstraints {
            $0.width.equalTo(124)
            $0.height.equalTo(39)
            $0.bottom.equalTo(bottomContainerView.snp.top).offset(-15)
            $0.centerX.equalToSuperview()
        }
        
        profileImageView.snp.makeConstraints {
            $0.width.height.equalTo(15)
        }
        
        userInfoStackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(35)
            $0.left.equalToSuperview().offset(25)
        }
        
        postTitleLabel.snp.makeConstraints {
            $0.top.equalTo(userInfoStackView.snp.bottom).offset(8)
            $0.left.equalToSuperview().offset(25)
            $0.right.equalToSuperview().offset(-25)
        }
        
//        gatherStatusView.snp.makeConstraints {
//            $0.width.equalTo(69)
//            $0.height.equalTo(30)
//            $0.top.equalTo(postTitleLabel.snp.bottom).offset(20)
//            $0.left.equalToSuperview().offset(25)
//        }
        
        gatherStatusToggleSwitch.snp.makeConstraints {
            $0.width.equalTo(81)
            $0.height.equalTo(26)
            $0.top.equalTo(postTitleLabel.snp.bottom).offset(20)
            $0.left.equalToSuperview().offset(25)
        }
        
        wonLabel.snp.makeConstraints {
            $0.right.equalToSuperview().offset(-Metrics.defaultOffSet)
            $0.top.equalTo(postTitleLabel.snp.bottom).offset(26)
        }

        priceLabel.snp.makeConstraints {
            $0.right.equalTo(wonLabel.snp.left).offset(-2)
            $0.top.equalTo(postTitleLabel.snp.bottom).offset(19)
        }

        perPersonLabel.snp.makeConstraints {
            $0.right.equalTo(priceLabel.snp.left).offset(-2)
            $0.top.equalTo(postTitleLabel.snp.bottom).offset(26)
        }
        
        divider.snp.makeConstraints {
            $0.height.equalTo(0.5)
            $0.left.right.equalToSuperview()
            $0.top.equalTo(gatherStatusToggleSwitch.snp.bottom).offset(20)
        }

        postDetailLabel.snp.makeConstraints {
            $0.top.equalTo(divider.snp.bottom).offset(10)
            $0.left.right.equalToSuperview().inset(Metrics.defaultOffSet)
        }
        
        enterChatButton.snp.makeConstraints {
            $0.height.equalTo(50)
            $0.bottom.equalToSuperview().offset(-30)
            $0.left.right.equalToSuperview().inset(Metrics.defaultOffSet)
        }
    }
    
    //MARK: - Binding
    
//    func bind(reactor: PostViewReactor) {
//
//    }

}

extension NewPostViewController {
    
    private func configurePanGestureRecognizer() {
        let panGesture = UIPanGestureRecognizer(
            target: self,
            action: #selector(viewPanned(_:))
        )
        panGesture.delaysTouchesBegan = false
        panGesture.delaysTouchesEnded = false
        view.addGestureRecognizer(panGesture)
    }

    private func nearest(to number: CGFloat, inValues values: [CGFloat]) -> CGFloat {
        guard let nearestVal = values.min(by: { abs(number - $0) < abs(number - $1) }) else { return number }
        return nearestVal
    }
    
    private func changeTopImageViewHeight(to height: CGFloat, option: UIView.AnimationOptions) {
        upperImageView.snp.updateConstraints {
            $0.height.equalTo(height)
        }
        
        UIView.animate(withDuration: 0.2, delay: 0, options: option, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    @objc private func viewPanned(_ panGestureRecognizer: UIPanGestureRecognizer) {
        let translation = panGestureRecognizer.translation(in: self.view)
        let velocity = panGestureRecognizer.velocity(in: self.view)
        
        switch panGestureRecognizer.state {
        case .began:
            startingUpperImageViewHeight = upperImageViewHeight
        case .changed:
            let modifiedTopClearViewHeight = startingUpperImageViewHeight + translation.y
            if modifiedTopClearViewHeight > upperImageViewMinHeight && modifiedTopClearViewHeight < upperImageViewMaxHeight {
                upperImageView.snp.updateConstraints {
                    $0.height.equalTo(modifiedTopClearViewHeight)
                }
            }
        case .ended:
            if velocity.y > 1500 {
                changeTopImageViewHeight(to: upperImageViewMaxHeight, option: .curveEaseOut)
            } else if velocity.y < -1500 {
                changeTopImageViewHeight(to: upperImageViewMinHeight, option: .curveEaseOut)
            } else {
                let nearestVal = nearest(to: upperImageViewHeight, inValues: [upperImageViewMaxHeight, upperImageViewMinHeight])
                changeTopImageViewHeight(to: nearestVal, option: .curveEaseIn)
            }
        default:
            break
        }
    }
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI

@available(iOS 13.0, *)
struct NewPostVC: PreviewProvider {
    
    static var previews: some SwiftUI.View {
        NewPostViewController().toPreview()
    }
}
#endif
