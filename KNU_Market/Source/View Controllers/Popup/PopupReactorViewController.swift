//
//  PopupReactorViewController.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2021/12/14.
//

import UIKit
import RxSwift
import RxCocoa
import RxGesture
import ReactorKit
import Then
import SDWebImage

class PopupReactorViewController: BaseViewController, View {
    
    typealias Reactor = PopupReactor
    
    //MARK: - Properties
    
    var disposeBag = DisposeBag()
    
    //MARK: - Constants
    
    fileprivate struct Metrics {
        static let dismissButtonHeight: CGFloat = 50
    }
    
    fileprivate struct Fonts {
        
        static let doNotSeeForOneDayButton: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12.5, weight: .semibold),
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .foregroundColor: UIColor.white
        ]
    }
    
    fileprivate struct Images {
        static let dismissButton   = UIImage(systemName: "xmark")?.withRenderingMode(.alwaysOriginal).withTintColor(.white)
    }
    
    //MARK: - UI
    
    lazy var popupImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.isUserInteractionEnabled = true
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 40
    }
    
    let doNotSeeForOneDayButton = UIButton(type: .system).then {
        $0.addBounceAnimationWithNoFeedback()
        $0.setAttributedTitle(NSAttributedString(
            string: "24시간 보지 않기",
            attributes: Fonts.doNotSeeForOneDayButton
        ), for: .normal)
    }
    
    let dismissButton = UIButton(type: .system).then {
        $0.backgroundColor = .darkGray
        $0.setImage(Images.dismissButton, for: .normal)
        $0.widthAnchor.constraint(equalToConstant: Metrics.dismissButtonHeight).isActive = true
        $0.heightAnchor.constraint(equalToConstant: Metrics.dismissButtonHeight).isActive = true
        $0.layer.cornerRadius = Metrics.dismissButtonHeight / 2
        $0.addBounceAnimationWithNoFeedback()
        $0.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
    }
    
    //MARK: - Initialization
    
    init(reactor: Reactor) {
        super.init()
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: - UI Setup
    
    override func setupLayout() {
        super.setupLayout()
        
        view.addSubview(popupImageView)
        view.addSubview(doNotSeeForOneDayButton)
        view.addSubview(dismissButton)
    }

    override func setupConstraints() {
        super.setupConstraints()
        
        popupImageView.snp.makeConstraints { make in
            make.width.equalTo(view.snp.width).multipliedBy(0.8)
            make.height.equalTo(self.popupImageView.snp.width).multipliedBy(1.3)
            make.center.equalToSuperview()
        }
        
        doNotSeeForOneDayButton.snp.makeConstraints { make in
            make.top.equalTo(popupImageView.snp.bottom).offset(15.3)
            make.centerX.equalToSuperview()
        }
        
        dismissButton.snp.makeConstraints { make in
            make.top.equalTo(doNotSeeForOneDayButton.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
        }
    }
    
    override func setupStyle() {
        super.setupStyle()
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
    }

    //MARK: - Binding Reactor
    
    func bind(reactor: Reactor) {
        
        // Input
        self.rx.viewWillAppear
            .map { _ in Reactor.Action.viewWillAppear }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        popupImageView.rx.tapGesture()
            .when(.recognized)
            .map { _ in Reactor.Action.pressedPopupImage }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        doNotSeeForOneDayButton.rx.tap
            .map { Reactor.Action.doNotSeePopupForOneDay }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        dismissButton.rx.tap
            .subscribe(onNext: { self.dismissVC() })
            .disposed(by: disposeBag)
         
        // Output
        
        /// Set Popup Image
        reactor.state
            .asObservable()
            .map { $0.mediaUrl }
            .subscribe(onNext: { [weak self] url in
                self?.popupImageView.sd_setImage(
                    with: url,
                    placeholderImage: nil,
                    options: .continueInBackground,
                    completed: nil
                )
            })
            .disposed(by: disposeBag)
        
        /// Opening Landing URL
        reactor.state
            .asObservable()
            .map { $0.landingUrl }
            .filter { $0 != nil }
            .subscribe(onNext: { url in
                UIApplication.shared.open(url!, options: [:])
            })
            .disposed(by: disposeBag)
        
        /// Dismissing VC after pressing doNotSeeForOneDayButton
        reactor.state
            .asObservable()
            .map { $0.dismiss }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] _ in
                self?.dismissVC()
            })
            .disposed(by: disposeBag)
    }
}
