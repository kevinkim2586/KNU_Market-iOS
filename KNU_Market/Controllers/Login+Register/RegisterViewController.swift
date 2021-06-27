import UIKit
import ProgressHUD
import SnackBar_swift

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var profileImageButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var emailFormatTextField: UITextField!
    @IBOutlet weak var nicknameTextField: UITextField!
    @IBOutlet weak var checkAlreadyInUseButton: UIButton!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var checkPasswordTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet var textFieldCollections: [UITextField]!
    

    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var checkPasswordLabel: UILabel!
    
    lazy var imagePicker = UIImagePickerController()
    
    var didCheckNicknameDuplicate: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialize()
    }
    
    @IBAction func pressedImageUploadButton(_ sender: UIButton) {
        
        presentActionSheet()
        present(self.imagePicker, animated: true, completion: nil)
    }
    
    func presentActionSheet() {
        
        let alert = UIAlertController(title: "프로필 사진 선택",
                                      message: "",
                                      preferredStyle: .actionSheet)
        let library = UIAlertAction(title: "앨범에서 선택",
                                    style: .default) { _ in
            
            self.initializeImagePicker()
            self.present(self.imagePicker, animated: true)
        }
        let remove = UIAlertAction(title: "프로필 사진 제거",
                                   style: .default) { _ in
            
            self.initializeProfileImageButton()
            
        }
        let cancel = UIAlertAction(title: "취소",
                                   style: .cancel,
                                   handler: nil)
        
        alert.addAction(library)
        alert.addAction(remove)
        alert.addAction(cancel)
        
        present(alert, animated: true, completion: nil)
    }

    
    @IBAction func pressedCheckDuplicateButton(_ sender: UIButton) {
        
        guard let nickname = nicknameTextField.text else { return }
        guard nickname.count > 0 else { return }
        
        nicknameTextField.resignFirstResponder()
        
        UserManager.shared.checkDuplicate(nickname: nickname) { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
            case .success(let isDuplicate):
                
                if isDuplicate {
                    
                    SnackBar.make(in: self.view,
                                  message: "이미 사용 중인 닉네임입니다 😅",
                                  duration: .lengthLong).show()
                    
                    DispatchQueue.main.async {
                        self.nicknameTextField.layer.borderColor = UIColor(named: Constants.Color.appColor)?.cgColor
                    }

                    
                    
                } else {
                    
                    SnackBar.make(in: self.view,
                                  message: "사용하셔도 좋습니다 🎉",
                                  duration: .lengthLong).show()
    
                    DispatchQueue.main.async {
                        self.nicknameTextField.layer.borderColor = UIColor(named: Constants.Color.borderColor)?.cgColor
                        self.didCheckNicknameDuplicate = true
                    }
                    
                }
               
            case .failure(let error):
                SnackBar.make(in: self.view,
                              message: "에러 발생: \(error.errorDescription) 🥲",
                              duration: .lengthLong).show()
            }
        }
    }
    
    @IBAction func pressedNextButton(_ sender: UIButton) {
        
        //TODO - 이메일 인증을 했는지 확인하는 로직도 있어야함. 없으면 알림
        
        if !checkIfBlankTextFieldsExists() ||
            !checkNicknameLength() ||
            !checkPasswordLength() ||
            !checkIfPasswordFieldsAreIdentical() ||
            !checkNicknameDuplicate() {
            return
        }
        
        showProgressBar()

        let id = emailTextField.text! + "@knu.ac.kr"
        let nickname = nicknameTextField.text!
        let password = passwordTextField.text!
        var profileImageData: Data? = nil
        
        if let image = profileImageButton.currentImage {
            profileImageData = image.jpegData(compressionQuality: 1.0)
        }
        
        let registerModel = RegisterModel(id: id,
                                          password: password,
                                          nickname: nickname,
                                          image: profileImageData)
        
        UserManager.shared.register(with: registerModel) { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
            case .success(let isSuccess):
                print("Register View Controller - Register Successful: \(isSuccess)")
                
                SnackBar.make(in: self.view,
                              message: "회원가입을 축하합니다! 🎉",
                              duration: .lengthLong).show()
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5) {
                    
                    self.dismiss(animated: true)
                    
                }
            
            case .failure(let error):
                
                SnackBar.make(in: self.view,
                              message: "일시적인 네트워크 문제. 잠시 후 다시 시도해주세요 🤔",
                              duration: .lengthLong).show()
                print("Register View Controller - Register FAILED with error: \(error.errorDescription)")
                
            }
            dismissProgressBar()
        }
    }
    
    func checkIfBlankTextFieldsExists() -> Bool {
        
        guard let email = emailTextField.text,
              let nickname = nicknameTextField.text,
              let pw = passwordTextField.text,
              let pwCheck = checkPasswordTextField.text else {
            SnackBar.make(in: self.view,
                          message: "빈 칸이 없는지 확인해주세요 🤔",
                          duration: .lengthLong).show()
            return false
        }
        
        guard !email.isEmpty,
              !nickname.isEmpty,
              !pw.isEmpty,
              !pwCheck.isEmpty else {
            SnackBar.make(in: self.view,
                          message: "빈 칸이 없는지 확인해주세요 🤔",
                          duration: .lengthLong).show()
            return false
        }
        return true
    }
    
//    func checkEmailFormat() -> Bool {
//
//        guard let email = emailTextField.text else { return false }
//
//        guard email.contains("@knu.ac.kr") else {
//            SnackBar.make(in: self.view,
//                          message: "학교 이메일을 기입하셨는지 확인하시기 바랍니다 🤔",
//                          duration: .lengthLong).show()
//            emailTextField.layer.borderColor = UIColor(named: Constants.Color.appColor)?.cgColor
//            return false
//        }
//        return true
//    }
    
    func checkNicknameDuplicate() -> Bool {
        
        if !didCheckNicknameDuplicate {
            SnackBar.make(in: self.view,
                          message: "닉네임 중복 확인을 해주세요 👀",
                          duration: .lengthLong).show()
            return false
        }
        else { return true }
    }
    
    func checkNicknameLength() -> Bool {
        
        guard let nickname = nicknameTextField.text else { return false }
        
        if nickname.count >= 2 && nickname.count <= 15 { return true }
        else {
            SnackBar.make(in: self.view,
                          message: "닉네임은 2글자 이상, 15자리 이하로 입력해주세요 👀",
                          duration: .lengthLong).show()
            return false
        }
    }
    
    func checkPasswordLength() -> Bool {
        
        guard let password = passwordTextField.text else { return false }
        
        if password.count >= 8 && password.count <= 15 { return true }
        else {
            SnackBar.make(in: self.view,
                          message: "비밀번호는 8자리 이상, 15자리 이하로 입력해주세요 🤔",
                          duration: .lengthLong).show()
            passwordTextField.layer.borderColor = UIColor(named: Constants.Color.appColor)?.cgColor
            passwordTextField.text?.removeAll()
            checkPasswordTextField.text?.removeAll()
            return false
            
        }
    }
    
    func checkIfPasswordFieldsAreIdentical() -> Bool {
        
        if passwordTextField.text == checkPasswordTextField.text { return true }
        else {
            SnackBar.make(in: self.view,
                          message: "비밀번호가 일치하지 않습니다 🤔",
                          duration: .lengthLong).show()
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
            didCheckNicknameDuplicate = false
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
            profileImageButton.layer.masksToBounds = true
//            profileImageButton.layer.borderWidth = 1
//            profileImageButton.layer.borderColor = UIColor.lightGray.cgColor
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
        initializeLabels()
        initializeTextFields()
        initializeProfileImageButton()

        initializeNextButton()
        
    }
    
    func initializeDelegates() {
        
        emailTextField.delegate = self
        nicknameTextField.delegate = self
        passwordTextField.delegate = self
        checkPasswordTextField.delegate = self
    }
    
    func initializeLabels() {
        
        nicknameLabel.changeTextAttributes(fullText: nicknameLabel.text!, changeText: "*")
        emailLabel.changeTextAttributes(fullText: emailLabel.text!, changeText: "*")
        passwordLabel.changeTextAttributes(fullText: passwordLabel.text!, changeText: "*")
        checkPasswordLabel.changeTextAttributes(fullText: checkPasswordLabel.text!, changeText: "*")
    }
    
    func initializeTextFields() {
        
        for textField in textFieldCollections {
     
            textField.layer.cornerRadius = textField.frame.height / 2
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

        profileImageButton.setImage(#imageLiteral(resourceName: "pick profile image"), for: .normal)
        profileImageButton.layer.masksToBounds = false
        profileImageButton.isUserInteractionEnabled = true
        profileImageButton.contentMode = .scaleAspectFit
        profileImageButton.layer.cornerRadius = profileImageButton.frame.height / 2
    }
    
    func initializeNextButton() {
        
        nextButton.layer.cornerRadius = nextButton.frame.height / 2
        nextButton.backgroundColor = UIColor(named: Constants.Color.appColor)
    }
    
    func initializeImagePicker() {
        
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
    }
    
}
