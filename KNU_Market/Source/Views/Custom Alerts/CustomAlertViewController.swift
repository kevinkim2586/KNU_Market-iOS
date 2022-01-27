//
//  KMCustomAlertViewController.swift
//  KNU_Market
//
//  Created by 장서영 on 2021/11/21.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift
import Then

class CustomAlertViewController: UIViewController {
    
    let disposedBag = DisposeBag()
    
    let alertView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 10
    }
    
    let titleLabel = UILabel().then {
        $0.font = UIFont(name: K.Fonts.notoSansKRMedium, size: 16)
        $0.textColor = .black
        $0.textAlignment = .left
        $0.numberOfLines = 2
    }
    
    let messageLabel = UILabel().then {
        $0.font = UIFont(name: K.Fonts.notoSansRegular, size: 15)
        $0.textColor = .black
        $0.textAlignment = .left
        $0.numberOfLines = 7
        $0.adjustsFontSizeToFitWidth = true
        $0.minimumScaleFactor = 0.75
        $0.lineBreakMode = .byWordWrapping
    }
    
    let cancelButton = UIButton(type: .system).then {
        $0.backgroundColor = .white
        $0.layer.borderWidth = 0.5
        $0.layer.borderColor = UIColor.lightGray.cgColor
        $0.layer.cornerRadius = 5
        $0.setTitleColor(.black, for: .normal)
        $0.titleLabel?.font = .boldSystemFont(ofSize: 15)
        $0.addBounceAnimationWithNoFeedback()
    }
    
    let actionButton = UIButton(type: .system).then {
        $0.backgroundColor = UIColor(named: K.Color.appColor)
        $0.layer.cornerRadius = 5
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = .boldSystemFont(ofSize: 15)
        $0.addBounceAnimationWithNoFeedback()
    }
    
    let buttonStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fillEqually
        $0.alignment = .center
        $0.spacing = 5
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.75)
        setUpSubViews()
        bindUI()
    }
    
    init(
        title: String,
        message: String,
        cancelButtonTitle: String,
        actionButtonTitle: String,
        action: @escaping () -> Void = {}
    ) {
        super.init(nibName: nil, bundle: nil)
        titleLabel.text = title
        messageLabel.text = message
        cancelButton.setTitle(cancelButtonTitle, for: .normal)
        actionButton.setTitle(actionButtonTitle, for: .normal)
        actionButton.rx.tap
            .bind {
                action()
                self.dismiss(animated: false)
            }.disposed(by: disposedBag)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpSubViews() {
        self.view.addSubview(alertView)
        [titleLabel, messageLabel].forEach { self.alertView.addSubview($0) }
        
        [cancelButton, actionButton].forEach {
            buttonStackView.addArrangedSubview($0)
        }
        self.alertView.addSubview(buttonStackView)
        
        alertView.snp.makeConstraints {
            $0.width.equalTo(view.frame.size.width - 40)
            $0.height.equalTo(messageLabel.snp.height).multipliedBy(2.0)
            $0.centerX.centerY.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(20)
            $0.leading.equalTo(20)
            $0.trailing.equalTo(-20)
            $0.centerX.equalTo(alertView)
        }
        
        messageLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(5)
            $0.leading.equalTo(20)
            $0.trailing.equalTo(-20)
            $0.centerX.equalTo(alertView)
        }
        
        buttonStackView.snp.makeConstraints {
            $0.top.equalTo(messageLabel.snp.bottom).inset(5)
            $0.left.right.equalToSuperview().inset(10)
            $0.height.greaterThanOrEqualTo(60)
            $0.bottom.equalToSuperview()
        }
        
        cancelButton.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(10)
        }
        
        actionButton.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(10)
        }
    }
    
    func bindUI() {
        cancelButton.rx.tap
            .bind(onNext: {
                self.dismiss(animated: false)
            }).disposed(by: disposedBag)
    }
}
