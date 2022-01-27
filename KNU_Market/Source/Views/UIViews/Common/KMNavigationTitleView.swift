//
//  KMNavigationTitleView.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2022/01/21.
//

import UIKit
import SnapKit

class KMNavigationTitleView: UIView {

    //MARK: - UI
    
    let appTitleLabel = UILabel().then {
        $0.text = "크누마켓"
        $0.font = UIFont(name: K.Fonts.notoSansBold, size: 21)
        $0.textColor = .black
    }
    
    let appCopyLabel = UILabel().then {
        $0.text = "우리가 함께 사는 곳"
        $0.font = UIFont(name: K.Fonts.notoSansRegular, size: 15)
        $0.textColor = .black
    }
    
    let appTitleLabelStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.distribution = .fill
        $0.spacing = 5
    }
    
    let emptySpaceView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
    
    let containerStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.distribution = .fill
        $0.spacing = 3
    }

    //MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    
    private func setupLayout() {
        [appTitleLabel, appCopyLabel].forEach {
            appTitleLabelStackView.addArrangedSubview($0)
        }
        
        [appTitleLabelStackView, emptySpaceView].forEach {
            containerStackView.addArrangedSubview($0)
        }
        
        self.addSubview(containerStackView)
    }
    
    private func setupConstraints() {
        containerStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
