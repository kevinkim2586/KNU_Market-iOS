//
//  PerPersonPriceInfoViewController.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2022/01/21.
//

import UIKit
import Then
import SnapKit
import RxSwift

class PerPersonPriceInfoViewController: BaseViewController {

    //MARK: - Properties
    
    let productPrice: Int
    let shippingFee: Int
    let totalPrice: Int
    let totalGatheringPeople: Int
    let perPersonPrice: Int
    
    //MARK: - Constants
    
    fileprivate struct Metrics {
        static let defaultPadding       = 20.f
        static let defaultTopPadding    = 10.f
    }
    
    fileprivate struct Fonts {
        static let labelFont = UIFont(name: K.Fonts.notoSansKRRegular, size: 15)
    }
    
    //MARK: - UI
    
    let productPriceInfoLabel = UILabel().then {
        $0.font = Fonts.labelFont
        $0.text = "제품 총 가격(원)"
    }
    
    let productPriceLabel = UILabel().then {
        $0.font = Fonts.labelFont
        $0.text = "0"
        $0.textAlignment = .right
    }
    
    let productPriceStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fillProportionally
        $0.alignment = .center
        $0.spacing = 5
    }
    
    let plusLabel = UILabel().then {
        $0.font = Fonts.labelFont
        $0.text = "+"
    }
    
    let shippingFeeInfoLabel = UILabel().then {
        $0.font = Fonts.labelFont
        $0.text = "배송비(원)"
    }
    
    let shippingFeeLabel = UILabel().then {
        $0.font = Fonts.labelFont
        $0.text = "0"
        $0.textAlignment = .right
    }
    
    let shippingFeeStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fillProportionally
        $0.alignment = .center
        $0.spacing = 5
    }
    
    let dividerLine_1 = UIView().then {
        $0.backgroundColor = .black
    }
    
    let totalPriceInfoLabel = UILabel().then {
        $0.font = Fonts.labelFont
        $0.textAlignment = .center
        $0.text = "합계(원)"
    }
    
    let totalPriceLabel = UILabel().then {
        $0.font = Fonts.labelFont
        $0.textAlignment = .right
        $0.text = "0"
    }
    
    let totalPriceStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fillProportionally
        $0.alignment = .center
        $0.spacing = 5
    }

    let dividerLabel = UILabel().then {
        $0.font = Fonts.labelFont
        $0.text = "÷"
    }
    
    
    let totalGatheringPeopleInfoLabel = UILabel().then {
        $0.font = Fonts.labelFont
        $0.text = "인원(명)"
    }
    
    let totalGatheringPeopleLabel = UILabel().then {
        $0.font = Fonts.labelFont
        $0.text = "2"
        $0.textAlignment = .right
    }
    
    let totalGatheringPeopleStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fill
        $0.alignment = .center
        $0.spacing = 5
    }
    
    let dividerLine_2 = UIView().then {
        $0.backgroundColor = .black
    }
    
    let perPersonPriceInfoLabel = UILabel().then {
        $0.font = Fonts.labelFont
        $0.text = "1인당 가격(원)"
        $0.textColor = UIColor(named: K.Color.appColor)!
    }
    
    let perPersonPriceLabel = UILabel().then {
        $0.font = Fonts.labelFont
        $0.textColor = UIColor(named: K.Color.appColor)!
        $0.text = "0"
        $0.textAlignment = .right
    }
    
    let perPersonPriceStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fillProportionally
        $0.alignment = .center
        $0.spacing = 5
    }
    
    //MARK: - Initialization
    
    init(
        productPrice: Int,
        shippingFee: Int,
        totalPrice: Int,
        totalGatheringPeople: Int,
        perPersonPrice: Int
    ) {
        self.productPrice = productPrice
        self.shippingFee = shippingFee
        self.totalPrice = totalPrice
        self.totalGatheringPeople = totalGatheringPeople
        self.perPersonPrice = perPersonPrice
        super.init()
        self.modalPresentationStyle = .popover
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    //MARK: - UI Setup
    
    override func setupLayout() {
        super.setupLayout()
        
        [productPriceInfoLabel, productPriceLabel].forEach {
            productPriceStackView.addArrangedSubview($0)
        }
        view.addSubview(productPriceStackView)
        
     
        [plusLabel, shippingFeeInfoLabel, shippingFeeLabel].forEach {
            shippingFeeStackView.addArrangedSubview($0)
        }
        view.addSubview(shippingFeeStackView)

        view.addSubview(dividerLine_1)

        [totalPriceInfoLabel, totalPriceLabel].forEach {
            totalPriceStackView.addArrangedSubview($0)
        }
        view.addSubview(totalPriceStackView)


        [dividerLabel, totalGatheringPeopleInfoLabel, totalGatheringPeopleLabel].forEach {
            totalGatheringPeopleStackView.addArrangedSubview($0)
        }
        view.addSubview(totalGatheringPeopleStackView)
     

        view.addSubview(dividerLine_2)

        [perPersonPriceInfoLabel, perPersonPriceLabel].forEach {
            perPersonPriceStackView.addArrangedSubview($0)
        }
        view.addSubview(perPersonPriceStackView)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        productPriceStackView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(Metrics.defaultPadding + 20)
            $0.right.equalToSuperview().inset(Metrics.defaultPadding)
            $0.left.equalToSuperview().inset(Metrics.defaultPadding + 18)
        }
        
        shippingFeeStackView.snp.makeConstraints {
            $0.top.equalTo(productPriceStackView.snp.bottom).offset(Metrics.defaultTopPadding)
            $0.left.right.equalToSuperview().inset(Metrics.defaultPadding)
        }

        dividerLine_1.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.top.equalTo(shippingFeeStackView.snp.bottom).offset(Metrics.defaultTopPadding)
            $0.left.right.equalToSuperview().inset(10)
        }

        totalPriceStackView.snp.makeConstraints {
            $0.top.equalTo(dividerLine_1.snp.bottom).offset(Metrics.defaultTopPadding)
            $0.left.equalToSuperview().inset(Metrics.defaultPadding)
            $0.right.equalToSuperview().inset(Metrics.defaultPadding)
        }

        totalGatheringPeopleStackView.snp.makeConstraints {
            $0.top.equalTo(totalPriceStackView.snp.bottom).offset(Metrics.defaultTopPadding)
            $0.left.right.equalToSuperview().inset(Metrics.defaultPadding)
        }

        dividerLine_2.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.top.equalTo(totalGatheringPeopleStackView.snp.bottom).offset(Metrics.defaultTopPadding)
            $0.left.right.equalToSuperview().inset(10)
        }

        perPersonPriceStackView.snp.makeConstraints {
            $0.top.equalTo(dividerLine_2.snp.bottom).offset(Metrics.defaultTopPadding)
            $0.right.equalToSuperview().inset(Metrics.defaultPadding)
            $0.left.equalToSuperview().inset(Metrics.defaultPadding + 20)
        }
    }
    
    private func configure() {
        productPriceLabel.text = productPrice.withDecimalSeparator
        shippingFeeLabel.text = shippingFee.withDecimalSeparator
        totalPriceLabel.text = totalPrice.withDecimalSeparator
        totalGatheringPeopleLabel.text = "\(totalGatheringPeople)"
        perPersonPriceLabel.text = perPersonPrice.withDecimalSeparator
    }
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI

@available(iOS 13.0, *)
struct PerPersonPriceInfoVC: PreviewProvider {

    static var previews: some SwiftUI.View {
        PerPersonPriceInfoViewController(productPrice: 3232, shippingFee: 223, totalPrice: 123, totalGatheringPeople: 12, perPersonPrice: 123).toPreview()
    }
}
#endif
