//
//  DetailMessageViewController.swift
//  KNU_Market
//
//  Created by 김부성 on 2021/11/21.
//

import UIKit

import ReactorKit
import Atributika

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
        
        // Label
        static let labelTop = 20.f
        
        // Text View
        static let textViewTop = 10.f
        
        // Image
        static let imageTop = 50.f
        static let imageHeight = 160.f
        static let imageWidth = 130.f
    }
    
    fileprivate struct Fonts {
        static let titleFont = UIFont.systemFont(ofSize: 14, weight: .light)
        static let tintFont = UIFont.systemFont(ofSize: 16, weight: .bold)
        static let textFont = UIFont.systemFont(ofSize: 13, weight: .regular)
        
        static let highlightFont = Style("h")
            .font(.systemFont(ofSize: 14, weight: .bold))
            .foregroundColor(Styles.mainColor!).underlineStyle(.single)
        static let defaultFont = Style
            .font(.systemFont(ofSize: 14, weight: .bold))
            .foregroundColor(.darkGray)
    }
    
    fileprivate struct Styles {
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
        $0.layer.borderWidth = Styles.borderWidth
        $0.layer.cornerRadius = Styles.cornerRadius
        $0.layer.borderColor = UIColor.lightGray.cgColor
        $0.tintColor = Styles.mainColor
        $0.font = Fonts.textFont
        $0.isEnabled = false
    }
    
    let explainLabel = UILabel().then {
        $0.text = "상세 내용"
        $0.font = Fonts.tintFont
    }
    
    let explainTextView = UITextView().then {
        $0.font = Fonts.textFont
        $0.layer.borderWidth = Styles.borderWidth
        $0.tintColor = Styles.mainColor
        $0.layer.borderColor = UIColor.lightGray.cgColor
        $0.layer.cornerRadius = Styles.cornerRadius
        $0.isEditable = false
    }
    
    let answerLabel = UILabel().then {
        $0.text = "답변 내용"
        $0.font = Fonts.tintFont
        $0.textColor = Styles.mainColor
    }
    
    let answerTextView = UITextView().then {
        $0.font = Fonts.textFont
        $0.layer.borderWidth = Styles.borderWidth
        $0.tintColor = Styles.mainColor
        $0.layer.borderColor = UIColor.lightGray.cgColor
        $0.layer.cornerRadius = Styles.cornerRadius
        $0.isEditable = false
    }
    
    let noAnswerLabel = UILabel().then {
        $0.text = "조금만 기다려주시면 답변 드리겠습니다"
        $0.textColor = .gray
        $0.font = Fonts.tintFont
    }
    
    let noAnswerImage = UIImageView().then {
        $0.image = UIImage(named: "no_answer_image")
    }
    
    let resendButton = UIButton(type: .system).then {
        $0.titleLabel?.numberOfLines = 2
        $0.titleLabel?.textAlignment = .center
        $0.setAttributedTitle(
            "해당 답변으로 문제 해결이 되지 않으셨다면\n<h>다시 문의</h> 주시면 도움드리겠습니다."
            .style(tags: Fonts.highlightFont)
            .styleAll(Fonts.defaultFont)
            .attributedString,
            for: .normal)
    }

    
    // MARK: - Inintializing
    init(reactor: Reactor) {
        super.init()
        
        self.navigationController?.navigationBar.isTranslucent = false
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
        self.view.addSubview(self.noAnswerLabel)
        self.view.addSubview(self.noAnswerImage)
        self.view.addSubview(self.resendButton)
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
            $0.top.equalTo(self.titleTextField.snp.bottom).offset(Metric.labelTop)
            $0.leading.equalToSafeArea(self.view).offset(Metric.viewSide)
            $0.trailing.equalToSafeArea(self.view).offset(-Metric.viewSide)
        }
        
        self.explainTextView.snp.makeConstraints {
            $0.top.equalTo(self.explainLabel.snp.bottom).offset(Metric.textViewTop)
            $0.leading.equalToSafeArea(self.view).offset(Metric.viewSide)
            $0.trailing.equalToSafeArea(self.view).offset(-Metric.viewSide)
            $0.height.equalTo(self.view.frame.height / 4)
        }
        
        self.answerLabel.snp.makeConstraints {
            $0.top.equalTo(self.explainTextView.snp.bottom).offset(Metric.labelTop)
            $0.leading.equalToSafeArea(self.view).offset(Metric.viewSide)
            $0.trailing.equalToSafeArea(self.view).offset(-Metric.viewSide)
        }
        
        self.answerTextView.snp.makeConstraints {
            $0.top.equalTo(self.answerLabel.snp.bottom).offset(Metric.textViewTop)
            $0.leading.equalToSafeArea(self.view).offset(Metric.viewSide)
            $0.trailing.equalToSafeArea(self.view).offset(-Metric.viewSide)
            $0.height.equalTo(self.view.frame.height / 4)
        }
        
        self.noAnswerLabel.snp.makeConstraints {
            $0.top.equalTo(self.answerTextView)
            $0.centerX.equalToSuperview()
        }
        
        self.noAnswerImage.snp.makeConstraints {
            $0.top.equalTo(self.answerLabel.snp.bottom).offset(Metric.imageTop)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(Metric.imageHeight)
            $0.width.equalTo(Metric.imageWidth)
        }
        
        self.resendButton.snp.makeConstraints {
            $0.bottom.left.right.equalToSafeArea(self.view)
        }

    }
    
    override func setupStyle() {
        super.setupStyle()
        
        self.title = "문의내용"
    }
    
    // MARK: - Configuring
    func bind(reactor: Reactor) {
        self.resendButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
        
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
                self.resendButton.isHidden = $0
                self.noAnswerLabel.isHidden = !$0
                self.noAnswerImage.isHidden = !$0
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
        DetailMessageViewController(reactor: DetailMessageViewReactor(title: "test", content: "test", answer: "")).toPreview()
    }
}
#endif
