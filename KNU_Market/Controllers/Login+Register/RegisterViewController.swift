import UIKit

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
    
    //Target 으로 바꾸기
    @IBAction func pressedImageUploadButton(_ sender: UIButton) {
        initializeImagePicker()
        present(self.imagePicker, animated: true, completion: nil)
        
    }
    
    @IBAction func pressedSendEmailVerificationButton(_ sender: UIButton) {
        
    }
    
    @IBAction func pressedCheckDuplicateButton(_ sender: UIButton) {
        
        guard let nickname = nicknameTextField.text else { return }
        guard nickname.count > 0 else { return }
        
        UserManager.shared.checkDuplicate(nickname: nickname) { result in
            
            switch result {
            case .success(let isDuplicate):
                
                if isDuplicate {
                    
                } else {
                    
                }
                
            case .failure(let error):
                self.presentSimpleAlert(title: "에러 발생", message: error.errorDescription)
            }
        }
    }
    
    @IBAction func pressedNextButton(_ sender: UIButton) {
        
        
        let registerModel = RegisterModel(id: "tahwan@gmail.com", password: "123456789", nickname: "굿굿", image: nil)
        UserManager.shared.register(with: registerModel) { result in
            
            switch result {
            case .success(let isSuccess):
                print(isSuccess)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        
        
        
        
 
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainTabBarController = storyboard.instantiateViewController(identifier: Constants.StoryboardID.tabBarController)
        
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainTabBarController)
    }
    
    
    
}

//MARK: - UITextFieldDelegate

extension RegisterViewController: UITextFieldDelegate {
    
    
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
        sendEmailVerificationButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
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
