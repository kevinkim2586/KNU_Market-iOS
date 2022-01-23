//
//  UploadPostGuideLabel.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2022/01/23.
//

import UIKit
import Then
import SnapKit

class UploadPostGuideLabel: UILabel {
    
    //MARK: - Constants
    
    fileprivate struct Metrics {
        static let indicatorSize = 7.f
    }
    
    //MARK: - UI
    
    let requiredIndicatorView = UIView().then {
        $0.backgroundColor = UIColor(named: K.Color.appColor)
    }
    
    let guideLabel = UILabel().then {
        $0.font = UIFont.init(name: K.Fonts.notoSansKRMedium, size: 15)
        $0.textColor = .darkGray
    }
    
    let labelStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fillProportionally
        $0.alignment = .top
        $0.spacing = 3
    }
    
    //MARK: - Initialization
    
    init(indicatorIsRequired: Bool, labelTitle: String) {
        guideLabel.text = labelTitle
        requiredIndicatorView.isHidden = indicatorIsRequired == true ? false : true
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    //MARK: - Life Cycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
                
        requiredIndicatorView.snp.makeConstraints {
            $0.width.height.equalTo(Metrics.indicatorSize)
        }
        
        requiredIndicatorView.layer.cornerRadius = Metrics.indicatorSize / 2
        
        [requiredIndicatorView, guideLabel].forEach {
            labelStackView.addArrangedSubview($0)
        }
        addSubview(labelStackView)
        
        labelStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
