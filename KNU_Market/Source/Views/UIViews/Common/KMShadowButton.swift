//
//  KMGradientButton.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2022/01/18.
//

import UIKit

class KMShadowButton: UIButton {
    
    var buttonTitle: String?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    init(buttonTitle: String) {
        super.init(frame: .zero)
        self.buttonTitle = buttonTitle
        configure()
    }
    
    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.2) {
                self.backgroundColor = self.backgroundColor?.withAlphaComponent(self.isHighlighted ? 0.5 : 1)
            }
        }
    }
    
    override var isEnabled: Bool {
        didSet {
            UIView.animate(withDuration: 0.2) {
                self.backgroundColor = self.isEnabled
                ? UIColor(named: K.Color.appColor)
                : UIColor.convertUsingHexString(hexValue: "#A3A3A3")
            }
        }
    }
    
    private func configure() {
        setTitle(buttonTitle ?? "확인", for: .normal)
        backgroundColor = UIColor(named: K.Color.appColor)
        titleLabel?.font = UIFont(name: K.Fonts.notoSansKRMedium, size: 16)
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 1, height: 1)
        self.layer.shadowOpacity = 0.4
        self.layer.shadowRadius = 5
        self.layer.cornerRadius = 10
    }
    
}
