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
    
    var timer: Timer?
    var currentIndex: Int = 0
    var totalNumberOfBannerImages: Int? {
        didSet {
            startTimer()
        }
    }
    
    //MARK: - UI
    
    let collectionViewLayout = UICollectionViewFlowLayout().then {
        $0.scrollDirection = .horizontal
        $0.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        
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
        totalNumberOfBannerImages = 5
    }
    
    //MARK: - Methods
    
    private func startTimer() {
        timer = Timer.scheduledTimer(
            timeInterval: 4,
            target: self,
            selector: #selector(moveToNextIndex),
            userInfo: nil,
            repeats: true
        )
    }
    
    @objc func moveToNextIndex() {
        
        guard let totalNumber = totalNumberOfBannerImages else {
            print("❗️ BannerHeaderView Index Error")
            return
        }
        
        if currentIndex < totalNumber - 1 {
            currentIndex += 1
            bannerCollectionView.scrollToItem(
                at: IndexPath(item: currentIndex, section: 0),
                at: .centeredHorizontally,
                animated: true
            )
        } else if currentIndex == totalNumber - 1 {
            currentIndex = 0
            bannerCollectionView.scrollToItem(
                at: IndexPath(item: currentIndex, section: 0),
                at: .centeredHorizontally,
                animated: true
            )
        }
    }
}

//MARK: - UICollectionViewDataSource, UICollectionViewDelegate

extension BannerHeaderView: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return totalNumberOfBannerImages ?? 1
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
        return 5
    }
}

//MARK: - UIScrollViewDelegate

extension BannerHeaderView: UIScrollViewDelegate {
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        let layout = bannerCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let cellWidthIncludingSpacing = layout.itemSize.width + layout.minimumLineSpacing
    
        var offset = targetContentOffset.pointee
        let index = (offset.x + scrollView.contentInset.left) / cellWidthIncludingSpacing
        let roundedIndex = round(index)

        offset = CGPoint(x: roundedIndex * cellWidthIncludingSpacing - scrollView.contentInset.left, y: scrollView.contentInset.top)
        
        targetContentOffset.pointee = offset
        
    }
}
