import UIKit
import TextFieldEffects

class CaptureStudentIDViewController: UIViewController {
    
    @IBOutlet var titleLabels: [UILabel]!
    @IBOutlet weak var studentIDTextField: HoshiTextField!
    @IBOutlet weak var studentBirthDateTextField: HoshiTextField!
    @IBOutlet weak var captureDetailLabel: UILabel!
    @IBOutlet weak var captureView: UIView!
    @IBOutlet weak var addImageButton: UIButton!
    @IBOutlet weak var checkDuplicateButton: UIButton!
    @IBOutlet weak var studentIdImageView: UIImageView!
    
    private lazy var imagePicker = UIImagePickerController()
    
    private var didCheckDuplicate: Bool = true
    
    private var studentIdImageData: Data?
    private let alertMessage: String = "첨부하신 학생증은 입력하신 정보 (학번, 생년월일)와의 대조를 위해서만 사용되며, 크누마켓은 절대 이를 원본으로 수집하지 않습니다.\n입력된 정보와 학생증 내의 정보가 일치하지 않을 시, 크누마켓 이용이 제한됩니다."
    
    typealias VerifyError = ValidationError.OnVerification
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }


    @IBAction func pressedCheckDuplicateButton(_ sender: UIButton) {
        view.endEditing(true)
        #warning("구현 필요")
    }
    
    @IBAction func pressedAddImageButton(_ sender: UIButton) {
        presentAlertWithCancelAction(
            title: "안내드립니다",
            message: alertMessage
        ) { selectedOk in
            self.present(self.imagePicker, animated: true)
        }
    }
    
    @IBAction func pressedNextButton(_ sender: UIButton) {
        view.endEditing(true)
        
        if !didCheckDuplicate {
            showSimpleBottomAlert(with: VerifyError.didNotCheckStudentIdDuplication.rawValue)
            return
        }
        if !validateUserInput() { return }
        verifyUserUsingStudentId()
    }
    
    private func verifyUserUsingStudentId() {
        showProgressBar()
        let model = StudentIdVerificationDTO(
            studentId: studentIDTextField.text!,
            studentBirth: studentBirthDateTextField.text!,
            studentIdImageData: studentIdImageData!
        )
        
        UserManager.shared.uploadStudentIdVerificationInformation(with: model) { [weak self] result in
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

extension CaptureStudentIDViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
    
    func updateStudentIdImageView(with newImage: UIImage) {
        studentIdImageView.image = newImage
        studentIdImageData = newImage.jpegData(compressionQuality: 0.9)
    }
}

//MARK: - User Input Validation

extension CaptureStudentIDViewController {
    
    func validateUserInput() -> Bool {
        
        guard let _ = studentIDTextField.text else {
            showSimpleBottomAlert(with: VerifyError.emptyStudentId.rawValue)
            return false
        }
        
        guard didCheckDuplicate != false else {
            showSimpleBottomAlert(with: VerifyError.didNotCheckStudentIdDuplication.rawValue)
            return false
        }
        
        guard let birthDate = studentBirthDateTextField.text else {
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

//MARK: - UITextFieldDelegate

extension CaptureStudentIDViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == studentIDTextField {
            didCheckDuplicate = true
        }
    }
}

//MARK: - UI Configuration & Initialization

extension CaptureStudentIDViewController {
    
    func initialize() {
        title = "모바일 학생증 인증"
        initializeTextFields()
        initializeTitleLabels()
        initializeCaptureDetailLabel()
        initializeCheckDuplicateButton()
        initializeCaptureView()
        initializeStudentIdImageView()
        initializeImagePicker()
    }
    
    func initializeTextFields() {
        studentIDTextField.delegate = self
    }
    
    func initializeTitleLabels() {
        titleLabels.forEach { label in
            label.font = .systemFont(ofSize: 19, weight: .semibold)
            label.textColor = UIColor(named: K.Color.appColor)
        }
    }
    
    
    func initializeCaptureDetailLabel() {
        captureDetailLabel.text = "반드시 학번, 생년월일이 보이게 캡쳐해주세요.\n(다른 부분은 가리셔도 됩니다.)"
        captureDetailLabel.font = .systemFont(ofSize: 16, weight: .medium)
        
    }
    
    func initializeCheckDuplicateButton() {
        checkDuplicateButton.layer.cornerRadius = 6
    }
    
    func initializeCaptureView() {
        captureView.layer.borderWidth = 0.5
        captureView.layer.borderColor = UIColor.lightGray.cgColor
        captureView.layer.cornerRadius = 6
    }
    
    func initializeStudentIdImageView() {
        studentIdImageView.image = UIImage(named: K.Images.chatBubbleIcon)
        studentIdImageView.contentMode = .scaleAspectFit
        studentIdImageView.layer.borderWidth = 0.5
        studentIdImageView.layer.borderColor = UIColor.lightGray.cgColor
        studentIdImageView.layer.cornerRadius = 6
    }
    
    func initializeImagePicker() {
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .savedPhotosAlbum
    }
    
    
}
