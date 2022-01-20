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
import ImageSlideshow
import RxGesture
import FirebaseDynamicLinks

class NewPostViewController: BaseViewController, ReactorKit.View {

    typealias Reactor = PostViewReactor
    
    //MARK: - Properties
    
    private lazy var upperImageViewHeight = view.frame.height / 2
    private lazy var upperImageViewMaxHeight = view.frame.height / 2
    private lazy var upperImageViewMinHeight = 100.f
    private lazy var startingUpperImageViewHeight = upperImageViewMaxHeight
    
    // KMPostButtonView Menu Item
    @available(iOS 14.0, *)
    var menuItems: [UIAction] {
        guard let reactor = reactor else { return [] }
        // 사용자가 본인이 올린 글일 경우
        if reactor.currentState.postIsUserUploaded {
            return [
                UIAction(title: "수정하기", image: nil, handler: { [weak self] _ in
                    self?.reactor?.action.onNext(.editPost)
                }),
                UIAction(title: "삭제하기", image: nil, handler: { [weak self] _ in
                    self?.presentAlertWithConfirmation(title: "정말 삭제하시겠습니까?", message: nil)
                        .subscribe(onNext: { actionType in
                            switch actionType {
                            case .ok:
                                self?.reactor?.action.onNext(.deletePost)
                            case .cancel:
                                break
                            }
                        })
                        .disposed(by: self?.disposeBag ?? DisposeBag.init())
                })
            ]
        } else {
            return [
                UIAction(title: "신고하기", image: nil, handler: { [weak self] _ in
                    guard let nickname = reactor.currentState.postModel?.nickname else { return }
                    self?.presentReportUserVC(userToReport: nickname, postUID: reactor.currentState.pageId)
                }),
                UIAction(title: "이 사용자의 글 보지 않기", image: nil, handler: { [weak self] _ in
                    guard let postUploader = self?.reactor?.currentState.postUploaderNickname else { return }
                    self?.presentAlertWithConfirmation(
                        title: postUploader + "님의 글 보지 않기",
                        message: "홈화면에서 위 사용자의 게시글이 더는 보이지 않도록 설정하시겠습니까? 한 번 설정하면 해제할 수 없습니다."
                    )
                        .subscribe(onNext: { actionType in
                            switch actionType {
                            case .ok:
                                self?.reactor?.action.onNext(.blockUser(postUploader))
                            case .cancel: break
                            }
                        })
                        .disposed(by: self?.disposeBag ?? DisposeBag.init())
                }),
            ]
        }
    }
    
    @available(iOS 14.0, *)
    var menu: UIMenu {
        return UIMenu(title: "", image: nil, identifier: nil, options: [], children: menuItems)
    }
    
    
    //MARK: - Constants
    
    fileprivate struct Metrics {
        static let profileImageViewSize = 15.f
        static let defaultOffSet        = 25.f
    }
    
    fileprivate struct Colors {
        static let labelLightGrayColor = UIColor.convertUsingHexString(hexValue: "#9D9D9D")
    }
    
    //MARK: - UI
    
    lazy var shadowView: UIView = {
        let view = UIView()
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.darkGray.withAlphaComponent(0.35).cgColor,
            UIColor.darkGray.withAlphaComponent(0.0).cgColor
        ]
        gradientLayer.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 100)
        gradientLayer.startPoint = CGPoint(x: 1.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        view.layer.insertSublayer(gradientLayer, at: 0)
        return view
    }()
    
    let upperImageSlideshow = ImageSlideshow().then {
        $0.contentScaleMode = .scaleAspectFill              /// 특이하게 여기서 contentMode가 아니라 contentScaleMode 다
        $0.clipsToBounds = true
        $0.slideshowInterval = 4
        let pageIndicator = UIPageControl()
//        pageIndicator.currentPageIndicatorTintColor = UIColor.lightGray
//        pageIndicator.pageIndicatorTintColor = UIColor.black
        $0.pageIndicator = pageIndicator
        $0.pageIndicatorPosition = .init(horizontal: .center, vertical: .customTop(padding: 0))
    }
    
    let bottomContainerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 25
        $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        $0.layer.borderWidth = 0.3
        $0.layer.borderColor = UIColor.lightGray.cgColor
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
    
    let bulletPointLabel_1 = UILabel().then {
        $0.textColor = Colors.labelLightGrayColor
        $0.text = "•"
        $0.font = UIFont(name: K.Fonts.notoSansKRRegular, size: 12)
    }
    
    let dateLabel = UILabel().then {
        $0.text = "1일 전"
        $0.textColor = Colors.labelLightGrayColor
        $0.numberOfLines = 1
        $0.font = UIFont(name: K.Fonts.notoSansKRRegular, size: 12)
    }
    
    
    let bulletPointLabel_2 = UILabel().then {
        $0.textColor = Colors.labelLightGrayColor
        $0.text = "•"
        $0.font = UIFont(name: K.Fonts.notoSansKRRegular, size: 12)
    }
    
    let viewCountLabel = UILabel().then {
        $0.textColor = Colors.labelLightGrayColor
        $0.numberOfLines = 1
        $0.font = UIFont(name: K.Fonts.notoSansKRRegular, size: 12)
    }
    
    let userInfoStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fill
        $0.alignment = .fill
        $0.spacing = 5
    }
    
    let postTitleLabel = UILabel().then {
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
    
    let questionMarkButton = UIButton(type: .system).then {
        $0.setImage(UIImage(systemName: "questionmark.circle.fill"), for: .normal)
        $0.tintColor = UIColor.convertUsingHexString(hexValue: "#CBCBCB")
    }
    
    let perPersonLabel = UILabel().then {
        $0.text = "1인당"
        $0.adjustsFontSizeToFitWidth = true
        $0.textAlignment = .right
        $0.textColor = UIColor.lightGray
        $0.font = UIFont(name: K.Fonts.notoSansKRRegular, size: 14)
    }
    
    let priceLabel = UILabel().then {
        $0.text = "?"
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

    
    let postDetailLabel = PostDetailLabel()
    
    let enterChatButton = KMShadowButton(buttonTitle: "채팅방 입장하기")
    
    let urlLinkButton = UIButton(type: .system).then {
        $0.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOffset = CGSize(width: 1, height: 1)
        $0.layer.shadowOpacity = 0.4
        $0.layer.shadowRadius = 5
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
    
    init(reactor: Reactor) {
        super.init()
        hidesBottomBarWhenPushed = true
        self.reactor = reactor
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurePanGestureRecognizer()
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
//            print("✅ AFTER")
//            self.gatherStatusToggleSwitch.switchConfigR.text = "hd"
//        }

    }
        
    //MARK: - UI Setup

    override func setupLayout() {
        super.setupLayout()
        
        view.addSubview(upperImageSlideshow)
        view.addSubview(shadowView)
        view.addSubview(bottomContainerView)
        view.addSubview(urlLinkButton)
        view.addSubview(postControlButtonView)
        
        [profileImageView, userNicknameLabel, bulletPointLabel_1, dateLabel, bulletPointLabel_2, viewCountLabel].forEach {
            userInfoStackView.addArrangedSubview($0)
        }
        
        bottomContainerView.addSubview(userInfoStackView)
        bottomContainerView.addSubview(postTitleLabel)
        bottomContainerView.addSubview(gatherStatusView)
        bottomContainerView.addSubview(gatherStatusToggleSwitch)
        bottomContainerView.addSubview(wonLabel)
        bottomContainerView.addSubview(priceLabel)
        bottomContainerView.addSubview(questionMarkButton)
        bottomContainerView.addSubview(perPersonLabel)
        bottomContainerView.addSubview(divider)
        bottomContainerView.addSubview(postDetailLabel)
        bottomContainerView.addSubview(enterChatButton)
    
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        upperImageSlideshow.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.height.equalTo(view.frame.height / 2)
        }
        
        shadowView.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.height.equalTo(70)
        }
        
        postControlButtonView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.height.equalTo(50)
            $0.left.right.equalToSuperview()
        }

        bottomContainerView.snp.makeConstraints {
            $0.top.equalTo(upperImageSlideshow.snp.bottom).offset(-15)
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
        
        gatherStatusView.snp.makeConstraints {
            $0.width.equalTo(69)
            $0.height.equalTo(30)
            $0.top.equalTo(postTitleLabel.snp.bottom).offset(20)
            $0.left.equalToSuperview().offset(25)
        }
        
        gatherStatusToggleSwitch.snp.makeConstraints {
            $0.width.equalTo(81)
            $0.height.equalTo(26)
            $0.top.equalTo(postTitleLabel.snp.bottom).offset(22)
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
        
        questionMarkButton.snp.makeConstraints {
            $0.width.height.equalTo(20)
            $0.right.equalTo(perPersonLabel.snp.left).offset(-5)
            $0.top.equalTo(postTitleLabel.snp.bottom).offset(27)
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
    
    func bind(reactor: PostViewReactor) {

        // Input
        
        self.rx.viewDidLoad
            .map { _ in Reactor.Action.viewDidLoad }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        self.rx.viewWillAppear
            .withUnretained(self)
            .subscribe(onNext: { _ in
                self.navigationController?.setNavigationBarHidden(true, animated: true)
                self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
            })
            .disposed(by: disposeBag)
        
        self.rx.viewWillDisappear
            .withUnretained(self)
            .subscribe(onNext: { _ in
                self.navigationController?.setNavigationBarHidden(false, animated: true)
            })
            .disposed(by: disposeBag)
        
        // 뒤로가기
        postControlButtonView.backButton.rx.tap
            .withUnretained(self)
            .subscribe(onNext: { _ in
                self.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
        
        // 공유 버튼
        postControlButtonView.shareButton.rx.tap
            .withUnretained(self)
            .subscribe(onNext: { _ in
                
                guard let postDetailModel = reactor.currentState.postModel else {
                    return
                }
                
                var components = URLComponents()
                components.scheme = "https"
                components.host = "knumarket.page.link"
                components.path = "/seePost"
                
                let postUIDQueryItem = URLQueryItem(name: "postUID", value: postDetailModel.uuid)
                components.queryItems = [postUIDQueryItem]
                
                guard let linkParameter = components.url else { return }
                print("✅ sharing link: \(linkParameter.absoluteString)")
                
                guard let shareLink = DynamicLinkComponents.init(link: linkParameter, domainURIPrefix: "https://knumarket.page.link") else {
                    print("❗️ shareLink error")
                    return
                }
                
                
                if let myBundleId = Bundle.main.bundleIdentifier {
                    shareLink.iOSParameters = DynamicLinkIOSParameters(bundleID: myBundleId)
                }
                
                shareLink.iOSParameters?.appStoreID = "1580677279"
                
                shareLink.socialMetaTagParameters = DynamicLinkSocialMetaTagParameters()
                shareLink.socialMetaTagParameters?.title = "\(postDetailModel.title) 같이 사요!"
                shareLink.socialMetaTagParameters?.descriptionText = "자세한 내용은 크누마켓에서 확인하세요."
                if let imageUIDs = postDetailModel.imageUIDs {
                    shareLink.socialMetaTagParameters?.imageURL = URL(string: K.MEDIA_REQUEST_URL + imageUIDs[0])
                }
               
                shareLink.shorten { [weak self] url, _, error in
                    
                    if let error = error {
                        print("❗️ Shortening URL Error: \(error)")
                        return
                    }
                    
                    guard let url = url else { return }
                    print("✅ shortened URL: \(url)")
                    
    
                    //UIActivityVC
                    let promoText = "\(postDetailModel.title) 같이 사요!"
                    let activityVC = UIActivityViewController(activityItems: [promoText, url], applicationActivities: nil)
                    self?.present(activityVC, animated: true)
                    
                }
                
                
                
                
                
                
            })
            .disposed(by: disposeBag)
        
        // 메뉴 버튼
        postControlButtonView.menuButton.rx.tap
            .withUnretained(self)
            .subscribe(onNext: { _ in
                guard #available(iOS 14.0, *) else {
//                    self.didPressMenuButton()
                    return
                }
            })
            .disposed(by: disposeBag)
        
        
        postDetailLabel.onClick = { [weak self] _, detection in
            switch detection.type {
            case .link(let url):
                self?.presentSafariView(with: url)
            default: break
            }
        }
        
        enterChatButton.rx.tap
            .map { Reactor.Action.joinChat }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
  
        urlLinkButton.rx.tap
            .withUnretained(self)
            .subscribe(onNext: { _ in
                if let url = reactor.currentState.referenceUrl {
                    self.presentSafariView(with: url)
                }
            })
            .disposed(by: disposeBag)
        
        upperImageSlideshow.rx.tapGesture()
            .when(.recognized)
            .withUnretained(self)
            .subscribe(onNext: { _ in
                self.upperImageSlideshow.presentFullScreenController(from: self)
            })
            .disposed(by: disposeBag)

        // Output
        
        reactor.state
            .map { $0.shouldEnableChatEntrance }
            .bind(to: enterChatButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        /// 방장 모집 상태 변경 버튼
        reactor.state
            .map { $0.postIsUserUploaded }
            .map { !$0 }
            .distinctUntilChanged()
            .bind(to: gatherStatusToggleSwitch.rx.isHidden)
            .disposed(by: disposeBag)
        
        /// 일반 유저 모집 상태 확인 View
        reactor.state
            .map { $0.postIsUserUploaded }
            .distinctUntilChanged()
            .bind(to: gatherStatusView.rx.isHidden)
            .disposed(by: disposeBag)

        
        
        
        reactor.state
            .map { $0.postModel }
            .filter { $0 != nil }
            .observe(on: MainScheduler.instance)
            .withUnretained(self)
            .subscribe(onNext: { (_, postModel) in
        
                
                if #available(iOS 14.0, *) {
                    self.postControlButtonView.menuButton.menu = self.menu
                    self.postControlButtonView.menuButton.showsMenuAsPrimaryAction = true
                }
                
                
                reactor.currentState.inputSources.isEmpty
                ? self.upperImageSlideshow.setImageInputs([ImageSource(image: UIImage(named: K.Images.defaultItemImage)!)])
                : self.upperImageSlideshow.setImageInputs(reactor.currentState.inputSources)
                
                
                
                
                
                self.profileImageView.sd_setImage(
                    with: URL(string: K.MEDIA_REQUEST_URL + (reactor.currentState.postModel?.profileImageUID ?? "")),
                    placeholderImage: UIImage(named: K.Images.defaultUserPlaceholder),
                    options: .continueInBackground
                )
                
                self.userNicknameLabel.text = reactor.currentState.postUploaderNickname
//                self.dateLabel
                
                
                
                
                self.viewCountLabel.text = reactor.currentState.viewCount
                
                self.postTitleLabel.text = reactor.currentState.title
                
                // 모집완료,모집 중 toggle
                self.gatherStatusView.updateGatheringStatusLabel(
                    currentNum: reactor.currentState.currentlyGatheredPeople,
                    total: reactor.currentState.totalGatheringPeople,
                    isCompletelyDone: reactor.currentState.isCompletelyDone
                )
                
                
                
                self.priceLabel.text = reactor.currentState.priceForEachPerson
                
                
                
                self.postDetailLabel.text = reactor.currentState.detail
                
                
                if reactor.currentState.referenceUrl == nil {
                    self.urlLinkButton.isHidden = true
                }
                
                
    

            })
            .disposed(by: disposeBag)
        
        
        reactor.state
            .map { ($0.alertMessage, $0.alertMessageType) }
            .distinctUntilChanged { $0.0 }
            .filter { $0.0 != nil }
            .withUnretained(self)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { (_, alertInfo) in
                switch alertInfo.1 {
                case .appleDefault:
                    self.presentSimpleAlert(title: alertInfo.0!, message: "")
                    
                case .custom:
                    self.presentCustomAlert(title: "채팅방 참여 불가", message: alertInfo.0!)
                    
                case .simpleBottom:
                    self.showSimpleBottomAlert(with: alertInfo.0!)
           
                case .none: break
                }
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.didFailFetchingPost }
            .distinctUntilChanged()
            .filter { $0 == true }
            .withUnretained(self)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { _ in
                self.postControlButtonView.isHidden = true
                self.upperImageSlideshow.isHidden = true
                self.bottomContainerView.isHidden = true
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.didDeletePost }
            .distinctUntilChanged()
            .filter { $0 == true }
            .withUnretained(self)
            .subscribe(onNext: {  _ in
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.2) {
                    self.navigationController?.popViewController(animated: true)
                }
            })
            .disposed(by: disposeBag)
        
        
        reactor.state
            .map { $0.didEnterChat }
            .distinctUntilChanged()
            .filter { $0 == true }
            .withUnretained(self)
            .subscribe(onNext: { _ in
                let vc = ChatViewController()
                vc.roomUID = reactor.currentState.pageId
                vc.chatRoomTitle = reactor.currentState.title
                vc.isFirstEntrance = reactor.currentState.isFirstEntranceToChat
                self.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: disposeBag)
        
        
        reactor.state
            .map { $0.isAttemptingToEnterChat }
            .distinctUntilChanged()
            .withUnretained(self)
            .subscribe(onNext: { (_, isAttempting) in
                self.enterChatButton.loadingIndicator(isAttempting)
            })
            .disposed(by: disposeBag)
        
        
        // Notification Center
        
        NotificationCenterService.presentVerificationNeededAlert.addObserver()
            .withUnretained(self)
            .bind { _ in
                self.presentUserVerificationNeededAlert()
            }
            .disposed(by: disposeBag)
        
    }

}

extension NewPostViewController {
    
    private func configurePanGestureRecognizer() {
        let panGesture = UIPanGestureRecognizer(
            target: self,
            action: #selector(viewPanned(_:))
        )
        panGesture.delaysTouchesBegan = false
        panGesture.delaysTouchesEnded = false
        bottomContainerView.addGestureRecognizer(panGesture)
    }

    private func nearest(to number: CGFloat, inValues values: [CGFloat]) -> CGFloat {
        guard let nearestVal = values.min(by: { abs(number - $0) < abs(number - $1) }) else { return number }
        return nearestVal
    }
    
    private func changeTopImageViewHeight(to height: CGFloat, option: UIView.AnimationOptions) {
        upperImageSlideshow.snp.updateConstraints {
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
                upperImageSlideshow.snp.updateConstraints {
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

//#if canImport(SwiftUI) && DEBUG
//import SwiftUI
//
//@available(iOS 13.0, *)
//struct NewPostVC: PreviewProvider {
//
//    static var previews: some SwiftUI.View {
//        NewPostViewController().toPreview()
//    }
//}
//#endif
