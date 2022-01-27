//
//  KMCustomAlertView.swift
//  KNU_Market
//
//  Created by 장서영 on 2021/11/21.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift
import Then

class KMCustomAlertView: UIView {
    
    let alertView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 10
    }
    
    let titleLabel = UILabel().then {
        $0.font = .boldSystemFont(ofSize: 20)
        $0.textColor = .black
        $0.numberOfLines = 2
    }
    
    let messageLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 15)
        $0.textColor = .black
        $0.numberOfLines = 7
    }
    
    let cancelButton = UIButton().then {
        $0.backgroundColor = .systemGray3
        $0.layer.cornerRadius = 5
    }
    
    let actionButton = UIButton().then {
        $0.backgroundColor = UIColor(named: K.Color.appColor)
        $0.layer.cornerRadius = 5
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
