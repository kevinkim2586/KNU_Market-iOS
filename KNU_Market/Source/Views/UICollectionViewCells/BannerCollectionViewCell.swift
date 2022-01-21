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
        $0.clipsToBounds = true
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
            $0.center.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(0.96)
            $0.height.equalToSuperview().multipliedBy(0.9)
        }
    }
}
