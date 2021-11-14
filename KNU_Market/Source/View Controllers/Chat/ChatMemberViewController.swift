import UIKit
import PanModal

class ChatMemberViewController: UIViewController {
    
    @IBOutlet weak var postTitleLabel: UILabel!
    @IBOutlet weak var postMemberCountLabel: UILabel!
    @IBOutlet weak var memberTableView: UITableView!
    @IBOutlet weak var exitButton: UIButton!
    
    var roomInfo: RoomInfo?
    var filteredMembers: [Member]?
    var postUploaderUID: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
        guard let members = roomInfo?.member else { return }
        filteredMembers = members.filter { $0.isBanned == false }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        dismissProgressBar()
    }
    
    @IBAction func pressedExitButton(_ sender: UIButton) {
        if postUploaderUID == User.shared.userUID {
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
        ChatManager.shared.banUser(userUID: uid, in: roomUID) { [weak self] result in
            
            guard let self = self else { return }
            
            dismissProgressBar()
            
            switch result {
            case .success(_):
                self.dismiss(animated: true)
                self.presentKMAlertOnMainThread(
                    title: "강퇴 성공",
                    message: "해당 사용자 내보내기에 성공하였습니다.",
                    buttonTitle: "확인"
                )
                
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
            presentKMAlertOnMainThread(
                title: "이미 차단한 사용자입니다.",
                message: "이미 차단 목록에 추가된 사용자입니다!",
                buttonTitle: "확인"
            )
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

extension ChatMemberViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredMembers?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
//        let cellID = K.cellID.chatMemberCell
//        guard let cell = tableView.dequeueReusableCell(
//            withIdentifier: cellID
//        ) as? ChatMemberTableViewCell else { return UITableViewCell() }
        
        let cellID = ChatMembersTableViewCell.cellId
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: cellID
        ) as? ChatMembersTableViewCell else { return UITableViewCell() }
        
        if let cellVM = filteredMembers?[indexPath.row] {
            
            guard let postUploaderUID = postUploaderUID else { return UITableViewCell() }
            cell.delegate = self
            cell.configure(userManager: UserManager(), userUid: cellVM.userUID, postUploaderUid: postUploaderUID)
//            cell.configure(with: cellVM.userUID, postUploaderUID: postUploaderUID)
             
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
        return 65
    }
}

//MARK: - ChatMemberTableViewCellDelegate

extension ChatMemberViewController: ChatMembersTableViewCellDelegate {
    
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
        
        let actionSheet = UIAlertController(
            title: "\(nickname)님",
            message: nil,
            preferredStyle: .actionSheet
        )
        
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
        let cancelAction = UIAlertAction(
            title: "취소",
            style: .cancel,
            handler: nil
        )
        actionSheet.addAction(banAction)
        actionSheet.addAction(reportAction)
        actionSheet.addAction(cancelAction)
        present(actionSheet, animated: true)
    }
}

//MARK: - UI Configuration & Initialization

extension ChatMemberViewController {
    
    func initialize() {
        
        initializeTableView()
        initializeTopView()
        initializeExitButton()
    }
    
    func initializeTableView() {
        
        memberTableView.delegate = self
        memberTableView.dataSource = self
        memberTableView.separatorStyle = .none
        memberTableView.register(
            ChatMembersTableViewCell.self,
            forCellReuseIdentifier: ChatMembersTableViewCell.cellId
        )
    }
    
    func initializeTopView() {
        postMemberCountLabel.text = "\(self.roomInfo?.post.currentlyGatheredPeople ?? 0)"
    }
    
    func initializeExitButton() {
        exitButton.layer.cornerRadius = 6
        exitButton.addBounceAnimationWithNoFeedback()
        
    }
}

//MARK: - PanModalPresentable

extension ChatMemberViewController: PanModalPresentable {
    
    var panScrollable: UIScrollView? {
        return memberTableView
    }
    
    var shortFormHeight: PanModalHeight {
        return .contentHeight(view.bounds.height / 2)
    }
    
    var longFormHeight: PanModalHeight {
        return .maxHeightWithTopInset(50)
    }
}
