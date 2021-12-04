//
//  InquiryTableViewCell.swift
//  KNU_Market
//
//  Created by 장서영 on 2021/11/13.
//

import UIKit
import SnapKit

class InquiryTableViewCell: UITableViewCell {
    
    static let cellId: String = "InquiryTableViewCell"
    
    let dateLabel: UILabel = {
        let dateLabel = UILabel()
        dateLabel.font = .systemFont(ofSize: 10)
        dateLabel.textColor = .black
        return dateLabel
    }()
    
    let inquiryTitleLabel: UILabel = {
        let inquieryTitleLabel = UILabel()
        inquieryTitleLabel.font = .boldSystemFont(ofSize: 14)
        inquieryTitleLabel.textColor = .black
        return inquieryTitleLabel
    }()
    
    let prograssImageView: UIImageView = {
        let prograssImg = UIImageView()
        prograssImg.contentMode = .scaleAspectFit
        return prograssImg
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpSubViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func setUpSubViews() {
        self.addSubview(self.contentView)
        [dateLabel, inquiryTitleLabel, prograssImageView].forEach({ self.contentView.addSubview($0)})
        
        dateLabel.snp.makeConstraints {
            $0.top.equalToSafeArea(contentView).offset(10)
            $0.leading.equalTo(25)
        }
        
        inquiryTitleLabel.snp.makeConstraints {
            $0.top.equalTo(dateLabel.snp.bottom).offset(5)
            $0.leading.equalTo(25)
            $0.bottom.equalTo(-17)
        }
        
        prograssImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(inquiryTitleLabel.snp.trailing).offset(10)
            $0.trailing.equalTo(-25)
            $0.width.height.equalTo(34)
        }
    }

}
