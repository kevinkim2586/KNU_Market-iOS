import UIKit
import TextFieldEffects

class ProfilePictureInputViewController: UIViewController {
    
    @IBOutlet weak var profileImageButton: UIButton!
    @IBOutlet weak var cameraButton: UIImageView!
    @IBOutlet weak var firstLineLabel: UILabel!
    @IBOutlet weak var secondLineLabel: UILabel!
    
    @IBOutlet weak var skipButton: UIButton!
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var nextButtonBottomAnchor: NSLayoutConstraint!
    @IBOutlet weak var nextButtonHeight: NSLayoutConstraint!
    
    lazy var imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    @IBAction func pressedNextButton(_ sender: UIButton) {
        performSegue(withIdentifier: Constants.SegueID.goToEmailInputVC, sender: self)
    }
    
    @IBAction func pressedSkipButton(_ sender: UIButton) {
        UserRegisterValues.shared.profileImage = nil
        performSegue(withIdentifier: Constants.SegueID.goToEmailInputVC, sender: self)
    }
}

//MARK: - UI Configuration & Initialization

extension ProfilePictureInputViewController {

    func initialize() {
        
        initializeLabels()
        initializeProfileImageButton()
        initializeImagePicker()
        
    }

    func initializeLabels() {
        
        firstLineLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        firstLineLabel.textColor = .darkGray
        secondLineLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        secondLineLabel.textColor = .darkGray
        
        firstLineLabel.text = "\(UserRegisterValues.shared.nickname)님 만의"
        firstLineLabel.changeTextAttributeColor(fullText: firstLineLabel.text!, changeText: "\(UserRegisterValues.shared.nickname)님")
        secondLineLabel.text = "프로필 사진도 선택해 주세요!"
        secondLineLabel.changeTextAttributeColor(fullText: secondLineLabel.text!, changeText: "프로필 사진")
    }
    
    func initializeProfileImageButton() {
        
        UserRegisterValues.shared.profileImage = nil
        profileImageButton.addTarget(self, action: #selector(presentActionSheet), for: .touchUpInside)
        profileImageButton.setImage(#imageLiteral(resourceName: "pick profile image"), for: .normal)
        profileImageButton.layer.masksToBounds = false
        profileImageButton.isUserInteractionEnabled = true
        profileImageButton.contentMode = .scaleAspectFit
    }
    
    func updateProfileImageButton(with image: UIImage) {
        
        profileImageButton.layer.cornerRadius = profileImageButton.frame.height / 2
        profileImageButton.setImage(image, for: .normal)
        profileImageButton.contentMode = .scaleAspectFit
        profileImageButton.layer.masksToBounds = true
        UserRegisterValues.shared.profileImage = image.jpegData(compressionQuality: 0.6)
    }
    
    func initializeImagePicker() {
        
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
    }
    
    @objc func presentActionSheet() {
        
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
            
            self.presentAlertWithCancelAction(title: "프로필 사진 제거",
                                              message: "정말로 제거하시겠습니까?") { selectedOk in
                
                if selectedOk { self.removeProfileImage() }
                else { return }
            }
        }
        let cancel = UIAlertAction(title: "취소",
                                   style: .cancel,
                                   handler: nil)
        
        alert.addAction(library)
        alert.addAction(remove)
        alert.addAction(cancel)
        
        present(alert, animated: true, completion: nil)
    }
    
    func removeProfileImage() {
        self.initializeProfileImageButton()
    }
}

//MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate

extension ProfilePictureInputViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let originalImage: UIImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            dismiss(animated: true) {
                self.updateProfileImageButton(with: originalImage)
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
