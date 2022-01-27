//
//  KMUrlLinkButton.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2022/01/21.
//

import UIKit

class KMUrlLinkButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func configure() {
        backgroundColor = UIColor.white.withAlphaComponent(0.8)
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 1, height: 1)
        layer.shadowOpacity = 0.4
        layer.shadowRadius = 5
        layer.cornerRadius = 20
        setTitle("링크 보러가기", for: .normal)
        setTitleColor(.black, for: .normal)
        let buttonImage = UIImage(
            systemName: "arrow.up.right",
            withConfiguration: UIImage.SymbolConfiguration(font: .systemFont(ofSize: 12))
        )
        tintColor = .black
        setImage(buttonImage, for: .normal)
        transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        titleLabel?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        imageView?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        isHidden = true
        titleLabel?.font = UIFont(name: K.Fonts.notoSansKRMedium, size: 13)
    }
    
}
