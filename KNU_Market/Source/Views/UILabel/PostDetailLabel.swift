//
//  PostDetailLabel.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2022/01/19.
//

import UIKit
import Atributika
import RxSwift

//MARK: - PostVC 공구글 내용 상세보기 전용 UILabel

class PostDetailLabel: AttributedLabel {
    
    fileprivate struct Fonts {
        
        private static let paragraphStyle = NSMutableParagraphStyle().then {
            $0.lineSpacing = 5
        }
        
        static let linkStyle = Style
            .foregroundColor(UIColor.systemBlue, .normal)
            .foregroundColor(UIColor.gray, .highlighted)
            .paragraphStyle(paragraphStyle)
            .underlineStyle(.single)
            .font(UIFont(name: K.Fonts.notoSansKRLight, size: 14)!)
        
        static let textStyle = Style
            .font(UIFont(name: K.Fonts.notoSansKRLight, size: 14)!)
            .foregroundColor(UIColor.black)
    }

    
    var text: String? {
        get {
            return self.attributedText?.string
        }
        set(newValue){
            self.attributedText = newValue?
                .styleLinks(Fonts.linkStyle)
                .styleAll(Fonts.textStyle)
        }
    }
 
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func configure() {
        self.attributedText = "로딩 중".styleLinks(Fonts.textStyle)
        self.numberOfLines = 0
    }
}
