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
    
    private lazy var imagePicker = UIImagePickerController()
    
    private var didCheckDuplicate: Bool = false
    
    private var imageData: Data?
    private let alertMessage: String = "학생증 사진은 입력하신 내용(학번, 생년월일)과 대조를 위해서만 사용되며, 절대 수집하지 않습니다. 입력하신 내용과 학생증 사진이 일치하지 않을 시, 제재 대상이 될 수 있음을 알려드립니다."
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }

    @IBAction func pressedCheckDuplicateButton(_ sender: UIButton) {
        
        view.endEditing(true)
        if !validateUserInput() { return }
        
        
        
    }
    
    @IBAction func pressedAddImageButton(_ sender: UIButton) {
        
        presentAlertWithCancelAction(title: "주의사항",
                                     message: alertMessage) { selectedOk in
            
            if selectedOk {
                self.present(self.imagePicker, animated: true)
            }
        }
        
        
    }
    
    @IBAction func pressedNextButton(_ sender: UIButton) {
        
        view.endEditing(true)
        
        
    }
}

//MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate

extension CaptureStudentIDViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let originalImage: UIImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            
            dismiss(animated: true) {
                
                
            }
            
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

//MARK: - User Input Validation

extension CaptureStudentIDViewController {
    
    func validateUserInput() -> Bool {
        
        guard let _ = studentIDTextField.text else {
            showSimpleBottomAlert(with: "학번을 입력해주세요.")
            return false
        }
        
        guard didCheckDuplicate != false else {
            showSimpleBottomAlert(with: "학번 중복 체크를 해주세요.")
            return false
        }
        
        guard let birthDate = studentBirthDateTextField.text else {
            showSimpleBottomAlert(with: "생년월일을 입력해주세요.")
            return false
        }
        
        guard birthDate.count == 6 else {
            showSimpleBottomAlert(with: "생년월일 6자리를 입력해주세요.")
            return false
        }
        
        guard imageData != nil else {
            showSimpleBottomAlert(with: "모바일 학생증 캡쳐본을 첨부해주세요.")
            return false
        }
        
        return true
        
    }
}

//MARK: - UI Configuration & Initialization

extension CaptureStudentIDViewController {
    
    func initialize() {
        
        title = "모바일 학생증 인증"
        initializeTitleLabels()
        initializeCaptureDetailLabel()
        initializeCheckDuplicateButton()
        initializeCaptureView()
        initializeImagePicker()
        
        
    }
    
    func initializeTitleLabels() {
        
        titleLabels.forEach { label in
            
            label.font = .systemFont(ofSize: 25, weight: .semibold)
            label.textColor = UIColor(named: Constants.Color.appColor)
        }
        
    }
    
    
    func initializeCaptureDetailLabel() {
        
        captureDetailLabel.text = "반드시 학번, 생년월일이 보이게 캡쳐해주세요.\n(다른 부분은 가리셔도 됩니다.)"
        captureDetailLabel.font = .systemFont(ofSize: 16, weight: .medium)
        
    }
    
    func initializeCheckDuplicateButton() {
            
        checkDuplicateButton.layer.cornerRadius = checkDuplicateButton.frame.height / 2
        
    }
    
    func initializeCaptureView() {
        
        captureView.layer.borderWidth = 0.5
        captureView.layer.borderColor = UIColor.lightGray.cgColor
        captureView.layer.cornerRadius = 5
    }
    
    func initializeImagePicker() {
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .savedPhotosAlbum
        
    }
}
