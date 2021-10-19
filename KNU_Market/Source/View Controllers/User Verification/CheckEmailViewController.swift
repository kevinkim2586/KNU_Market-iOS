import UIKit

class CheckEmailViewController: UIViewController {

    private let titleLabel      = KMTitleLabel(textColor: .darkGray)
    private let detailLabel     = KMDetailLabel(numberOfTotalLines: 2)
    private let bottomButton    = KMBottomButton(buttonTitle: "홈으로 돌아가기")

    var email: String?
    
    private let padding: CGFloat = 20
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
}

//MARK: - Target Methods

extension CheckEmailViewController {
    
    @objc func pressedGoBackToHomeButton() {
        popVCsFromNavController(count: 3)
    }
}

//MARK: - UI Configuration & Initialization

extension CheckEmailViewController {
    
    func initialize() {
        view.backgroundColor = .white
        title = "웹메일 인증"
        initializeTitleLabel()
        initializeDetailLabel()
        initializeBottomButton()
    }
    
    func initializeTitleLabel() {
        guard let email = email else { return }
        view.addSubview(titleLabel)
        titleLabel.numberOfLines = 2
        titleLabel.text = "\(email)\n위의 메일로 인증 메일이 전송되었습니다."
        titleLabel.changeTextAttributeColor(
            fullText: titleLabel.text!,
            changeText: email
        )
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding)
        ])
    }
    
    func initializeDetailLabel() {
        view.addSubview(detailLabel)
        detailLabel.text = "✻ 메일이 보이지 않는 경우 반드시 스팸함을 확인해주세요!"
        detailLabel.changeTextAttributeColor(
            fullText: detailLabel.text!,
            changeText: "반드시 스팸함을 확인"
        )
        
        NSLayoutConstraint.activate([
            detailLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 25),
            detailLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            detailLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding)
        ])
    }
    
    func initializeBottomButton() {
        view.addSubview(bottomButton)
        
        bottomButton.addTarget(
            self,
            action: #selector(pressedGoBackToHomeButton),
            for: .touchUpInside
        )
        bottomButton.updateTitleEdgeInsetsForKeyboardHidden()
        
        NSLayoutConstraint.activate([
            bottomButton.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomButton.heightAnchor.constraint(equalToConstant: bottomButton.heightConstantForKeyboardHidden)
        ])
    }
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI

@available(iOS 13.0, *)
struct VCPreview: PreviewProvider {
    
    static var previews: some View {
        UIStoryboard(name: "VerifyEmail", bundle: nil).instantiateViewController(identifier: "CheckEmailViewController").toPreview()
    }
}
#endif
