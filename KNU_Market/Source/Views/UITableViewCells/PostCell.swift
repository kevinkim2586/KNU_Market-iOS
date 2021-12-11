//
//  PostCell.swift
//  KNU_Market
//
//  Created by 김부성 on 2021/12/11.
//

import UIKit
import Atributika
import RxSwift
import RxRelay

let linkOnClicked = PublishSubject<URL>()
class PostCell: UITableViewCell {

    // MARK: - Constants
    fileprivate struct Fonts {
        private static let paragraphStyle = NSMutableParagraphStyle().then {
            $0.lineSpacing = 5
        }
        
        static let linkStyle = Style
            .foregroundColor(UIColor.systemBlue, .normal)
            .foregroundColor(UIColor.gray, .highlighted)
            .paragraphStyle(paragraphStyle)
            .underlineStyle(.single)
    }
    
    // MARK: - Properties
    var title: String? {
        get {
            return self.titleLabel.attributedText?.string
        }
        
        set(value) {
            titleLabel.attributedText = value?.styleLinks(Fonts.linkStyle)
        }
    }
    
    // MARK: - UI
    let titleLabel = AttributedLabel()
    
    //MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setupLayout()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }

    fileprivate func setupLayout() {
        self.contentView.addSubview(self.titleLabel)
        bind()
    }
    
    fileprivate func setupConstraints() {
        self.titleLabel.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview().inset(10)
        }
    }
    
    fileprivate func bind() {
        self.titleLabel.onClick = { label, detection in
            switch detection.type {
            case let .link(url):
                linkOnClicked.onNext(url)
            default:
                break
            }
        }
    }

}
