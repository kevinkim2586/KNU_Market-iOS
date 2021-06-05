import UIKit
import SPIndicator

class MyPageViewController: UIViewController {
    
    @IBOutlet weak var profileImageButton: UIButton!
    @IBOutlet weak var userNicknameLabel: UILabel!
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var settingsTableView: UITableView!
    
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
                    }
                }
            case .failure(let error):
                self.showErrorCard(title: "네트워크 오류", message: error.errorDescription)
            }
        }
    }
    
    // 아래 수정 필요
    func popToInitialViewController() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let initialVC = storyboard.instantiateViewController(identifier: Constants.StoryboardID.initialVC)
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(initialVC)
    }
}

//MARK: - MyPageViewModelDelegate

extension MyPageViewController: MyPageViewModelDelegate {

    func didLoadUserProfileInfo() {
        userNicknameLabel.text = "\(viewModel.userNickname)"
    }
    
    func didFetchProfileImage() {
        profileImageButton.setImage(viewModel.profileImage, for: .normal)
    }
    
    func failedLoadingUserProfileInfo(with error: NetworkError) {
        showWarningCard(title: "프로필 조회 실패", message: error.errorDescription)
    }

    //이미지 먼저 서버에 업로드
    func didUploadImageToServerFirst(with uid: String) {
        viewModel.updateUserProfileImage(with: uid)
    }
    
    func failedUploadingImageToServerFirst(with error: NetworkError) {
        showErrorCard(title: "이미지 업로드 실패", message: error.errorDescription)
    }
    
    // 프로필 사진 실제 DB상 수정
    func didUpdateUserProfileImage() {
        viewModel.loadUserProfile()
        showToast(message: "프로필 이미지 변경 성공")
        showSuccessCard(title: "성공", message: "프로필 이미지를 변경하였습니다", iconText: "😄")
    }
    
    func failedUpdatingUserProfileImage(with error: NetworkError) {
        showErrorCard(title: "업로드 실패", message: error.errorDescription)
    }
    
    func showToastMessage(with message: String) {
        showToast(message: message)
    }
}

//MARK: - UITableViewDelegate, UITableViewDataSource

extension MyPageViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellID.myPageCell, for: indexPath)
        
        cell.textLabel?.font = .systemFont(ofSize: 17)
        
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = viewModel.tableViewOptions[indexPath.row]
        case 1:
            cell.textLabel?.text = viewModel.tableViewOptions[indexPath.row]
        case 2:
            cell.textLabel?.text = viewModel.tableViewOptions[indexPath.row]
        default: break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
        case 0:
            guard let vc = self.storyboard?.instantiateViewController(identifier: Constants.StoryboardID.sendDeveloperMessageVC) else { return }
            pushViewController(with: vc)
        case 1:
            guard let vc = self.storyboard?.instantiateViewController(identifier: Constants.StoryboardID.settingsVC) else { return }
            pushViewController(with: vc)
        case 2:
            guard let vc = self.storyboard?.instantiateViewController(identifier: Constants.StoryboardID.termsAndConditionsVC) else { return }
            pushViewController(with: vc)
        default: return
        }
        
    }
    
    func pushViewController(with vc: UIViewController) {
        navigationController?.pushViewController(vc, animated: true)
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
                    
                            self.viewModel.uploadImageToServerFirst(with: originalImage)
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
        
        initializeTableView()
        initializeProfileImageButton()
        initializeImagePicker()
    }
    
    func initializeTableView() {
        
        settingsTableView.delegate = self
        settingsTableView.dataSource = self
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
