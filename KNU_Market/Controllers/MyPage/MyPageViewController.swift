import UIKit
import SPIndicator
import SnackBar_swift

class MyPageViewController: UIViewController {
    
    @IBOutlet weak var profileImageButton: UIButton!
    @IBOutlet weak var userNicknameLabel: UILabel!
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
}

//MARK: - profile image modification methods

extension MyPageViewController {
    
    @IBAction func pressedProfileImageButton(_ sender: UIButton) {
        
        presentActionSheet()
    }
    
    func presentActionSheet() {
        
        let alert = UIAlertController(title: "프로필 사진 변경",
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
        
        UserManager.shared.updateUserProfileImage(with: "default") { [weak self] result in

            guard let self = self else { return }

            switch result {

            case .success(_):
                SnackBar.make(in: self.view,
                              message: "프로필 사진 제거 성공 🎉",
                              duration: .lengthLong).show()
                DispatchQueue.main.async {
                    self.initializeProfileImageButton()
                    User.shared.profileImage = nil
                }
            case .failure(_):
                SnackBar.make(in: self.view,
                              message: "프로필 이미지 제거에 실패하였습니다. 다시 시도해주세요 🥲",
                              duration: .lengthLong).show()
            }
        }
    }
}

//MARK: - MyPageViewModelDelegate

extension MyPageViewController: MyPageViewModelDelegate {

    func didLoadUserProfileInfo() {
        userNicknameLabel.text = "\(viewModel.userNickname)"
    }
    
    func didFetchProfileImage() {
        
        profileImageButton.setImage(viewModel.profileImage, for: .normal)
        profileImageButton.layer.masksToBounds = true
    }
    
    func failedLoadingUserProfileInfo(with error: NetworkError) {
        SnackBar.make(in: self.view,
                      message: "프로필 정보 가져오기 실패. 잠시 후 다시 시도해주세요🥲",
                      duration: .lengthLong).show()
        print("failedLoadingUserProfileInfo with error: \(error.errorDescription)")
    }

    //이미지 먼저 서버에 업로드
    func didUploadImageToServerFirst(with uid: String) {
        viewModel.updateUserProfileImage(with: uid)
    }
    
    func failedUploadingImageToServerFirst(with error: NetworkError) {
        SnackBar.make(in: self.view,
                      message: "이미지 업로드 실패. 잠시 후 다시 시도해주세요🥲",
                      duration: .lengthLong).show()
        print("failedUploadingImageToServerFirst with error: \(error.errorDescription)")
    }
    
    // 프로필 사진 실제 DB상 수정
    func didUpdateUserProfileImage() {
        viewModel.loadUserProfile()
        SnackBar.make(in: self.view,
                      message: "프로필 이미지 변경 성공 🎉",
                      duration: .lengthLong).show()
    }
    
    func failedUpdatingUserProfileImage(with error: NetworkError) {
        SnackBar.make(in: self.view,
                      message: "프로필 사진 변경 실패. 잠시 후 다시 시도해주세요🥲",
                      duration: .lengthLong).show()
        print("failedUpdatingUserProfileImage with error: \(error.errorDescription)")
    }
    
    func showErrorMessage(with message: String) {
        SnackBar.make(in: self.view,
                      message: message,
                      duration: .lengthLong).show()
    }
}

//MARK: - UITableViewDelegate, UITableViewDataSource

extension MyPageViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.tableViewOptions.count
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
        case 3:
            cell.textLabel?.text = viewModel.tableViewOptions[indexPath.row]
        case 4:
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
        
        self.navigationController?.view.backgroundColor = .white
        
        initializeTableView()
        initializeProfileImageButton()
        initializeImagePicker()
    }
    
    func initializeTableView() {
        
        settingsTableView.delegate = self
        settingsTableView.dataSource = self
    }
    
    func initializeProfileImageButton() {
        
        profileImageButton.setImage(#imageLiteral(resourceName: "pick profile image"), for: .normal)
        profileImageButton.layer.masksToBounds = false
        profileImageButton.isUserInteractionEnabled = true
        profileImageButton.contentMode = .scaleAspectFit
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
        profileImageButton.layer.masksToBounds = true

    }
    
}
