//
//  InquiryTableViewCell.swift
//  KNU_Market
//
//  Created by 장서영 on 2021/11/13.
//

import UIKit
import SnapKit

class InquiryTableViewCell: UITableViewCell {
    
    let dateLabel: UILabel = {
        let dateLabel = UILabel()
        dateLabel.font = .systemFont(ofSize: 10)
        dateLabel.textColor = .black
        return dateLabel
    }()
    
    let inquieryTitleLabel: UILabel = {
        let inquieryTitleLabel = UILabel()
        inquieryTitleLabel.font = .boldSystemFont(ofSize: 13)
        inquieryTitleLabel.textColor = .black
        return inquieryTitleLabel
    }()
    
    let prograssImageView: UIImageView = {
        let prograssImg = UIImageView()
        prograssImg.contentMode = .scaleAspectFit
        return prograssImg
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func setUpSubViews() {
        [dateLabel, inquieryTitleLabel, prograssImageView].forEach({ self.addSubview($0)})
        
        dateLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.leading.equalTo(25)
        }
        
        inquieryTitleLabel.snp.makeConstraints {
            $0.top.equalTo(dateLabel.snp.bottom).offset(5)
            $0.leading.equalTo(25)
        }
        
        prograssImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalTo(25)
        }
    }

}
