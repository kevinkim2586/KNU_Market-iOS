import UIKit
import ProgressHUD

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var profileImageButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var sendEmailVerificationButton: UIButton!
    @IBOutlet weak var nicknameTextField: UITextField!
    @IBOutlet weak var checkAlreadyInUseButton: UIButton!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var checkPasswordTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet var textFieldCollections: [UITextField]!
    
    lazy var imagePicker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialize()
    }
    
    @IBAction func pressedImageUploadButton(_ sender: UIButton) {
        
        initializeImagePicker()
        present(self.imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func pressedSendEmailVerificationButton(_ sender: UIButton) {
        
        
    }
    
    @IBAction func pressedCheckDuplicateButton(_ sender: UIButton) {
        
        guard let nickname = nicknameTextField.text else { return }
        guard nickname.count > 0 else { return }
        
        nicknameTextField.resignFirstResponder()
        
        UserManager.shared.checkDuplicate(nickname: nickname) { result in
            
            switch result {
            case .success(let isNotDuplicate):
                
                if isNotDuplicate {
    
                    self.nicknameTextField.layer.borderColor = UIColor(named: Constants.Color.borderColor)?.cgColor
                    self.checkAlreadyInUseButton.setTitle("사용하셔도 좋습니다 👍", for: .normal)
       
                } else {
        
                    self.nicknameTextField.layer.borderColor = UIColor(named: Constants.Color.appColor)?.cgColor
                    self.checkAlreadyInUseButton.setTitle("이미 사용 중인 닉네임입니다.", for: .normal)
                }
               
            case .failure(let error):
                self.presentSimpleAlert(title: "에러 발생", message: error.errorDescription)
            }
        }
    }
    
    @IBAction func pressedNextButton(_ sender: UIButton) {
        
        if !checkIfBlankTextFieldsExists() || !checkEmailFormat() || !checkIfPasswordFieldsAreIdentical() {
        
            return
        }
        
        showProgressBar()
        
        let registerModel = RegisterModel(id: "tahwan@gmail.com", password: "123456789", nickname: "굿굿", image: nil)
        UserManager.shared.register(with: registerModel) { result in
            
            switch result {
            case .success(let isSuccess):
                print(isSuccess)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        
        changeRootViewController()
        dismissProgressBar()
    }
    
    func checkIfBlankTextFieldsExists() -> Bool {
        
        guard let email = emailTextField.text,
              let nickname = nicknameTextField.text,
              let pw = passwordTextField.text,
              let pwCheck = checkPasswordTextField.text else {
            self.presentSimpleAlert(title: "입력 오류", message: "빈 칸이 없는지 확인해주세요.")
            return false
        }
        
        guard !email.isEmpty, !nickname.isEmpty, !pw.isEmpty, !pwCheck.isEmpty else {
            self.presentSimpleAlert(title: "입력 오류", message: "빈 칸이 없는지 확인해주세요.")
            return false
        }
    
        return true
    }
    
    func checkEmailFormat() -> Bool {
        
        guard let email = emailTextField.text else { return false }
        
        guard email.contains("@knu.ac.kr") else {
            self.presentSimpleAlert(title: "경북대학교 이메일로 가입하셔야 합니다.", message: "학교 이메일을 기입하셨는지 확인하시기 바랍니다.")
            emailTextField.layer.borderColor = UIColor(named: Constants.Color.appColor)?.cgColor
            return false
        }
        return true
    }
    
    func checkIfPasswordFieldsAreIdentical() -> Bool {
        
        if passwordTextField.text == checkPasswordTextField.text { return true }
        else {
            self.presentSimpleAlert(title: "비밀번호가 일치하지 않습니다.", message: "다시 입력해주세요.")
            checkPasswordTextField.text?.removeAll()
            passwordTextField.becomeFirstResponder()
            return false
        }
    }
    
    func changeRootViewController() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainTabBarController = storyboard.instantiateViewController(identifier: Constants.StoryboardID.tabBarController)
        
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainTabBarController)
    }
    
    
}

//MARK: - UITextFieldDelegate

extension RegisterViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField == nicknameTextField {
            checkAlreadyInUseButton.setTitle("중복 확인", for: .normal)
            checkAlreadyInUseButton.titleLabel?.tintColor = UIColor(named: Constants.Color.appColor)
        }
        textField.layer.borderColor = UIColor(named: Constants.Color.borderColor)?.cgColor
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
    
        if textField.text?.count == 0 {
            textField.layer.borderColor = UIColor(named: Constants.Color.appColor)?.cgColor
        }
    }
}

//MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate

extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let originalImage: UIImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            
            profileImageButton.setImage(originalImage, for: .normal)
            profileImageButton.contentMode = .scaleAspectFit
            profileImageButton.layer.borderWidth = 1
            profileImageButton.layer.borderColor = UIColor.lightGray.cgColor
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}


//MARK: - UI Configuration

extension RegisterViewController {
     
    func initialize() {
        
        initializeDelegates()
        initializeTextFields()
        initializeProfileImageButton()
        initializeEmailVerificationButton()
        initializeNextButton()
        
    }
    
    func initializeDelegates() {
        
        emailTextField.delegate = self
        nicknameTextField.delegate = self
        passwordTextField.delegate = self
        checkPasswordTextField.delegate = self
    }
    
    func initializeTextFields() {
        
        for textField in textFieldCollections {
     
            textField.layer.cornerRadius = 1  //textField.frame.height / 2
            textField.layer.borderWidth = 1
            textField.layer.borderColor = UIColor(named: Constants.Color.borderColor)?.cgColor
            
            textField.leftView = UIView(frame: CGRect(x: 0,
                                                      y: 0,
                                                      width: 15,
                                                      height: 15))
            textField.leftViewMode = .always
        }
        passwordTextField.isSecureTextEntry = true
        checkPasswordTextField.isSecureTextEntry = true
    }
    
    func initializeProfileImageButton() {

        profileImageButton.isUserInteractionEnabled = true
        profileImageButton.contentMode = .scaleAspectFit
        profileImageButton.layer.masksToBounds = true
        profileImageButton.layer.cornerRadius = profileImageButton.frame.height / 2
    }
    
    func initializeEmailVerificationButton() {
        
        sendEmailVerificationButton.setTitle("인증 메일 보내기", for: .normal)
        sendEmailVerificationButton.titleLabel?.font = UIFont.systemFont(ofSize: 17,
                                                                         weight: .semibold)
        sendEmailVerificationButton.backgroundColor = UIColor(named: Constants.Color.appColor)
        sendEmailVerificationButton.layer.cornerRadius  = sendEmailVerificationButton.frame.height / 2
        sendEmailVerificationButton.addBounceAnimationWithNoFeedback()
    }
    
    func initializeNextButton() {
        
        nextButton.layer.cornerRadius = nextButton.frame.width / 2
        nextButton.backgroundColor = UIColor(named: Constants.Colors.appDefaultColor)
        nextButton.setImage(UIImage(systemName: "arrow.right"),
                            for: .normal)
    }
    
    func initializeImagePicker() {
        
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
    }
    
}
