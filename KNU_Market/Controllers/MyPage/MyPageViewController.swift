import UIKit

class MyPageViewController: UIViewController {
    
    @IBOutlet weak var profileImageButton: UIButton!
    @IBOutlet weak var userNicknameLabel: UILabel!
    @IBOutlet weak var sendDeveloperMessageButton: UIButton!
    @IBOutlet weak var logOutButton: UIButton!
    
    lazy var imagePicker = UIImagePickerController()
    var profileImageExists: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

   
        loadUserProfile()
        initialize()
        
    }

    func loadUserProfile() {
        
        UserManager.shared.loadUserProfile { result in
            
            switch result {
            case .success(let model):
                
                DispatchQueue.main.async {
                    self.userNicknameLabel.text = model.nickname
                }
                OperationQueue().addOperation {
                    self.fetchProfileImage(with: model.profileImage)
                }
        
            case .failure(let error):
                self.presentSimpleAlert(title: "에러 발생", message: error.errorDescription)
            }
        }
    }
    
    func fetchProfileImage(with urlString: String) {
        
        UserManager.shared.requestMedia(from: urlString) { result in
            
            switch result {
            case .success(let imageData):
                
                if let imageData = imageData {
                    
                    let profileImage = UIImage(data: imageData) ?? UIImage(named: "pick_profile_picture")!
                    
                    DispatchQueue.main.async {
                        self.profileImageButton.setImage(profileImage, for: .normal)
                    }
                }
            case .failure(let error):
                self.presentSimpleAlert(title: "에러 발생", message: error.errorDescription)
            }
        }
    }
    
    
    @IBAction func pressedProfileImageButton(_ sender: UIButton) {
        
        initializeImagePicker()
        present(self.imagePicker, animated: true, completion: nil)
    }
    
 


}


//MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate

extension MyPageViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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

extension MyPageViewController {
    
    func initialize() {
        
        initializeImageView()
        initializeImagePicker()
    }
    
    func initializeImageView() {
        
        profileImageButton.isUserInteractionEnabled = true
        profileImageButton.contentMode = .scaleAspectFit
        profileImageButton.layer.masksToBounds = true
        profileImageButton.layer.cornerRadius = profileImageButton.frame.height / 2
    }
    
    func initializeImagePicker() {
        
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
    }
    
}
