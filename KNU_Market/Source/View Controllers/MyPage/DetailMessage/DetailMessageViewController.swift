//
//  DetailMessageViewController.swift
//  KNU_Market
//
//  Created by 김부성 on 2021/11/21.
//

import UIKit

import ReactorKit

final class DetailMessageViewController: BaseViewController, ReactorKit.View {
    
    var disposeBag: DisposeBag = DisposeBag()
    
    typealias Reactor = DetailMessageViewReactor
    
    // MARK: - Constants
    fileprivate struct Metric {
        // View
        static let viewSide = 20.f
        
        // title
        static let titleTop = 30.f
        static let titleTextFieldTop = 20.f
        static let titleTextFieldHeight = 50.f
    }
    
    fileprivate struct Fonts {
        static let titleFont = UIFont.systemFont(ofSize: 14, weight: .light)
        static let tintFont = UIFont.systemFont(ofSize: 16, weight: .bold)
        static let textFont = UIFont.systemFont(ofSize: 13, weight: .regular)
    }
    
    fileprivate struct Style {
        static let mainColor = UIColor(named: "AppDefaultColor")
        
        static let borderWidth = 1.f
        static let cornerRadius = 5.f
    }
    
    // MARK: - Properties
    
    // MARK: - UI
    let titleLabel = UILabel().then {
        $0.text = "문의 및 건의 내용"
        $0.font = Fonts.tintFont
    }
    
    let titleTextField = UITextField().then {
        $0.borderStyle = .roundedRect
        $0.layer.borderWidth = Style.borderWidth
        $0.layer.cornerRadius = Style.cornerRadius
        $0.layer.borderColor = UIColor.lightGray.cgColor
        $0.tintColor = Style.mainColor
        $0.font = Fonts.textFont
        $0.isEnabled = false
    }
    
    let explainLabel = UILabel().then {
        $0.text = "상세 내용"
        $0.font = Fonts.tintFont
    }
    
    let explainTextView = UITextView().then {
        $0.font = Fonts.textFont
        $0.layer.borderWidth = Style.borderWidth
        $0.tintColor = Style.mainColor
        $0.layer.borderColor = UIColor.lightGray.cgColor
        $0.layer.cornerRadius = Style.cornerRadius
        $0.isEditable = false
    }
    
    let answerLabel = UILabel().then {
        $0.text = "답변 내용"
        $0.font = Fonts.tintFont
        $0.textColor = Style.mainColor
    }
    
    let answerTextView = UITextView().then {
        $0.font = Fonts.textFont
        $0.layer.borderWidth = Style.borderWidth
        $0.tintColor = Style.mainColor
        $0.layer.borderColor = UIColor.lightGray.cgColor
        $0.layer.cornerRadius = Style.cornerRadius
        $0.isEditable = false
    }

    
    // MARK: - Inintializing
    init(reactor: Reactor) {
        super.init()
        defer {
            self.reactor = reactor
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func setupLayout() {
        super.setupLayout()
        
        self.view.addSubview(self.titleLabel)
        self.view.addSubview(self.titleTextField)
        self.view.addSubview(self.explainLabel)
        self.view.addSubview(self.explainTextView)
        self.view.addSubview(self.answerLabel)
        self.view.addSubview(self.answerTextView)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        self.titleLabel.snp.makeConstraints {
            $0.top.equalToSafeArea(self.view).offset(Metric.titleTop)
            $0.leading.equalToSafeArea(self.view).offset(Metric.viewSide)
            $0.trailing.equalToSafeArea(self.view).offset(-Metric.viewSide)
        }
        
        self.titleTextField.snp.makeConstraints {
            $0.top.equalTo(self.titleLabel.snp.bottom).offset(Metric.titleTextFieldTop)
            $0.leading.equalToSafeArea(self.view).offset(Metric.viewSide)
            $0.trailing.equalToSafeArea(self.view).offset(-Metric.viewSide)
            $0.height.equalTo(Metric.titleTextFieldHeight)
        }
        
        self.explainLabel.snp.makeConstraints {
            $0.top.equalTo(self.titleTextField.snp.bottom).offset(20)
            $0.leading.equalToSafeArea(self.view).offset(Metric.viewSide)
            $0.trailing.equalToSafeArea(self.view).offset(-Metric.viewSide)
        }
        
        self.explainTextView.snp.makeConstraints {
            $0.top.equalTo(self.explainLabel.snp.bottom).offset(10)
            $0.leading.equalToSafeArea(self.view).offset(Metric.viewSide)
            $0.trailing.equalToSafeArea(self.view).offset(-Metric.viewSide)
            $0.height.equalTo(self.view.frame.height / 4)
        }
        
        self.answerLabel.snp.makeConstraints {
            $0.top.equalTo(self.explainTextView.snp.bottom).offset(20)
            $0.leading.equalToSafeArea(self.view).offset(Metric.viewSide)
            $0.trailing.equalToSafeArea(self.view).offset(-Metric.viewSide)
        }
        
        self.answerTextView.snp.makeConstraints {
            $0.top.equalTo(self.answerLabel.snp.bottom).offset(10)
            $0.leading.equalToSafeArea(self.view).offset(Metric.viewSide)
            $0.trailing.equalToSafeArea(self.view).offset(-Metric.viewSide)
            $0.height.equalTo(self.view.frame.height / 4)
        }
    }
    
    override func setupStyle() {
        super.setupStyle()
        
        self.title = "문의내용"
    }
    
    // MARK: - Configuring
    func bind(reactor: Reactor) {
        reactor.state.map { $0.title }.asObservable()
            .bind(to: self.titleTextField.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.content }.asObservable()
            .bind(to: self.explainTextView.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.answer.isEmpty }.asObservable()
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.answerLabel.isHidden = $0
                self.answerTextView.isHidden = $0
            })
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.answer }.asObservable()
            .bind(to: self.answerTextView.rx.text)
            .disposed(by: disposeBag)
    }
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI

@available(iOS 13.0, *)
struct DetailMessageVC: PreviewProvider {
    
    static var previews: some SwiftUI.View {
        DetailMessageViewController(reactor: DetailMessageViewReactor(title: "", content: "", answer: "")).toPreview()
    }
}
#endif
