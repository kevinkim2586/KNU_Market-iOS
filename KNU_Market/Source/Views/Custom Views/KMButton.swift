//
//  KMButton.swift
//  KNU_Market
//
//  Created by 김부성 on 2021/11/15.
//

import UIKit

final class KMButton: UIButton {
    
    // MARK: - Constants
    fileprivate struct Style {
        static let titleFont = UIFont.systemFont(ofSize: 20, weight: .bold)
    }

    // MARK: - UI
    
    // MARK: - Initializing
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.clipsToBounds = true
        self.setTitleColor(.white, for: .normal)
        self.titleLabel?.font = Style.titleFont
        self.backgroundColor = UIColor(named: "AppDefaultColor")
    }
    
    override public var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.3) {
                self.backgroundColor = self.backgroundColor?.withAlphaComponent(self.isHighlighted ? 0.5 : 1)
            }
        }
    }
    
    override public var isEnabled: Bool {
        didSet {
            UIView.animate(withDuration: 0.3) {
                self.backgroundColor = self.isEnabled ? UIColor(named: "AppDefaultColor") : UIColor(named: "DisabledColor")
            }
        }
    }
    
}

