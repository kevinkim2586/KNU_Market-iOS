import UIKit
import Photos
import SDWebImage

class MyPageViewController: UIViewController {
    
    @IBOutlet weak var profileImageButton: UIButton!
    @IBOutlet weak var userNicknameLabel: UILabel!
    @IBOutlet weak var userVerifiedImage: UIImageView!
    @IBOutlet weak var settingsTableView: UITableView!
    @IBOutlet weak var settingsBarButtonItem: UIBarButtonItem!
    
    lazy var imagePicker = UIImagePickerController()
    
    private var viewModel = MyPageViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.loadUserProfile()
        initialize()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.post(name: .getBadgeValue, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        viewModel.loadUserProfile()
    }
    
    
    @IBAction func pressedSettingsBarButtonItem(_ sender: UIBarButtonItem) {
        
        guard let vc = self.storyboard?.instantiateViewController(identifier: K.StoryboardID.settingsVC) as? SettingsViewController
        else { fatalError() }
        pushViewController(with: vc)
    }
}

//MARK: - profile image modification methods

extension MyPageViewController {
    
    @IBAction func pressedProfileImageButton(_ sender: UIButton) {
        presentActionSheet()
    }
    
    func presentActionSheet() {
        
        let alert = UIAlertController(
            title: "프로필 사진 변경",
            message: "",
            preferredStyle: .actionSheet
        )
        let library = UIAlertAction(
            title: "앨범에서 선택",
            style: .default
        ) { [weak self] _ in
            self?.initializeImagePicker()
        }
        let remove = UIAlertAction(
            title: "프로필 사진 제거",
            style: .default
        ) { [weak self] _ in
            self?.presentAlertWithCancelAction(
                title: "프로필 사진 제거",
                message: "정말로 제거하시겠습니까?"
            ) { selectedOk in
                
                if selectedOk { self?.removeProfileImage() }
                else { return }
            }
        }
        let cancel = UIAlertAction(
            title: "취소",
            style: .cancel,
            handler: nil
        )
        
        alert.addAction(library)
        alert.addAction(remove)
        alert.addAction(cancel)
        
        present(alert, animated: true, completion: nil)
    }
    
    func removeProfileImage() {
        
        UserManager.shared.updateUserInfo(
            type: .profileImage,
            infoString: "default"
        ) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(_):
                self.showSimpleBottomAlert(with: "프로필 사진 제거 성공 🎉")
                DispatchQueue.main.async {
                    self.initializeProfileImageButton()
                    User.shared.profileImage = nil
                }
            case .failure(_):
                self.showSimpleBottomAlert(with: "프로필 이미지 제거에 실패하였습니다. 다시 시도해주세요 🥲")
            }
        }
    }
}

//MARK: - MyPageViewModelDelegate

extension MyPageViewController: MyPageViewModelDelegate {
    
    func didLoadUserProfileInfo() {
        userNicknameLabel.text = "\(viewModel.userNickname)\n(\(viewModel.userId))"
        userVerifiedImage.isHidden = detectIfVerifiedUser() ? false : true
    }
    
    func didFetchProfileImage() {
        if viewModel.profileImage != nil {
            profileImageButton.setImage(
                viewModel.profileImage,
                for: .normal
            )
            profileImageButton.layer.masksToBounds = true
        } else {
            profileImageButton.setImage(UIImage(named: K.Images.pickProfileImage),
                                        for: .normal)
            profileImageButton.layer.masksToBounds = false
        }
    }
    
    func failedLoadingUserProfileInfo(with error: NetworkError) {
        self.showSimpleBottomAlert(with: "프로필 정보 가져오기 실패. 로그아웃 후 다시 시도해주세요.")
        userNicknameLabel.text = "닉네임 불러오기 실패"
    }
    
    //이미지 먼저 서버에 업로드
    func didUploadImageToServerFirst(with uid: String) {
        viewModel.updateUserProfileImage(with: uid)
    }
    
    func failedUploadingImageToServerFirst(with error: NetworkError) {
        self.showSimpleBottomAlert(with: error.errorDescription)
        initializeProfileImageButton()
    }
    
    // 프로필 사진 실제 DB상 수정
    func didUpdateUserProfileImage() {
        viewModel.loadUserProfile()
        self.showSimpleBottomAlert(with: "프로필 이미지 변경 성공 🎉")
    }
    
    func failedUpdatingUserProfileImage(with error: NetworkError) {
        self.showSimpleBottomAlert(with: error.errorDescription)
    }
    
    func showErrorMessage(with message: String) {
        self.showSimpleBottomAlert(with: message)
    }
}

//MARK: - UITableViewDelegate, UITableViewDataSource

extension MyPageViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 0:
            return viewModel.tableViewSection_1.count
        case 1:
            return viewModel.tableViewSection_2.count
        default:
            return 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "사용자 설정"
        case 1: return "기타"
        default: break
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 25))
        view.backgroundColor = .white
        
        let label = UILabel(frame: CGRect(x: 16, y: 5, width: tableView.frame.width, height: 20))
        
        switch section {
        case 0: label.text = "사용자 설정"
        case 1: label.text = "기타"
        default: break
        }
        
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textAlignment = .left
        label.textColor = .darkGray
        view.addSubview(label)
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: K.cellID.myPageCell,
            for: indexPath
        ) as! MyPageTableViewCell
        
        cell.leftImageView.tintColor = .black
        
        switch indexPath.section {
        case 0:
            cell.settingsTitleLabel.text = viewModel.tableViewSection_1[indexPath.row]
            cell.leftImageView.image = UIImage(systemName: K.Images.myPageSection_1_Images[indexPath.row])
        case 1:
            cell.settingsTitleLabel.text = viewModel.tableViewSection_2[indexPath.row]
            cell.leftImageView.image = UIImage(systemName: K.Images.myPageSection_2_Images[indexPath.row])
        default: break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.section {
        case 0:
            guard let vc = self.storyboard?.instantiateViewController(
                identifier: K.StoryboardID.myPageSection_1_Options[indexPath.row]
            ) else { return }
            pushViewController(with: vc)
        case 1:
            switch indexPath.row {
            case 1:
                let url = URL(string: K.URL.termsAndConditionNotionURL)!
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            case 2:
                let url = URL(string: K.URL.privacyInfoConditionNotionURL)!
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            default:
                guard let vc = self.storyboard?.instantiateViewController(identifier: K.StoryboardID.myPageSection_2_Options[indexPath.row]) else { return }
                pushViewController(with: vc)
            }
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
                self.presentAlertWithCancelAction(
                    title: "프로필 사진 변경",
                    message: "선택하신 이미지로 프로필 사진을 변경하시겠습니까?"
                ) { selectedOk in
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
        createObserversForPresentingVerificationAlert()
        createObserversForGettingBadgeValue()
        
        viewModel.delegate = self
        
        userVerifiedImage.isHidden = true
        initializeTabBarIcon()
        initializeTableView()
        initializeBarButtonItem()
        initializeProfileImageButton()
        setBackBarButtonItemTitle()
        setNavigationBarAppearance(to: .white)
    }
    
    func initializeTabBarIcon() {
        navigationController?.tabBarItem.image = UIImage(named: K.Images.myPageUnselected)?.withRenderingMode(.alwaysTemplate)
        navigationController?.tabBarItem.selectedImage = UIImage(named: K.Images.myPageSelected)?.withRenderingMode(.alwaysTemplate)
    }
    
    func initializeTableView() {
        settingsTableView.delegate = self
        settingsTableView.dataSource = self
        settingsTableView.separatorStyle = .none
        settingsTableView.separatorColor = .lightGray
    }
    
    func initializeBarButtonItem() {
        
        if #available(iOS 14.0, *) {
            settingsBarButtonItem.image = UIImage(systemName: "gearshape")
        } else {
            settingsBarButtonItem.image = UIImage(systemName: "gear")
        }
    }
    
    func initializeProfileImageButton() {
        profileImageButton.setImage(UIImage(named: K.Images.pickProfileImage), for: .normal)
        profileImageButton.layer.masksToBounds = false
        profileImageButton.isUserInteractionEnabled = true
        profileImageButton.contentMode = .scaleAspectFit
        profileImageButton.layer.cornerRadius = profileImageButton.frame.height / 2
    }
    
    func initializeImagePicker() {
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .savedPhotosAlbum
        self.present(self.imagePicker, animated: true)
    }
    
    func updateProfileImageButton(with image: UIImage) {
        profileImageButton.setImage(image, for: .normal)
        profileImageButton.contentMode = .scaleAspectFit
        profileImageButton.layer.masksToBounds = true
    }
    
    
}
