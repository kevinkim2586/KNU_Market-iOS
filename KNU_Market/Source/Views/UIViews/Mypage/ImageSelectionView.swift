//
//  ImageSelectionView.swift
//  KNU_Market
//
//  Created by 김부성 on 2021/11/21.
//

import UIKit
import SnapKit
import RxSwift
import RxGesture
import RxRelay

final class ImageSelectionView: UIView {
    
    // MARK: - Properties
    let disposeBag: DisposeBag = DisposeBag()
    let tap: PublishRelay<UITapGestureRecognizer> = .init()
    
    // MARK: - Constants
    fileprivate struct Metric {
        // Image
        static let imageHeight = 25.f
        static let imageWidth = 25.f
        static let imageY = 7.f
        
        // Label
        static let labelTop = 5.f
    }
    
    fileprivate struct Style {
        // SuperView
        static let borderWidth = 1.f
        static let cornerRadius = 5.f
        static let borderColor = UIColor.lightGray.cgColor
        static let backgroundColor = UIColor.convertUsingHexString(hexValue: "#F0F0F0")
        
        // imageView
        static let image = UIImage(named: "camera")
        static let mainColor = UIColor.init(named: K.Color.appColor)
    }
    
    fileprivate struct Font {
        static let labelFont = UIFont.systemFont(ofSize: 10, weight: .semibold)
    }
    
    // MARK: - UI
    let imageView = UIImageView().then {
        $0.image = Style.image
        $0.tintColor = Style.mainColor
    }
    
    let label = UILabel().then {
        $0.textColor = .lightGray
        $0.font = Font.labelFont
    }
    
    // MARK: - Initializing
    override init(frame: CGRect) {
        super.init(frame: .zero)
        self.bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func layoutSubviews() {
        super.layoutSubviews()
        
//        self.layer.borderWidth = Style.borderWidth
        self.layer.cornerRadius = Style.cornerRadius
        self.layer.borderColor = Style.borderColor
        self.backgroundColor = Style.backgroundColor
        self.clipsToBounds = true
        
        self.addSubview(self.imageView)
        self.addSubview(self.label)
        
        self.imageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-Metric.imageY)
            $0.height.equalTo(Metric.imageHeight)
            $0.width.equalTo(Metric.imageWidth)
        }
        
        self.label.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(self.imageView.snp.bottom).offset(Metric.labelTop)
        }
    }
    
    // MARK: - Configuring
    func bind() {
        Observable.merge(
            self.rx.tapGesture().when(.recognized),
            self.imageView.rx.tapGesture().when(.recognized)
        )
            .bind(to: self.tap)
            .disposed(by: disposeBag)
        
    }
}
