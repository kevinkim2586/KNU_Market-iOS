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
                    self?.presentReportUserVC(
                        userToReport: reactor.currentState.postModel.nickname,
                        postUID: reactor.currentState.pageId
                    )
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
    
    lazy var upperShadowView: UIView = {
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
        $0.pageIndicator = pageIndicator
        $0.pageIndicatorPosition = .init(horizontal: .center, vertical: .customTop(padding: 10))
    }
    
    let bottomContainerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 25
        $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        $0.layer.borderWidth = 0.3
        $0.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    let dragIndicatorView = UIView().then {
        $0.backgroundColor = .lightGray
        $0.layer.cornerRadius = 3
    }
    
    let profileImageView = UIImageView().then {
        $0.image = UIImage(named: K.Images.defaultUserPlaceholder)
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.cornerRadius = Metrics.profileImageViewSize / 2
    }
    
    let userNicknameLabel = UILabel().then {
        $0.text = "-"
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
        $0.text = "-일 전"
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
        text: "모집중 -/-",
        textColor: .white,
        font: UIFont(name: K.Fonts.notoSansKRMedium, size: 11)!,
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
        $0.delegate = self
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
    
    let urlLinkButton = KMUrlLinkButton(type: .system)

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
        configure()
    }
        
    //MARK: - UI Setup

    override func setupLayout() {
        super.setupLayout()
        
        view.addSubview(upperImageSlideshow)
        view.addSubview(upperShadowView)
        view.addSubview(bottomContainerView)
        view.addSubview(urlLinkButton)
        view.addSubview(postControlButtonView)
        
        [profileImageView, userNicknameLabel, bulletPointLabel_1, dateLabel, bulletPointLabel_2, viewCountLabel].forEach {
            userInfoStackView.addArrangedSubview($0)
        }
        
        bottomContainerView.addSubview(dragIndicatorView)
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
        
        upperShadowView.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.height.equalTo(70)
        }
        
        postControlButtonView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.height.equalTo(50)
            $0.left.right.equalToSuperview()
        }

        bottomContainerView.snp.makeConstraints {
            $0.top.equalTo(upperImageSlideshow.snp.bottom).offset(-25)
            $0.bottom.left.right.equalToSuperview()
        }
        
        urlLinkButton.snp.makeConstraints {
            $0.width.equalTo(124)
            $0.height.equalTo(39)
            $0.bottom.equalTo(bottomContainerView.snp.top).offset(-15)
            $0.centerX.equalToSuperview()
        }
        
        dragIndicatorView.snp.makeConstraints {
            $0.width.equalTo(50)
            $0.height.equalTo(6)
            $0.top.equalTo(bottomContainerView.snp.top).inset(10)
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
                self.navigationController?.interactivePopGestureRecognizer?.delegate = self
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
      
                var components = URLComponents()
                components.scheme = "https"
                components.host = "knumarket.page.link"
                components.path = "/seePost"
                
                let postUIDQueryItem = URLQueryItem(name: "postUID", value: reactor.currentState.postModel.uuid)
                components.queryItems = [postUIDQueryItem]
                
                guard let linkParameter = components.url else { return }
                print("✅ sharing link: \(linkParameter.absoluteString)")
                
                guard let shareLink = DynamicLinkComponents.init(link: linkParameter, domainURIPrefix: "https://knumarket.page.link") else {
                    print("❗️ shareLink error")
                    return
                }
                
                shareLink.androidParameters = DynamicLinkAndroidParameters(packageName: "com.kyh.knumarket")
                
                if let myBundleId = Bundle.main.bundleIdentifier {
                    shareLink.iOSParameters = DynamicLinkIOSParameters(bundleID: myBundleId)
                }
                shareLink.iOSParameters?.appStoreID = "1580677279"
                
                shareLink.socialMetaTagParameters = DynamicLinkSocialMetaTagParameters()
                shareLink.socialMetaTagParameters?.title = "\(reactor.currentState.postModel.title) 같이 사요!"
                shareLink.socialMetaTagParameters?.descriptionText = "자세한 내용은 크누마켓에서 확인하세요."
                if let imageUIDs = reactor.currentState.postModel.imageUIDs {
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
                    let promoText = "\(reactor.currentState.postModel.title) 같이 사요!"
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
                    self.pressedMenuButton()
                    return
                }
                // iOS 14 이상이면 UIMenu로 자동 실행 -> postModel에 데이터가 들어가면 그때 button.menu에 속성 자동 추가
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
        
        questionMarkButton.rx.tap
            .withUnretained(self)
            .subscribe(onNext: { _ in
                let popupVC = PerPersonPriceInfoViewController(
                    productPrice: reactor.currentState.productPrice,
                    shippingFee: reactor.currentState.shippingFee,
                    totalPrice: reactor.currentState.productPrice + reactor.currentState.shippingFee,
                    totalGatheringPeople: reactor.currentState.totalGatheringPeople,
                    perPersonPrice: reactor.currentState.priceForEachPersonInInt
                )
                
                popupVC.modalPresentationStyle = .popover
                popupVC.preferredContentSize = CGSize(
                    width: (self.view.frame.size.width / 2) + 20,
                    height: self.view.frame.size.height / 3 - 40
                )
                let popOver: UIPopoverPresentationController = popupVC.popoverPresentationController!
                popOver.delegate = self
                popOver.sourceView = self.questionMarkButton
                self.present(popupVC, animated: true)
            })
            .disposed(by: disposeBag)

        // Output
        
        /// 최초 Configuration
        reactor.state
            .map { $0.postModel.title }
            .distinctUntilChanged()
            .withUnretained(self)
            .subscribe(onNext: { _ in
                
                if reactor.currentState.postIsUserUploaded {
                    self.gatherStatusToggleSwitch.configureGatheringStatus(
                        isCompletelyDone: reactor.currentState.isCompletelyDone,
                        totalGatheringPeople: reactor.currentState.totalGatheringPeople,
                        currentlyGatheredPeople: reactor.currentState.currentlyGatheredPeople
                    )
                    
                } else {
                    self.gatherStatusView.updateGatheringStatusLabel(
                        currentNum: reactor.currentState.currentlyGatheredPeople,
                        total: reactor.currentState.totalGatheringPeople,
                        isCompletelyDone: reactor.currentState.isCompletelyDone
                    )
                    
                }
                
                if #available(iOS 14.0, *) {
                    self.postControlButtonView.menuButton.menu = self.menu
                    self.postControlButtonView.menuButton.showsMenuAsPrimaryAction = true
                }
            })
            .disposed(by: disposeBag)
        
        /// 채팅 버튼 활성화 여부
        reactor.state
            .map { $0.shouldEnableChatEntrance }
            .bind(to: enterChatButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        /// 방장 - 모집 상태 변경 버튼 숨김 여부
        reactor.state
            .map { $0.postIsUserUploaded }
            .map { !$0 }
            .distinctUntilChanged()
            .bind(to: gatherStatusToggleSwitch.rx.isHidden)
            .disposed(by: disposeBag)
        
        /// 일반 유저 - 모집 상태 확인 View 숨김 여부
        reactor.state
            .map { $0.postIsUserUploaded }
            .distinctUntilChanged()
            .bind(to: gatherStatusView.rx.isHidden)
            .disposed(by: disposeBag)

        /// 닉네임
        reactor.state
            .map { $0.postModel.nickname }
            .distinctUntilChanged()
            .bind(to: userNicknameLabel.rx.text)
            .disposed(by: disposeBag)
        
        /// 날짜
        reactor.state
            .map { $0.postModel.date }
            .distinctUntilChanged()
            .map { DateConverter.convertDateStringToSimpleFormat($0) }
            .bind(to: dateLabel.rx.text)
            .disposed(by: disposeBag)
        
        /// 조회 수
        reactor.state
            .map { $0.postModel.viewCount }
            .distinctUntilChanged()
            .map { "조회 \($0)"}
            .bind(to: viewCountLabel.rx.text)
            .disposed(by: disposeBag)
        
        /// 글 제목
        reactor.state
            .map { $0.postModel.title }
            .distinctUntilChanged()
            .bind(to: postTitleLabel.rx.text)
            .disposed(by: disposeBag)
        
        /// 글 상세 내용
        reactor.state
            .map { $0.postModel.postDetail }
            .distinctUntilChanged()
            .bind(to: postDetailLabel.rx.text)
            .disposed(by: disposeBag)
        
        /// 별도 첨부 링크 버튼 숨김 여부
        reactor.state
            .map { $0.postModel.referenceUrl }
            .distinctUntilChanged()
            .map { $0 == nil }
            .bind(to: urlLinkButton.rx.isHidden)
            .disposed(by: disposeBag)
        
        /// 가격 정보가 없으면 숨김 처리해야하는 UI Component
        reactor.state
            .map { $0.postModel }
            .map { model -> String? in
                if model.price == nil || model.price == 0 {
                    return nil
                } else { return "" }
            }
            .distinctUntilChanged()
            .map { $0 == nil }
            .bind(
                to: questionMarkButton.rx.isHidden,
                perPersonLabel.rx.isHidden,
                priceLabel.rx.isHidden,
                wonLabel.rx.isHidden
            )
            .disposed(by: disposeBag)

        /// 가격 정보 (1인당 가격)
        reactor.state
            .map { $0.postModel }
            .map { model -> String in
                if let price = model.price, let shippingFee = model.shippingFee {
                    let perPersonPrice = (price + shippingFee) / model.totalGatheringPeople
                    return perPersonPrice.withDecimalSeparator
                } else { return "" }
            }
            .distinctUntilChanged()
            .bind(to: priceLabel.rx.text)
            .disposed(by: disposeBag)
        
        /// 유저 프로필 이미지
        reactor.state
            .map { $0.postModel.profileImageUID }
            .distinctUntilChanged()
            .map { URL(string: K.MEDIA_REQUEST_URL + $0) }
            .withUnretained(self)
            .subscribe(onNext: { (_, url) in
                self.profileImageView.sd_setImage(
                    with: url,
                    placeholderImage: UIImage(named: K.Images.defaultUserPlaceholder),
                    options: .continueInBackground
                )
            })
            .disposed(by: disposeBag)

        /// 유저가 올린 이미지 모음
        reactor.state
            .map { $0.inputSources }
            .withUnretained(self)
            .subscribe(onNext: { (_, inputSources) in
                inputSources.isEmpty
                ? self.upperImageSlideshow.setImageInputs([ImageSource(image: UIImage(named: K.Images.defaultItemImage)!)])
                : self.upperImageSlideshow.setImageInputs(inputSources)
            })
            .disposed(by: disposeBag)

        /// 알림
        reactor.state
            .map { ($0.alertMessage, $0.alertMessageType) }
            .distinctUntilChanged { $0.0 }
            .filter { $0.0 != nil }
            .withUnretained(self)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { (_, alertInfo) in
                switch alertInfo.1 {
                case .appleDefault:
                    self.presentSimpleAlert(title: alertInfo.0!)
                    
                case .custom:
                    self.presentCustomAlert(title: "채팅방 참여 불가", message: alertInfo.0!)
                    
                case .simpleBottom:
                    self.showSimpleBottomAlert(with: alertInfo.0!)
           
                case .none: break
                }
            })
            .disposed(by: disposeBag)
        
        /// 글 불러오기에 실패했을 때 숨겨야하는 UI Component 모음
        reactor.state
            .map { $0.didFailFetchingPost }
            .distinctUntilChanged()
            .filter { $0 == true }
            .bind(
                to: postControlButtonView.rx.isHidden,
                upperImageSlideshow.rx.isHidden,
                bottomContainerView.rx.isHidden
            )
            .disposed(by: disposeBag)
        
        /// 방장 - 글 삭제 완료 시
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
        
        /// 채팅방 입장 성공 시
        reactor.state
            .map { $0.didEnterChat }
            .distinctUntilChanged()
            .filter { $0 == true }
            .withUnretained(self)
            .subscribe(onNext: { _ in
                
                if reactor.currentState.isFromChatVC {
                    self.navigationController?.popViewController(animated: true)
                } else {
                    
                    let vc = ChatViewController()
                    vc.roomUID = reactor.currentState.pageId
                    vc.chatRoomTitle = reactor.currentState.title
                    vc.isFirstEntrance = reactor.currentState.isFirstEntranceToChat
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            })
            .disposed(by: disposeBag)
        
        /// 채팅방에 입장 시도 중
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
    
    private func configure() {

        
    }
}

//MARK: - LabelSwitchDelegate

extension NewPostViewController: LabelSwitchDelegate {

    func switchChangeToState(sender: LabelSwitch) {
        switch sender.curState {
            
            case .L:
                print("✅ Left Side")
            
            let vc = CustomAlertViewController_Rx(
                title: "모집 완료를 해제하시겠습니까?",
                message: "해제 시 추가 인원이 참여할 수도 있습니다.",
                cancelButtonTitle: "아니오",
                actionButtonTitle: "예"
            )
            self.present(vc, animated: true)
            vc.alertObserver
                .withUnretained(self)
                .subscribe(onNext: { (_, actionType) in
                    switch actionType {
                    case .ok:
                        self.reactor?.action.onNext(.updatePostAsRegathering)
                        
                    case .cancel:
                        self.gatherStatusToggleSwitch.flipSwitch()
                    }
                })
                .disposed(by: disposeBag)
                    
        
            case .R:
                print("✅ Right Side")
            
            let vc = CustomAlertViewController_Rx(
                title: "모집 완료하시겠습니까?",
                message: "모집 완료 시 추가 인원이 참여할 수 없습니다. (모집 완료 해제 또는 글 수정을 통해 해제 가능)",
                cancelButtonTitle: "아니오",
                actionButtonTitle: "예"
            )
            self.present(vc, animated: true)
            vc.alertObserver
                .withUnretained(self)
                .subscribe(onNext: { (_, actionType) in
      
                    
                    switch actionType {
                    case .ok:
                        self.reactor?.action.onNext(.markPostDone)
                        
                    case .cancel:
                        
                        self.gatherStatusToggleSwitch.flipSwitch()
                        
                        
                    }
                })
                .disposed(by: disposeBag)
            
            
        }
    }
}

//MARK: - Alert Actions

extension NewPostViewController {
    
    func pressedMenuButton() {
        guard let reactor = reactor else { return }
        
        if reactor.currentState.postIsUserUploaded {
            
            let editAction = UIAlertAction(
                title: "글 수정하기",
                style: .default
            ) { [weak self] _ in
                guard let self = self else { return }
                DispatchQueue.main.async {

                    let vc = UploadPostViewController(
                        viewModel: UploadPostViewModel(
                            postManager: PostManager(),
                            mediaManager: MediaManager()
                        )
//                        editModel: nil
                    )
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            
            let deleteAction = UIAlertAction(
                title: "삭제하기",
                style: .destructive
            ) { [weak self] _ in
                guard let self = self else { return }
                self.presentAlertWithConfirmation(title: "정말 삭제하시겠습니까?", message: nil)
                    .subscribe(onNext: { actionType in
                        switch actionType {
                        case .ok:
                            self.reactor?.action.onNext(.deletePost)
                        case .cancel:
                            break
                        }
                    })
                    .disposed(by: self.disposeBag)
            }
            
            let actionSheet = UIHelper.createActionSheet(with: [editAction, deleteAction], title: nil)
            self.present(actionSheet, animated: true)
            
        } else {

            let reportAction = UIAlertAction(
                title: "신고하기",
                style: .default
            ) { [weak self] _ in
                guard let self = self else { return }
                self.presentReportUserVC(
                    userToReport: reactor.currentState.postModel.nickname,
                    postUID: reactor.currentState.pageId
                )
            }
            let blockAction = UIAlertAction(
                title: "이 사용자의 글 보지 않기",
                style: .default
            ) { [weak self] _ in
                guard let self = self else { return }
                guard let postUploader = self.reactor?.currentState.postUploaderNickname else { return }
                self.presentAlertWithConfirmation(
                    title: postUploader + "님의 글 보지 않기",
                    message: "홈화면에서 위 사용자의 게시글이 더는 보이지 않도록 설정하시겠습니까? 한 번 설정하면 해제할 수 없습니다."
                )
                    .subscribe(onNext: { actionType in
                        switch actionType {
                        case .ok:
                            self.reactor?.action.onNext(.blockUser(postUploader))
                        case .cancel: break
                        }
                    })
                    .disposed(by: self.disposeBag)
            }
            let actionSheet = UIHelper.createActionSheet(with: [reportAction, blockAction], title: nil)
            self.present(actionSheet, animated: true)
        }
    }
}

//MARK: - UIPopoverPresentationControllerDelegate

extension NewPostViewController: UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }

    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        return true
    }
}

//MARK: - PanGestureRecognizer

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

//MARK: - UINavigationControllerDelegate

extension NewPostViewController: UINavigationControllerDelegate, UIGestureRecognizerDelegate {
            
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
