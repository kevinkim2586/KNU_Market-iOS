//
//  KMGatherStatusView.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2022/01/18.
//

import UIKit
import SnapKit

class KMGatherStatusView: UIView {
    
    //MARK: - UI
    
    let personImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "singlePersonIcon")
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let gatheringStatusLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        $0.textColor = UIColor.white
        $0.textAlignment = .center
        $0.text = "-/-"
    }
    
    lazy var gatheringStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 7
        [personImageView, gatheringStatusLabel].forEach { stackView.addArrangedSubview($0) }
        return stackView
    }()
    
    let gatherDoneLabel = UILabel().then {
        $0.text = "모집완료"
        $0.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        $0.textColor = UIColor.white
        $0.textAlignment = .center
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
    
    init() {
        super.init(frame: .zero)
        setupLayout()
        setupConstraints()
        toggleAsDoneGathering()
    }
    
    //MARK: - Configuration
    
    private func setupLayout() {
        self.addSubview(gatheringStackView)
        self.addSubview(gatherDoneLabel)
    }
    
    private func setupConstraints() {
        
        gatheringStackView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        gatherDoneLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    func toggleAsDoneGathering() {
        self.backgroundColor = UIColor.lightGray
        gatherDoneLabel.isHidden = false
        gatheringStatusLabel.isHidden = true
        personImageView.isHidden = true
    }
    
    func toggleAsStillGathering() {
        self.backgroundColor = UIColor(named: K.Color.appColor)
        gatherDoneLabel.isHidden = true
        gatheringStatusLabel.isHidden = false
        personImageView.isHidden = false
    }
    
    func updateGatheringStatusLabel(currentNum: Int, total: Int) {
        let filteredNumbers = filterInvalidGatheringPeopleNumbers(currentNum, total)
        gatheringStatusLabel.text = "\(filteredNumbers.0)/\(filteredNumbers.1)"
    }
    
    func updateGatheringStatusLabel(currentNum: Int, total: Int, isCompletelyDone: Bool) {
        let filteredNumbers = filterInvalidGatheringPeopleNumbers(currentNum, total)
        gatheringStatusLabel.text = "\(filteredNumbers.0)/\(filteredNumbers.1)"
        isCompletelyDone ? toggleAsDoneGathering() : toggleAsStillGathering()
    }
    
    private func filterInvalidGatheringPeopleNumbers(_ currentNum: Int, _ total: Int) -> (Int, Int) {
        
        var currentNum = currentNum
        var total = total
        
        /// 현재 모집인원 숫자가 1미만이거나 최대 모집 가능 인원 숫자보다 클 상황에 대비
        if currentNum < 1 { currentNum = 1 }
        if currentNum > ValidationError.Restrictions.maximumGatheringPeople { currentNum = ValidationError.Restrictions.maximumGatheringPeople }
        
        /// 모집 가능 인원 숫자가 최소 모집 인원 (2) 보다 작거나 최대 모집 인원 (10) 보다 클 상황에 대비
        if total < ValidationError.Restrictions.minimumGatheringPeople { total = ValidationError.Restrictions.minimumGatheringPeople }
        if total > ValidationError.Restrictions.maximumGatheringPeople { total = ValidationError.Restrictions.maximumGatheringPeople }
        
        return (currentNum, total)
    }
}

