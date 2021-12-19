import UIKit
import TextFieldEffects
import SnapKit

class CaptureStudentIdViewController: BaseViewController {
    
    //MARK: - Properties
    
    private var userManager: UserManager?
    
    private var didCheckDuplicate: Bool = false
    private var studentIdImageData: Data?
    
    typealias VerifyError = ValidationError.OnVerification
    
    //MARK: - Constants
    
    fileprivate struct Metrics {
        static let labelSidePadding: CGFloat    = 30
        static let textFieldHeight: CGFloat     = 60
    }
    
    fileprivate struct Fonts {
        static let titleLabels       = UIFont.systemFont(ofSize: 19, weight: .semibold)
    }
    
    fileprivate struct Images {
        static let plusImage        = UIImage(systemName: "plus")?.withRenderingMode(.alwaysOriginal).withTintColor(.black)
    }
    
    fileprivate struct Texts {
        static let alertMessage     = "첨부하신 학생증은 입력하신 정보 (학번, 생년월일)와의 대조를 위해서만 사용되며, 크누마켓은 절대 이를 원본으로 수집하지 않습니다.\n입력된 정보와 학생증 내의 정보가 일치하지 않을 시, 크누마켓 이용이 제한됩니다."
    }
    
    //MARK: - UI
    
    let studentIdLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.titleLabels
        label.textColor = UIColor(named: K.Color.appColor)
        label.text = "학번"
        return label
    }()
    
    lazy var studentIdTextField: KMTextField = {
        let textField = KMTextField(placeHolderText: "학번을 입력해주세요.")
        textField.delegate = self
        return textField
    }()
    
    let checkDuplicateButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 6
        button.setTitle("중복 확인", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        button.backgroundColor = UIColor(named: K.Color.appColor)
        button.addTarget(
            self,
            action: #selector(pressedCheckDuplicateButton),
            for: .touchUpInside
        )
        button.addBounceAnimation()
        return button
    }()
    
    let birthDateLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.titleLabels
        label.textColor = UIColor(named: K.Color.appColor)
        label.text = "생년월일"
        
        return label
    }()
    
    let birthDateTextField: KMTextField = {
        let textField = KMTextField(placeHolderText: "생년월일 6자리 (예:981121)")
        return textField
    }()
    
    let captureLabel: UILabel = {
        let label = UILabel()
        label.font = Fonts.titleLabels
        label.textColor = UIColor(named: K.Color.appColor)
        label.text = "모바일 학생증 캡쳐"
        
        return label
    }()
    
    let captureGuideLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16,weight: .medium)
        label.textColor = .black
        label.text = "반드시 학번, 생년월일이 보이게 캡쳐해주세요."
        return label
    }()
    
    let selectImageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(Images.plusImage, for: .normal)
        button.widthAnchor.constraint(equalToConstant: 90).isActive = true
        button.heightAnchor.constraint(equalToConstant: 90).isActive = true
        button.addTarget(
            self,
            action: #selector(pressedSelectImageButton),
            for: .touchUpInside
        )
        button.layer.borderWidth = 0.5
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.cornerRadius = 6
        return button
    }()
    
    let studentIdImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: K.Images.chatBubbleIcon)
        imageView.widthAnchor.constraint(equalToConstant: 90).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 90).isActive = true
        imageView.contentMode = .scaleAspectFit
        imageView.layer.borderWidth = 0.5
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        imageView.layer.cornerRadius = 6
        imageView.clipsToBounds = true
        return imageView
    }()
    
    lazy var captureStudentIdStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalCentering
        stackView.spacing = 60
        [selectImageButton, studentIdImageView].forEach { stackView.addArrangedSubview($0) }
        return stackView
    }()
    
    lazy var captureStudentIdView: UIView = {
        let view = UIView()
        view.layer.borderWidth = 0.5
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.cornerRadius = 6
        view.addSubview(captureStudentIdStackView)
        captureStudentIdStackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        return view
    }()
    
    let bottomButton: KMBottomButton = {
        let button = KMBottomButton(buttonTitle: "인증 완료하기")
        button.heightAnchor.constraint(equalToConstant: button.heightConstantForKeyboardHidden).isActive = true
        button.setTitle("인증 완료하기", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.addTarget(
            self,
            action: #selector(pressedBottomButton),
            for: .touchUpInside
        )
        return button
    }()
    
    lazy var imagePicker: UIImagePickerController = {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .savedPhotosAlbum
        return imagePicker
    }()
    
    //MARK: - Initialization
    init(userManager: UserManager) {
        super.init()
        self.userManager = userManager
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        studentIdTextField.becomeFirstResponder()
    }
    
    //MARK: - UI Setup
    override func setupLayout() {
        super.setupLayout()
        
        view.addSubview(studentIdLabel)
        view.addSubview(studentIdTextField)
        view.addSubview(checkDuplicateButton)
        view.addSubview(birthDateLabel)
        view.addSubview(birthDateTextField)
        view.addSubview(captureLabel)
        view.addSubview(captureGuideLabel)
        view.addSubview(captureStudentIdView)
        view.addSubview(bottomButton)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        studentIdLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(35)
            make.left.equalTo(view.snp.left).offset(Metrics.labelSidePadding)
            make.right.equalTo(view.snp.right).offset(-Metrics.labelSidePadding)
        }
        
        checkDuplicateButton.snp.makeConstraints { make in
            make.width.equalTo(80)
            make.right.equalTo(view.snp.right).offset(-Metrics.labelSidePadding)
            make.top.equalTo(studentIdLabel.snp.bottom).offset(35)
        }
        
        studentIdTextField.snp.makeConstraints { make in
            make.top.equalTo(studentIdLabel.snp.bottom).offset(6)
            make.left.equalTo(view.snp.left).offset(Metrics.labelSidePadding)
            make.height.equalTo(Metrics.textFieldHeight)
        }
        
        birthDateLabel.snp.makeConstraints { make in
            make.top.equalTo(studentIdTextField.snp.bottom).offset(20)
            make.left.equalTo(view.snp.left).offset(Metrics.labelSidePadding)
            make.right.equalTo(view.snp.right).offset(-Metrics.labelSidePadding)
        }
        
        birthDateTextField.snp.makeConstraints { make in
            make.top.equalTo(birthDateLabel.snp.bottom).offset(6)
            make.left.equalTo(view.snp.left).offset(Metrics.labelSidePadding)
            make.height.equalTo(Metrics.textFieldHeight)
        }
        
        captureLabel.snp.makeConstraints { make in
            make.top.equalTo(birthDateTextField.snp.bottom).offset(20)
            make.left.equalTo(view.snp.left).offset(Metrics.labelSidePadding)
            make.right.equalTo(view.snp.right).offset(-Metrics.labelSidePadding)
        }
        
        captureGuideLabel.snp.makeConstraints { make in
            make.top.equalTo(captureLabel.snp.bottom).offset(10)
            make.left.equalTo(view.snp.left).offset(Metrics.labelSidePadding)
            make.right.equalTo(view.snp.right).offset(-Metrics.labelSidePadding)
        }

        bottomButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.left.equalTo(view.snp.left)
            make.right.equalTo(view.snp.right)
            make.height.equalTo(bottomButton.heightConstantForKeyboardHidden)
        }
        
        captureStudentIdView.snp.makeConstraints { make in
            make.top.equalTo(captureGuideLabel.snp.bottom).offset(15)
            make.left.equalTo(view.snp.left).offset(Metrics.labelSidePadding)
            make.right.equalTo(view.snp.right).offset(-Metrics.labelSidePadding)
            make.bottom.equalTo(bottomButton.snp.top).offset(-20)
        }
        
    }
    
    override func setupStyle() {
        super.setupStyle()
        view.backgroundColor = .white
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
    private func configure() {
        title = "모바일 학생증 인증"
    }
    

}


//MARK: - Target Methods

extension CaptureStudentIdViewController {
    
    @objc private func pressedSelectImageButton() {
        presentAlertWithCancelAction(
            title: "안내드립니다",
            message: Texts.alertMessage
        ) { selectedOk in
            if selectedOk { self.present(self.imagePicker, animated: true) }
        }
    }
    
    @objc private func pressedBottomButton() {
        view.endEditing(true)
        
        if !didCheckDuplicate {
            showSimpleBottomAlert(with: VerifyError.didNotCheckStudentIdDuplication.rawValue)
            return
        }
        if !validateUserInput() { return }
        verifyUserUsingStudentId()
    }
    
    @objc private func pressedCheckDuplicateButton() {
        view.endEditing(true)
        guard let studentId = studentIdTextField.text, studentId.count > 5 else {
            showSimpleBottomAlert(with: VerifyError.emptyStudentId.rawValue)
            return
        }
        
        userManager?.checkDuplication(studentId: studentId) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let isDuplicate):
                if isDuplicate {
                    self.showSimpleBottomAlert(with: VerifyError.duplicateStudentId.rawValue)
                    self.didCheckDuplicate = false
                } else {
                    DispatchQueue.main.async {
                        self.showSimpleBottomAlert(with: "사용하셔도 좋습니다🎉")
                        self.didCheckDuplicate = true
                    }
                }
            case .failure(_):
                self.showSimpleBottomAlert(with: NetworkError.E000.rawValue)
            }
        }
    }
    
    private func verifyUserUsingStudentId() {
        showProgressBar()
        let model = StudentIdVerificationDTO(
            studentId: studentIdTextField.text!,
            studentBirth: birthDateTextField.text!,
            studentIdImageData: studentIdImageData!
        )
        
        userManager?.uploadStudentIdVerificationInformation(with: model) { [weak self] result in
            guard let self = self else { return }
            dismissProgressBar()
            switch result {
            case .success(_):
                self.showSimpleBottomAlertWithAction(
                    message: "인증 완료되었습니다😁",
                    buttonTitle: "홈으로"
                ) {
                    if let vcPopCount = self.navigationController?.viewControllers.count {
                        self.popVCsFromNavController(count: vcPopCount - 1)
                    }
                }
            case .failure(let error):
                self.showSimpleBottomAlert(with: error.errorDescription)
            }
        }
    }
}

//MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate

extension CaptureStudentIdViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let originalImage: UIImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            dismiss(animated: true) {
                self.updateStudentIdImageView(with: originalImage)
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    private func updateStudentIdImageView(with newImage: UIImage) {
        studentIdImageView.image = newImage
        studentIdImageData = newImage.jpegData(compressionQuality: 0.9)
    }
}

//MARK: - UITextFieldDelegate

extension CaptureStudentIdViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == studentIdTextField {
            didCheckDuplicate = false
        }
    }
}

//MARK: - User Input Validation

extension CaptureStudentIdViewController {
    
    func validateUserInput() -> Bool {
        guard let _ = studentIdTextField.text else {
            showSimpleBottomAlert(with: VerifyError.emptyStudentId.rawValue)
            return false
        }
        guard didCheckDuplicate != false else {
            showSimpleBottomAlert(with: VerifyError.didNotCheckStudentIdDuplication.rawValue)
            return false
        }
        
        guard let birthDate = birthDateTextField.text else {
            showSimpleBottomAlert(with: VerifyError.emptyBirthDate.rawValue)
            return false
        }
        guard birthDate.count == 6 else {
            showSimpleBottomAlert(with: VerifyError.incorrectBirthDateLength.rawValue)
            return false
        }
        guard studentIdImageData != nil else {
            showSimpleBottomAlert(with: VerifyError.didNotChooseStudentIdImage.rawValue)
            return false
        }
        return true
    }
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI

@available(iOS 13.0, *)
struct CaptureStudentIdVC: PreviewProvider {
    
    static var previews: some View {
        CaptureStudentIdViewController(userManager: UserManager()).toPreview()
    }
}
#endif
