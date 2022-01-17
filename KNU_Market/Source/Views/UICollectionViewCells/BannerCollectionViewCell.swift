//
//  BannerCollectionViewCell.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2022/01/17.
//

import UIKit
import SnapKit

class BannerCollectionViewCell: UICollectionViewCell {
    
    //MARK: - Properties
    
    //MARK: - Constants
    
    static let cellId: String = "BannerCollectionViewCell"
    
    //MARK: - UI
    
    let bannerImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.layer.cornerRadius = 15
        $0.layer.masksToBounds = true
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
    
    //MARK: - UI Setup
    
    
    private func setupLayout() {
        contentView.addSubview(bannerImageView)
    }
    
    private func setupConstraints() {
        bannerImageView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(20)
            $0.left.equalToSuperview().inset(36)
            $0.bottom.equalToSuperview().inset(20)
            $0.right.equalToSuperview().offset(0)
        }
    }
}
