import UIKit

class UnregisterUser_CheckSecondPrecautionsViewController: UIViewController {
    
    private let titleLabel      = KMTitleLabel(fontSize: 19, textColor: UIColor(named: K.Color.appColor) ?? .systemPink)
    private let detailLabel     = KMDetailLabel(fontSize: 16, numberOfTotalLines: 10)
    private let bottomButton    = KMBottomButton(buttonTitle: "확인했습니다.")
    
    private let padding: CGFloat = 20
    
    private let precautionText          = "회원탈퇴를 하실 경우\n\n1. 참가 중인 공구 채팅방 자동으로 나가기\n\n2. 개설한 공구글 자동으로 삭제\n\n위 두 과정이 진행되며,\n\n다시 복구할 수 없음을 알려드립니다."
    private let precautionTextToChange  = "다시 복구할 수 없음을 알려드립니다."
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
}

//MARK: - Target Methods

extension UnregisterUser_CheckSecondPrecautionsViewController {
    
    @objc func pressedBottomButton() {
        navigationController?.pushViewController(UnregisterUser_InputPasswordViewController(), animated: true)
    }
}

//MARK: - UI Configuration

extension UnregisterUser_CheckSecondPrecautionsViewController {
    
    private func initialize() {
        view.backgroundColor = .white
        initializeTitleLabel()
        initializeDetailLabel()
        initializeBottomButton()
    }
    
    private func initializeTitleLabel() {
        view.addSubview(titleLabel)
        titleLabel.text = "회원탈퇴 안내"
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding)
        ])
    }
    
    private func initializeDetailLabel() {
        view.addSubview(detailLabel)
        detailLabel.text = precautionText
        detailLabel.textColor = .darkGray
        detailLabel.changeTextAttributeColor(
            fullText: precautionText,
            changeText: precautionTextToChange
        )
    
        NSLayoutConstraint.activate([
            detailLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            detailLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            detailLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding)
        ])
    }
    
    private func initializeBottomButton() {
        view.addSubview(bottomButton)
        bottomButton.addTarget(
            self,
            action: #selector(pressedBottomButton),
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
struct UnRegister2: PreviewProvider {
    
    static var previews: some View {
        UnregisterUser_CheckSecondPrecautionsViewController().toPreview()
    }
}
#endif
