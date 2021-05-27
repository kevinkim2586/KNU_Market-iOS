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
    
    var didCheckNicknameDuplicate: Bool = false

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
        
        UserManager.shared.checkDuplicate(nickname: nickname) { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
            case .success(let isNotDuplicate):
                
                if isNotDuplicate {
    
                    DispatchQueue.main.async {
                        self.nicknameTextField.layer.borderColor = UIColor(named: Constants.Color.borderColor)?.cgColor
                        self.checkAlreadyInUseButton.setTitle("사용하셔도 좋습니다 👍", for: .normal)
                        self.didCheckNicknameDuplicate = true
                    }
                    
                    
                } else {
                    
                    DispatchQueue.main.async {
                        self.nicknameTextField.layer.borderColor = UIColor(named: Constants.Color.appColor)?.cgColor
                        self.checkAlreadyInUseButton.setTitle("이미 사용 중인 닉네임입니다 😅", for: .normal)
                    }
                    
                }
               
            case .failure(let error):
                self.showErrorCard(title: "에러 발생", message: error.errorDescription)
            }
        }
    }
    
    @IBAction func pressedNextButton(_ sender: UIButton) {
        
        //TODO - 이메일 인증을 했는지 확인하는 로직도 있어야함. 없으면 알림
        
        if !checkIfBlankTextFieldsExists() || !checkEmailFormat() || !checkNicknameLength() || !checkPasswordLength() || !checkPasswordLength() || !checkNicknameDuplicate() {
            return
        }
        
        showProgressBar()

        let id = emailTextField.text!
        let password = passwordTextField.text!
        let nickname = nicknameTextField.text!
        var profileImageData: Data? = nil
        
        if let image = profileImageButton.currentImage {
            profileImageData = image.jpegData(compressionQuality: 1.0)
        }
        
        let registerModel = RegisterModel(id: id, password: password, nickname: nickname, image: profileImageData)
        
        UserManager.shared.register(with: registerModel) { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
            case .success(let isSuccess):
                print("Register View Controller - Register Successful: \(isSuccess)")
                
                self.showToast(message: "회원가입을 축하합니다! 새로 로그인해주세요.")
                self.showSuccessCard(title: "회원가입 성공!", message: "회원가입을 축하합니다!", iconText: "🎉")
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5) {
                    
                    self.dismiss(animated: true)
                    
                }
            
            case .failure(let error):
                self.showErrorCard(title: "에러 발생", message: "일시적인 오류입니다. 나중에 다시 시도해주세요")
                print("Register View Controller - Register FAILED with error: \(error.localizedDescription)")
                
            }
            dismissProgressBar()
        }
    }
    
    func checkIfBlankTextFieldsExists() -> Bool {
        
        guard let email = emailTextField.text,
              let nickname = nicknameTextField.text,
              let pw = passwordTextField.text,
              let pwCheck = checkPasswordTextField.text else {
            self.showWarningCard(title: "입력 오류", message: "빈 칸이 없는지 확인해주세요")
            return false
        }
        
        guard !email.isEmpty, !nickname.isEmpty, !pw.isEmpty, !pwCheck.isEmpty else {
            self.showWarningCard(title: "입력 오류", message: "빈 칸이 없는지 확인해주세요")
            return false
        }
        return true
    }
    
    func checkEmailFormat() -> Bool {
        
        guard let email = emailTextField.text else { return false }
        
        guard email.contains("@knu.ac.kr") else {
            self.showWarningCard(title: "경북대학교 이메일로 가입하셔야 합니다", message: "학교 이메일을 기입하셨는지 확인하시기 바랍니다")
            emailTextField.layer.borderColor = UIColor(named: Constants.Color.appColor)?.cgColor
            return false
        }
        return true
    }
    
    func checkNicknameDuplicate() -> Bool {
        
        if !didCheckNicknameDuplicate { return false}
        else { return true }
    }
    
    func checkNicknameLength() -> Bool {
        
        guard let nickname = nicknameTextField.text else { return false }
        
        if nickname.count >= 2 && nickname.count <= 10 { return true }
        else {
            self.showWarningCard(title: "닉네임을 다시 입력해주세요", message: "닉네임은 2글자 이상, 10자리 이하로 입력해주세요")
            return false
        }
    }
    
    func checkPasswordLength() -> Bool {
        
        guard let password = passwordTextField.text else { return false }
        
        if password.count >= 8 && password.count <= 15 { return true }
        else {
            self.showWarningCard(title: "비밀번호 오류", message: "비밀번호는 8자리 이상, 15자리 이하로 입력해주세요")
            passwordTextField.layer.borderColor = UIColor(named: Constants.Color.appColor)?.cgColor
            passwordTextField.text?.removeAll()
            checkPasswordTextField.text?.removeAll()
            return false
            
        }
    }
    
    func checkIfPasswordFieldsAreIdentical() -> Bool {
        
        if passwordTextField.text == checkPasswordTextField.text { return true }
        else {
            self.showWarningCard(title: "비밀번호가 일치하지 않습니다", message: "다시 입력해주세요")
            checkPasswordTextField.text?.removeAll()
            passwordTextField.becomeFirstResponder()
            return false
        }
    }
    
    // 아래 함수 필요없으니 없애는거 검토
    
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
     
            textField.layer.cornerRadius = 1
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
