import UIKit

class MyPageViewController: UIViewController {
    
    @IBOutlet weak var profileImageButton: UIButton!
    @IBOutlet weak var userNicknameLabel: UILabel!
    @IBOutlet weak var sendDeveloperMessageButton: UIButton!
    @IBOutlet weak var logOutButton: UIButton!
    
    lazy var imagePicker = UIImagePickerController()
    
    private var viewModel: MyPageViewModel = MyPageViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        loadUserProfile()
        initialize()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadUserProfile()
    }
    
    func loadUserProfile() {
        
        viewModel.loadUserProfile()
    }
    
//    func loadUserProfile() {
//
//        UserManager.shared.loadUserProfile { result in
//
//            switch result {
//            case .success(let model):
//
//                DispatchQueue.main.async {
//                    self.userNicknameLabel.text = model.nickname
//                }
//                OperationQueue().addOperation {
//                    self.fetchProfileImage(with: model.profileImage)
//                }
//            case .failure(let error):
//                self.presentSimpleAlert(title: "에러 발생", message: error.errorDescription)
//            }
//        }
//    }
    
//    func fetchProfileImage(with urlString: String) {
//
//        UserManager.shared.requestMedia(from: urlString) { result in
//
//            switch result {
//            case .success(let imageData):
//
//                if let imageData = imageData {
//
//                    let profileImage = UIImage(data: imageData) ?? UIImage(named: "pick_profile_picture")!
//
//                    DispatchQueue.main.async {
//                        self.profileImageButton.setImage(profileImage, for: .normal)
//                    }
//                }
//            case .failure(_):
//                self.showToast(message: "프로필 사진 가져오기 실패", font: .systemFont(ofSize: 12.0))
//
//            }
//        }
//    }
    
    
    @IBAction func pressedProfileImageButton(_ sender: UIButton) {
        
        initializeImagePicker()
        present(self.imagePicker, animated: true, completion: nil)
    }
    
    func updateUserProfileToServer(with image: UIImage) {
        
        UserManager.shared.updateUserProfileInfo(with: image) { isSuccess in
            
        
        }
    }
    

}

//MARK: - MyPageViewModelDelegate

extension MyPageViewController: MyPageViewModelDelegate {
    
    func didLoadUserProfileInfo() {
        userNicknameLabel.text = viewModel.userNickname
    }
    
    func didFetchProfileImage() {
        profileImageButton.setImage(viewModel.profileImage, for: .normal)
    }
    
    func didUpdateUserProfileToServer() {
        
    }
    
    func failedLoadingUserProfileInfo(with error: NetworkError) {
        self.presentSimpleAlert(title: "에러 발생", message: error.errorDescription)
    }
    
    func failedUpdatingUserProfileToServer(with error: NetworkError) {
        
    }
    
    func showToastMessage(with message: String) {
        showToast(message: message)
    }
    
    
    
}

//MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate

extension MyPageViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let originalImage: UIImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            
            dismiss(animated: true) {
                
                self.presentAlertWithCancelAction(title: "프로필 사진 변경", message: "선택하신 이미지로 프로필 사진을 변경하시겠습니까?") { selectedOk in
                    
                    if selectedOk {
            
                        self.updateProfileImageButton(with: originalImage)
                        
                        showProgressBar()
                        
                        OperationQueue().addOperation {
                            
                            self.updateUserProfileToServer(with: originalImage)
                        
                         
                            
                        }
                      
                        
                        dismissProgressBar()
                        
        
                    } else {
                        self.imagePickerControllerDidCancel(self.imagePicker)
                    }
                }
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    

}


//MARK: - UI Configuration

extension MyPageViewController {
    
    func initialize() {
        
        viewModel.delegate = self
        
        initializeProfileImageButton()
        initializeImagePicker()
    }
    
    func initializeProfileImageButton() {
        
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
    
    func updateProfileImageButton(with image: UIImage) {
        
        profileImageButton.setImage(image, for: .normal)
        profileImageButton.contentMode = .scaleAspectFit
        profileImageButton.layer.borderWidth = 1
        profileImageButton.layer.borderColor = UIColor.lightGray.cgColor
    }
    
}
