//
//  PostListCollectionHeaderView.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2022/01/17.
//

import UIKit
import SnapKit

class BannerHeaderView: UIView {
    
    //MARK: - Properties
    
    //MARK: - UI
    
    let collectionViewLayout = UICollectionViewFlowLayout().then {
        $0.scrollDirection = .horizontal
        $0.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    lazy var bannerCollectionView = UICollectionView(frame: .zero, collectionViewLayout: self.collectionViewLayout).then {
        $0.delegate = self
        $0.dataSource = self
        $0.clipsToBounds = true
        $0.register(
            BannerCollectionViewCell.self,
            forCellWithReuseIdentifier: BannerCollectionViewCell.cellId
        )
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .white
        $0.showsHorizontalScrollIndicator = false
    }
    
    //MARK: - Constants
    
    //MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    //MARK: - UI Setup
    
    private func setupLayout() {
        self.addSubview(bannerCollectionView)
    }
    
    private func setupConstraints() {
        bannerCollectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

//MARK: - UICollectionViewDataSource, UICollectionViewDelegate

extension BannerHeaderView: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = bannerCollectionView.dequeueReusableCell(withReuseIdentifier: BannerCollectionViewCell.cellId, for: indexPath) as? BannerCollectionViewCell else {
            fatalError()
        }
        
        cell.bannerImageView.image = UIImage(named: "bannerMock")
        cell.backgroundColor = .clear
        return cell
    }
}

//MARK: - UICollectionViewDelegateFlowLayout

extension BannerHeaderView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 350, height: 180)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return -5
    }

}
