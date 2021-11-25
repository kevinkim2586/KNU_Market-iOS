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

class KMCustomAlertViewController: UIViewController {
    
    let disposedBag = DisposeBag()
    
    let alertView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 10
    }
    
    let titleLabel = UILabel().then {
        $0.font = .boldSystemFont(ofSize: 20)
        $0.textColor = .black
        $0.textAlignment = .center
        $0.numberOfLines = 2
    }
    
    let messageLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 15)
        $0.textColor = .black
        $0.textAlignment = .center
        $0.numberOfLines = 7
    }
    
    let cancelButton = UIButton(type: .system).then {
        $0.backgroundColor = .systemGray3
        $0.layer.cornerRadius = 5
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = .boldSystemFont(ofSize: 15)
    }
    
    let actionButton = UIButton(type: .system).then {
        $0.backgroundColor = UIColor(named: K.Color.appColor)
        $0.layer.cornerRadius = 5
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = .boldSystemFont(ofSize: 15)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.75)
        setUpSubViews()
        cancelButtonTapped()
    }
    
    init(title: String, message: String, cancelButtonTitle: String, actionButtonTitle: String, action: @escaping () -> Void = { }) {
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
        [titleLabel, messageLabel, cancelButton, actionButton].forEach({ self.alertView.addSubview($0) })
        
        alertView.snp.makeConstraints {
            $0.width.equalTo(280)
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
            $0.top.equalTo(titleLabel.snp.bottom).offset(10)
            $0.leading.equalTo(20)
            $0.trailing.equalTo(-20)
            $0.centerX.equalTo(alertView)
        }
        
        cancelButton.snp.makeConstraints {
            $0.width.equalTo(125)
            $0.height.equalTo(44)
            $0.leading.equalTo(alertView).offset(10)
            $0.bottom.equalTo(alertView).offset(-10)
            $0.top.equalTo(messageLabel.snp.bottom).offset(10)
        }
        
        actionButton.snp.makeConstraints {
            $0.width.equalTo(125)
            $0.height.equalTo(44)
            $0.leading.equalTo(cancelButton.snp.trailing).offset(10)
            $0.trailing.equalTo(alertView).offset(-10)
            $0.bottom.equalTo(alertView).offset(-10)
            $0.top.equalTo(messageLabel.snp.bottom).offset(10)
        }
    }
    
    func cancelButtonTapped() {
        cancelButton.rx.tap
            .bind(onNext: {
                self.dismiss(animated: false)
            }).disposed(by: disposedBag)
    }
}
