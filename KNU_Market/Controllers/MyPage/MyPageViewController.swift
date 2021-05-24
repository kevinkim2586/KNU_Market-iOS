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

        viewModel.loadUserProfile()
        initialize()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        viewModel.loadUserProfile()
    }
    
    @IBAction func pressedProfileImageButton(_ sender: UIButton) {
        
        initializeImagePicker()
        present(self.imagePicker, animated: true, completion: nil)
    }
    
    
    @IBAction func pressedLogOutButton(_ sender: UIButton) {
        
        UserManager.shared.logOut { result in
            
            switch result {
            
            case .success(_):
                
                self.presentAlertWithCancelAction(title: "로그아웃 하시겠습니까?", message: "") { selectedOk in
                    
                    if selectedOk {
                        
                        DispatchQueue.main.async {
                            self.popToInitialViewController()
                        }
                        
                    } else { return }
                }
            case .failure(let error):
                self.presentSimpleAlert(title: "네트워크 오류", message: error.errorDescription)
            }
        }
    }
    
    func popToInitialViewController() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let initialNavController = storyboard.instantiateViewController(identifier: Constants.StoryboardID.initialNavigationController)
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(initialNavController)
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
        updateProfileImageButton(with: viewModel.profileImage)
        showToast(message: "프로필 이미지 변경 성공")
    }
    
    func failedLoadingUserProfileInfo(with error: NetworkError) {
        self.presentSimpleAlert(title: "에러 발생", message: error.errorDescription)
    }
    
    func failedUpdatingUserProfileToServer(with error: NetworkError) {
        
        self.presentSimpleAlert(title: "업로드 오류", message: error.errorDescription)
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
                            
                            
                            self.viewModel.updateUserProfileToServer(with: originalImage)
        
                        
                            dismissProgressBar()
                            
                            
                        }
              
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
