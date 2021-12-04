import UIKit
import Photos
import SnapKit

class MyPageViewController: BaseViewController {
    
    //MARK: - Properties
    
    var viewModel: MyPageViewModel!
    

    //MARK: - Constants
    
    fileprivate struct Metrics {
        static let profileImageButtonHeight: CGFloat = 120
    }
    
    fileprivate struct Images {
        static let userVerifiedImage = UIImage(systemName: "checkmark.circle.fill")?.withRenderingMode(.alwaysOriginal)
            .withTintColor(UIColor(named: K.Color.appColor) ?? .systemPink)
        
        static let userUnVerifiedImage = UIImage(systemName: "xmark.circle.fill")?.withRenderingMode(.alwaysOriginal)
            .withTintColor(UIColor.systemGray)
    }
    
    //MARK: - UI
    
    lazy var profileImageContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    let profileImageButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: K.Images.pickProfileImage), for: .normal)
        button.layer.masksToBounds = false
        button.isUserInteractionEnabled = true
        button.contentMode = .scaleAspectFit
        button.widthAnchor.constraint(equalToConstant: Metrics.profileImageButtonHeight).isActive = true
        button.heightAnchor.constraint(equalToConstant: Metrics.profileImageButtonHeight).isActive = true
        button.layer.cornerRadius = Metrics.profileImageButtonHeight / 2
        button.addTarget(self, action: #selector(pressedProfileImageButton(_:)), for: .touchUpInside)
        return button
    }()
    
    let cameraIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: K.Images.cameraIcon)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let userNicknameLabel: UILabel = {
        let label = UILabel()
        label.text = "로딩 중.."
        label.numberOfLines = 2
        label.minimumScaleFactor = 0.8
        label.adjustsFontSizeToFitWidth = true
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    let userVerifiedImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    lazy var settingsTableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(
            MyPageTableViewCell.self,
            forCellReuseIdentifier: MyPageTableViewCell.cellId
        )
        return tableView
    }()
    
    // UIBarButtonItems
    
    lazy var myPageBarButtonItem: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.title = "마이페이지"
        button.style = .done
        button.tintColor = .black
        return button
    }()
    
    lazy var settingsBarButtonItem: UIBarButtonItem = {
        let button = UIBarButtonItem()
        if #available(iOS 14.0, *) {
            button.image = UIImage(systemName: "gearshape")
        } else {
            button.image = UIImage(systemName: "gear")
        }
        button.style = .plain
        button.target = self
        button.action = #selector(pressedSettingsBarButtonItem)
        return button
    }()
    
    // UIImagePickerController
    
    lazy var imagePicker: UIImagePickerController = {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .savedPhotosAlbum
        return imagePicker
    }()
    
    
    //MARK: - Initialization
    init(viewModel: MyPageViewModel) {
        super.init()
        self.viewModel = viewModel
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        viewModel.loadUserProfile()
//        initialize()
    
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.post(name: .getBadgeValue, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        viewModel.loadUserProfile()
    }
    
    
    //MARK: - UI Setup
    override func setupLayout() {
        super.setupLayout()
        
        navigationItem.leftBarButtonItem = myPageBarButtonItem
        navigationItem.rightBarButtonItem = settingsBarButtonItem
        
        view.addSubview(profileImageContainerView)
        profileImageContainerView.addSubview(profileImageButton)
        profileImageContainerView.addSubview(cameraIcon)
        profileImageContainerView.addSubview(userNicknameLabel)
        profileImageContainerView.addSubview(userVerifiedImage)
        view.addSubview(settingsTableView)

    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        profileImageContainerView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(15)
            make.left.equalTo(view.snp.left).offset(50)
            make.right.equalTo(view.snp.right).offset(-50)
            make.height.equalTo(160)
        }
        
        profileImageButton.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        userNicknameLabel.snp.makeConstraints { make in
            make.top.equalTo(profileImageButton.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
        
        cameraIcon.snp.makeConstraints { make in
            make.width.height.equalTo(30)
            make.bottom.equalTo(userNicknameLabel.snp.top).offset(-10)
            make.right.equalTo(profileImageContainerView.snp.right).offset(-80)
        }
        
        userVerifiedImage.snp.makeConstraints { make in
            make.width.height.equalTo(20)
            make.left.equalTo(userNicknameLabel.snp.right).offset(4)
            make.bottom.equalTo(profileImageContainerView.snp.bottom).offset(5)
        }
        
        settingsTableView.snp.makeConstraints { make in
            make.top.equalTo(profileImageContainerView.snp.bottom).offset(6)
            make.left.equalTo(view.snp.left)
            make.right.equalTo(view.snp.right)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
    
        }
    }
    
    private func configure() {
        
        createObserversForPresentingVerificationAlert()
        createObserversForGettingBadgeValue()
        
        viewModel.delegate = self
    }

}

//MARK: - Target Methods

extension MyPageViewController {
    
    @objc private func pressedSettingsBarButtonItem() {
        pushViewController(with: AccountManagementViewController())
    }
    
}

//MARK: - profile image modification methods

extension MyPageViewController {
    
    @objc private func pressedProfileImageButton(_ sender: UIButton) {
        presentActionSheet()
    }
    
    func presentActionSheet() {
        
        let library = UIAlertAction(
            title: "앨범에서 선택",
            style: .default
        ) { [weak self] _ in
            guard let self = self else { return }
            self.present(self.imagePicker, animated: true)
        }
        let remove = UIAlertAction(
            title: "프로필 사진 제거",
            style: .default
        ) { [weak self] _ in
            self?.presentAlertWithCancelAction(
                title: "프로필 사진 제거",
                message: "정말로 제거하시겠습니까?"
            ) { selectedOk in
                
                if selectedOk { self?.viewModel.removeProfileImage() }
                else { return }
            }
        }

        let alert = UIHelper.createActionSheet(with: [library, remove], title: "프로필 사진 변경")
        present(alert, animated: true, completion: nil)
    }
    
}

//MARK: - MyPageViewModelDelegate

extension MyPageViewController: MyPageViewModelDelegate {
    
    func didLoadUserProfileInfo() {
        userNicknameLabel.text = "\(viewModel.userNickname)\n(\(viewModel.userId))"
        
        userVerifiedImage.image = detectIfVerifiedUser()
        ? Images.userVerifiedImage
        : Images.userUnVerifiedImage
        
        settingsTableView.reloadData()
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
    
    func didRemoveProfileImage() {
        showSimpleBottomAlert(with: "프로필 사진 제거 성공 🎉")
        initializeProfileImageButton()
        User.shared.profileImage = nil
        
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
        case 0: return viewModel.tableViewSection_1.count
        case 1: return viewModel.tableViewSection_2.count
        default: return 0
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
            withIdentifier: MyPageTableViewCell.cellId,
            for: indexPath
        ) as! MyPageTableViewCell
        
        cell.leftImageView.tintColor = .black
        
        switch indexPath.section {
        case 0:
            cell.settingsTitleLabel.text = viewModel.tableViewSection_1[indexPath.row]
            cell.leftImageView.image = UIImage(systemName: K.Images.myPageSection_1_Images[indexPath.row])
        case 1:
            cell.settingsTitleLabel.text = viewModel.tableViewSection_2[indexPath.row]
            if indexPath.row == 0 {
                cell.leftImageView.image = UIImage(named: K.Images.myPageSection_2_Images[indexPath.row])
                cell.notificationBadgeImageView.isHidden = viewModel.isReportChecked
            } else {
                cell.leftImageView.image = UIImage(systemName: K.Images.myPageSection_2_Images[indexPath.row])
            }
        default: break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0: pushViewController(with: MyPostsViewController(viewModel: PostListViewModel(postManager: PostManager(), chatManager: ChatManager(), userManager: UserManager(), popupManager: PopupManager())))
            case 1: pushViewController(with: AccountManagementViewController())
            case 2: pushViewController(with: VerifyOptionViewController())
            default: break
            }
        case 1:
            switch indexPath.row {
            case 0: pushViewController(with: SendUsMessageViewController(reactor: SendUsMessageReactor()))
            case 1:
                let url = URL(string: K.URL.termsAndConditionNotionURL)!
                presentSafariView(with: url)
            case 2:
                let url = URL(string: K.URL.privacyInfoConditionNotionURL)!
                presentSafariView(with: url)
            case 3: pushViewController(with: DeveloperInformationViewController())
            default: break
            }
        default: return
        }
    }
    
    func pushViewController(with vc: UIViewController) {
        vc.hidesBottomBarWhenPushed = true
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
        
        initializeTabBarIcon()
        initializeProfileImageButton()
        setBackBarButtonItemTitle()
        setNavigationBarAppearance(to: .white)
    }
    
    func initializeTabBarIcon() {
        navigationController?.tabBarItem.image = UIImage(named: K.Images.myPageUnselected)?.withRenderingMode(.alwaysTemplate)
        navigationController?.tabBarItem.selectedImage = UIImage(named: K.Images.myPageSelected)?.withRenderingMode(.alwaysTemplate)
    }
    

    
    func initializeProfileImageButton() {
        profileImageButton.setImage(UIImage(named: K.Images.pickProfileImage), for: .normal)
        profileImageButton.layer.masksToBounds = false
        profileImageButton.isUserInteractionEnabled = true
        profileImageButton.contentMode = .scaleAspectFit
        profileImageButton.layer.cornerRadius = profileImageButton.frame.height / 2
    }
    
    
    func updateProfileImageButton(with image: UIImage) {
        profileImageButton.setImage(image, for: .normal)
        profileImageButton.contentMode = .scaleAspectFit
        profileImageButton.layer.masksToBounds = true
    }
    
    
}
//#if canImport(SwiftUI) && DEBUG
//import SwiftUI
//
//@available(iOS 13.0, *)
//struct MyPageVC: PreviewProvider {
//
//    static var previews: some View {
//        MyPageViewController(userManager: UserManager()).toPreview()
//    }
//}
//#endif
