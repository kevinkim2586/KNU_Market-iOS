import UIKit

class UnregisterUser_CheckFirstPrecautionsViewController: UIViewController {
    
    private let titleLabel      = KMTitleLabel(fontSize: 19, textColor: UIColor(named: K.Color.appColor) ?? .systemPink)
    private let detailLabel     = KMDetailLabel(fontSize: 16, numberOfTotalLines: 10)
    private let bottomButton    = KMBottomButton(buttonTitle: "확인했습니다.")
    
    private let padding: CGFloat = 20
    
    private let precautionText          = "현재 참가 중인 공동구매가 존재합니다.\n\n참가 중인 구성원들과 협의를 모두 마친 후 회원 탈퇴를 부탁드립니다.\n\n\n\n협의가 되지 않은 상태에서의 회원탈퇴로 인해 발생하는 문제에 대해서 크누마켓은 책임지지 않습니다."
    private let precautionTextToChange  = "협의를 모두 마친 후"

    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
}

//MARK: - Target Methods

extension UnregisterUser_CheckFirstPrecautionsViewController {
    
    @objc func pressedBottomButton() {
        navigationController?.pushViewController(UnregisterUser_CheckSecondPrecautionsViewController(), animated: true)
    }
}

//MARK: - UI Configuration

extension UnregisterUser_CheckFirstPrecautionsViewController {
    
    private func initialize() {
        view.backgroundColor = .white
        setBackBarButtonItemTitle()
        initializeTitleLabel()
        initializeDetailLabel()
        initializeBottomButton()
    }
    
    private func initializeTitleLabel() {
        view.addSubview(titleLabel)
        titleLabel.text = "확인하셨나요?"
        
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
struct UnRegister1: PreviewProvider {
    
    static var previews: some View {
        UnregisterUser_CheckFirstPrecautionsViewController().toPreview()
    }
}
#endif
