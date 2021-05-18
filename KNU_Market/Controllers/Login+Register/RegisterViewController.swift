import UIKit

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var sendEmailVerificationButton: UIButton!
    @IBOutlet weak var nicknameTextField: UITextField!
    @IBOutlet weak var checkAlreadyInUseButton: UIButton!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var checkPasswordTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    
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
            
            profileImageView.image = originalImage
            profileImageView.contentMode = .scaleAspectFit
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
        initializeImageView()
        initializeNextButton()
        
    }
    
    func initializeDelegates() {
        
        emailTextField.delegate = self
        nicknameTextField.delegate = self
        passwordTextField.delegate = self
        checkPasswordTextField.delegate = self
    }
    
    func initializeImageView() {

        profileImageView.isUserInteractionEnabled = true
        profileImageView.contentMode = .scaleAspectFit
        profileImageView.layer.masksToBounds = true
        profileImageView.layer.borderWidth = 1
        profileImageView.layer.borderColor = UIColor.lightGray.cgColor
  
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
