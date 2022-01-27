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
        gatheringStatusLabel.text = "\(currentNum)/\(total)"
    }
    
    func updateGatheringStatusLabel(currentNum: Int, total: Int, isCompletelyDone: Bool) {
        gatheringStatusLabel.text = "\(currentNum)/\(total)"
        isCompletelyDone ? toggleAsDoneGathering() : toggleAsStillGathering()
    }
}

