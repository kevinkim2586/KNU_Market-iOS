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

class CustomAlertViewController_Rx: UIViewController {
    
    let disposedBag = DisposeBag()
    
    let alertObserver = PublishSubject<ActionType>()
    
    let alertView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 20
        $0.clipsToBounds = true
    }
    
    let titleLabel = UILabel().then {
        $0.font = .boldSystemFont(ofSize: 16)
        $0.font = UIFont(name: K.Fonts.notoSansKRMedium, size: 16)
        $0.textColor = .black
        $0.textAlignment = .left
        $0.numberOfLines = 2
    }
    
    let messageLabel = UILabel().then {
        $0.font = UIFont(name: K.Fonts.notoSansKRRegular, size: 15)
        $0.textColor = .black
        $0.textAlignment = .left
        $0.numberOfLines = 0
        $0.adjustsFontSizeToFitWidth = true
        $0.minimumScaleFactor = 0.75
        $0.lineBreakMode = .byWordWrapping
    }
    
    let cancelButton = UIButton(type: .system).then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 0
        $0.setTitleColor(.black, for: .normal)
        $0.titleLabel?.font = UIFont(name: K.Fonts.notoSansKRRegular, size: 14)
    }
    
    let actionButton = UIButton(type: .system).then {
        $0.backgroundColor = UIColor(named: K.Color.appColor)
        $0.layer.cornerRadius = 0
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = UIFont(name: K.Fonts.notoSansKRRegular, size: 14)
    }
    
    let buttonStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fillEqually
        $0.alignment = .fill
        $0.spacing = 0
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
        actionButtonTitle: String
    ) {
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .overFullScreen
        self.modalTransitionStyle = .crossDissolve
        titleLabel.text = title
        messageLabel.text = message
        cancelButton.setTitle(cancelButtonTitle, for: .normal)
        actionButton.setTitle(actionButtonTitle, for: .normal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpSubViews() {
        view.addSubview(alertView)
        alertView.addSubview(titleLabel)
        alertView.addSubview(messageLabel)
     
        [cancelButton, actionButton].forEach {
            buttonStackView.addArrangedSubview($0)
        }
        alertView.addSubview(buttonStackView)
        
    
        alertView.snp.makeConstraints {
            $0.width.equalTo(self.view.frame.size.width - 40)
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
            $0.height.equalTo(45)
            $0.left.equalToSuperview()
            $0.right.equalToSuperview()
            $0.top.equalTo(messageLabel.snp.bottom).offset(10)
            $0.bottom.equalToSuperview()
        }
    }
    
    func bindUI() {
        
        actionButton.rx.tap
            .withUnretained(self)
            .subscribe(onNext: { _ in
                self.alertObserver.onNext(.ok)
                self.alertObserver.onCompleted()
                self.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposedBag)
        
        cancelButton.rx.tap
            .withUnretained(self)
            .subscribe(onNext: { _ in
                self.alertObserver.onNext(.cancel)
                self.alertObserver.onCompleted()
                self.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposedBag)
    }
}
