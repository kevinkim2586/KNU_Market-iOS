import UIKit
import PanModal
import SnapKit

class ChatMemberListViewController: BaseViewController {
    
    //MARK: - Properties
    
    private var roomInfo: RoomInfo?
    private var postUploaderUid: String?
    private var filteredMembers: [Member]?
    
    private var chatManager: ChatManager?
    
    //MARK: - Constants
    
    fileprivate struct Metrics {
        static let headerViewHeight: CGFloat        = 60
        static let chatMembersCellHeight: CGFloat   = 65
    }
    
    //MARK: - UI
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.text = "참여 중인 사용자"
        return label
    }()
    
    let personImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "people icon")
        return imageView
    }()
    
    let participatingMemberCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 15)
        return label
    }()
    
    lazy var exitButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(named: K.Color.appColor) ?? .systemPink
        button.setTitle("나가기", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        button.addTarget(
            self,
            action: #selector(pressedExitButton),
            for: .touchUpInside
        )
        button.layer.cornerRadius = 6
        button.addBounceAnimationWithNoFeedback()
        return button
    }()
    
    let headerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    lazy var memberTableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(
            ChatMembersTableViewCell.self,
            forCellReuseIdentifier: ChatMembersTableViewCell.cellId
        )
        return tableView
    }()
    
    //MARK: - Initialization
    
    init(chatManager: ChatManager, roomInfo: RoomInfo?, postUploaderUid: String) {
        super.init()
        self.chatManager = chatManager
        self.roomInfo = roomInfo
        self.postUploaderUid = postUploaderUid
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    //MARK: - UI Setup

    override func setupLayout() {
        super.setupLayout()
        
        view.addSubview(headerView)
        headerView.addSubview(titleLabel)
        headerView.addSubview(personImageView)
        headerView.addSubview(participatingMemberCountLabel)
        headerView.addSubview(exitButton)
        view.addSubview(memberTableView)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        headerView.snp.makeConstraints { make in
            make.height.equalTo(Metrics.headerViewHeight)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.right.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
        }
        
        personImageView.snp.makeConstraints { make in
            make.width.height.equalTo(20)
            make.centerY.equalToSuperview()
            make.left.equalTo(titleLabel.snp.right).offset(20)
        }
        
        participatingMemberCountLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(personImageView.snp.right).offset(7)
        }
        
        exitButton.snp.makeConstraints { make in
            make.width.equalTo(70)
            make.height.equalTo(25)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(15)
        }
        
        memberTableView.snp.makeConstraints { make in
            make.left.bottom.right.equalToSuperview()
            make.top.equalTo(headerView.snp.bottom)
        }
    }
    
    override func setupStyle() {
        super.setupStyle()
    }
    
    private func configure() {
        
        filterBannedMembers()
        participatingMemberCountLabel.text = "\(self.roomInfo?.post.currentlyGatheredPeople ?? 0)"
    }
    
    private func filterBannedMembers() {
        guard let members = roomInfo?.member else { return }
        filteredMembers = members.filter { $0.isBanned == false }
    }
}

//MARK: - Target Methods

extension ChatMemberListViewController {
    
    @objc private func pressedExitButton() {
        if postUploaderUid == User.shared.userUID {
            presentAlertWithCancelAction(
                title: "본인이 방장으로 있는 채팅방입니다.",
                message: "글 작성자가 나가면 공구가 삭제되고 참여자 전원이 채팅방에서 나가게 됩니다. 신중히 생각 후 삭제해주세요. 🤔"
            ) { selectedOk in
                
                if selectedOk {
                    showProgressBar()
                    NotificationCenter.default.post(
                        name: .didChooseToDeletePost,
                        object: nil
                    )
                    self.dismiss(animated: true)
                }
            }
        } else {
            presentAlertWithCancelAction(
                title: "해당 공구에서 나가시겠습니까?",
                message: ""
            ) { selectedOk in
                
                if selectedOk {
                    showProgressBar()
                    NotificationCenter.default.post(
                        name: .didChooseToExitPost,
                        object: nil
                    )
                    self.dismiss(animated: true)
                }
            }
        }
    }
    
    
    func banUser(uid: String, nickname: String) {
        
        showProgressBar()
        
        guard let roomUID = self.roomInfo?.post.uuid else {
            showSimpleBottomAlert(with: NetworkError.E000.errorDescription)
            return
        }
        chatManager?.banUser(userUID: uid, in: roomUID) { [weak self] result in
            guard let self = self else { return }
            dismissProgressBar()
            
            switch result {
            case .success(_):
                self.dismiss(animated: true)
                self.presentCustomAlert(title: "강퇴 성공", message: "해당 사용자 내보내기에 성공하였습니다.")
                let userInfo: [String : String] = ["uid" : uid, "nickname" : nickname]
                showProgressBar()
                NotificationCenter.default.post(
                    name: .didBanUser,
                    object: userInfo
                )
            case .failure(let error):
                self.showSimpleBottomAlert(with: error.errorDescription)
            }
        }
    }
    
    func blockUser(uid: String, nickname: String) {
        guard !User.shared.bannedChatMembers.contains(uid) else {
            presentCustomAlert(title: "이미 차단한 사용자입니다.", message: "이미 차단 목록에 추가된 사용자입니다!")
            return
        }
        
        User.shared.bannedChatMembers.append(uid)
        dismiss(animated: true) {
            NotificationCenter.default.post(
                name: .didBlockUser,
                object: nil
            )
            NotificationCenter.default.post(
                name: .resetAndReconnectChat,
                object: nil
            )
        }
    }
    
}

//MARK: - UITableViewDelegate, UITableViewDataSource

extension ChatMemberListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredMembers?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellID = ChatMembersTableViewCell.cellId
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: cellID
        ) as? ChatMembersTableViewCell else { return UITableViewCell() }
        
        if let cellVM = filteredMembers?[indexPath.row] {
            
            guard let postUploaderUID = postUploaderUid else { return UITableViewCell() }
            cell.delegate = self
            cell.configure(userManager: UserManager(), userUid: cellVM.userUID, postUploaderUid: postUploaderUID)
             
        } else {
            cell.nicknameLabel.text = "사용자 정보 불러오기 실패 🧐"
            cell.reportUserButton.isHidden = true
            cell.crownImageView.isHidden = true
            cell.profileImageView.image = UIImage(named: K.Images.chatMemberDefaultImage)
        }
    
        tableView.tableFooterView = UIView(frame: .zero)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Metrics.chatMembersCellHeight
    }
}

//MARK: - ChatMemberTableViewCellDelegate

extension ChatMemberListViewController: ChatMembersTableViewCellDelegate {
    
    func presentActionSheetForMembers(blockUID: String, reportNickname: String) {
            
        let reportAction = UIAlertAction(
            title: "신고하기",
            style: .default
        ) { [weak self] _ in
            guard let self = self else { return }
            guard let postUID = self.roomInfo?.post.uuid else { return }
            self.presentReportUserVC(userToReport: reportNickname, postUID: postUID)
        }
        
        let banAction = UIAlertAction(
            title: "차단하기",
            style: .default
        ) { [weak self] _ in
            guard let self = self else { return }
            
            self.presentAlertWithCancelAction(
                title: "\(reportNickname)님을 차단하시겠습니까?",
                message: "한 번 차단하면 해당 사용자의 채팅이 모든 채팅방에서 더 이상 보이지 않으며, 복구할 수 없습니다. 진행하시겠습니까? "
            ) { selectedOk in
                if selectedOk {
                    self.blockUser(uid: blockUID, nickname: reportNickname)
                }
            }
        }
   
        let actionSheet = UIHelper.createActionSheet(
            with: [reportAction, banAction],
            title: "\(reportNickname)님"
        )

        present(actionSheet, animated: true)
    }
    
    func failedPresentingUserReportVC() {
        showSimpleBottomAlert(with: "일시적인 서비스 오류입니다. 잠시 후 다시 시도해주세요 😥")
    }
    
    func presentActionSheetForPostUploader(userUID: String, nickname: String) {
        
        let banAction = UIAlertAction(
            title: "강퇴하기",
            style: .default
        ) { [weak self] _ in
            guard let self = self else { return }
            
            self.presentAlertWithCancelAction(
                title: "정말 강퇴 시키시겠습니까?",
                message: "강퇴를 시키면 다시는 채팅방에 들어오지 못합니다."
            ) { selectedOk in
                if selectedOk {
                    self.banUser(uid: userUID, nickname: nickname)
                }
            }
        }
        let reportAction = UIAlertAction(
            title: "신고하기",
            style: .default
        ) { [weak self] _ in
            guard let self = self else { return }
            guard let postUID = self.roomInfo?.post.uuid else { return }
            self.presentReportUserVC(userToReport: nickname, postUID: postUID)
        }
 
        let actionSheet = UIHelper.createActionSheet(
            with: [banAction, reportAction],
            title: "\(nickname)님"
        )
        
        present(actionSheet, animated: true)
    }
}


//MARK: - PanModalPresentable

extension ChatMemberListViewController: PanModalPresentable {
    
    var panScrollable: UIScrollView? {
        return memberTableView
    }
    
    var shortFormHeight: PanModalHeight {
        return filteredMembers != nil
        ? .contentHeight(CGFloat(filteredMembers!.count) * Metrics.chatMembersCellHeight + Metrics.headerViewHeight)
        : .contentHeight(view.bounds.height / 2)
    }
    var longFormHeight: PanModalHeight {
        return .maxHeightWithTopInset(50)
    }
}
