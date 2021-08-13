import UIKit
import PanModal

protocol ChatMemberViewDelegate: AnyObject {
    
    func didChooseToExitPost()
    func didChooseToDeletePost()
    
    func didDismissPanModal()
}

class ChatMemberViewController: UIViewController {
    
    @IBOutlet weak var postTitleLabel: UILabel!
    @IBOutlet weak var postMemberCountLabel: UILabel!
    @IBOutlet weak var memberTableView: UITableView!
    
    var roomInfo: RoomInfo?
    var postUploaderUID: String?
    
    weak var delegate: ChatMemberViewDelegate?
    
    deinit {
        print("❗️ ChatMemberVC has been DEINITIALIZED")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        initialize()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.delegate?.didDismissPanModal()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        dismissProgressBar()
    }

    

    @IBAction func pressedSettingsButton(_ sender: UIButton) {

        let alert = UIAlertController(title: nil,
                                      message: nil,
                                      preferredStyle: .actionSheet)
        
        // 내가 올린 공구글이라면 채팅방 나가기가 아닌 공구글 자체 삭제
        if self.postUploaderUID == User.shared.userUID {
            
            let deleteChatRoom = UIAlertAction(title: "공구 삭제하기",
                                               style: .destructive) { _ in
                
                self.presentAlertWithCancelAction(title: "정말 삭제하시겠습니까?",
                                                  message: "글 작성자가 삭제하면 공구가 삭제되고 참여자 전원이 채팅방에서 나가게 됩니다. 신중히 생각 후 삭제해주세요. 🤔") { selectedOk in
                    
                    if selectedOk {
                        self.delegate?.didChooseToDeletePost()
                        self.dismiss(animated: true)
                    }
                }
            }
            
            alert.addAction(deleteChatRoom)
    
        } else {
            let exitChatRoom = UIAlertAction(title: "채팅방 나가기",
                                             style: .default) { _ in
                
                self.presentAlertWithCancelAction(title: "해당 공구에서 나가시겠습니까?",
                                                  message: "") { selectedOk in
                    
                    if selectedOk {
                        self.delegate?.didChooseToExitPost()
                        self.dismiss(animated: true)
                    }
                }
            }
            alert.addAction(exitChatRoom)
        }
        
        let cancel = UIAlertAction(title: "취소",
                                   style: .cancel,
                                   handler: nil)
        alert.addAction(cancel)
        self.present(alert, animated: true)
    }
    
    func banUser(uid: String) {
        
        showProgressBar()
        
        guard let roomUID = self.roomInfo?.post.uuid else {
            self.showSimpleBottomAlert(with: NetworkError.E000.errorDescription)
            return
        }
        
        ChatManager.shared.banUser(userUID: uid, in: roomUID) { [weak self] result in
            
            guard let self = self else { return }
            
            dismissProgressBar()
            
            switch result {
            
            case .success(_):
                
                self.dismiss(animated: true) {
                    self.showSimpleBottomAlert(with: "강퇴 성공 🎉")
                }
                
            case .failure(let error):
                self.showSimpleBottomAlert(with: error.errorDescription)
            }
        }
        
    }
    
}

//MARK: - UITableViewDelegate, UITableViewDataSource

extension ChatMemberViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return roomInfo?.member.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellID = Constants.cellID.chatMemberCell
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID) as? ChatMemberTableViewCell else { return UITableViewCell() }
        
        if let cellVM = self.roomInfo?.member[indexPath.row] {
            
            cell.delegate = self
            cell.configure(with: cellVM.userUID)
             
        } else {
            cell.nicknameLabel.text = "사용자 정보 불러오기에 실패했습니다.🧐"
            cell.reportUserButton.isHidden = true
        }
    
        tableView.tableFooterView = UIView(frame: .zero)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        
        guard let postUploader = self.roomInfo?.post.user.uid else { return }   // 글 작성자가 누구인지 판단
        
        if User.shared.userUID != postUploader { return }                       // 방장이 아닌 경우 그냥 바로 deselectRow
        
        guard let selectedUser = self.roomInfo?.member[indexPath.row].userUID else {
            self.showSimpleBottomAlert(with: "현재 강퇴 기능을 사용을 할 수 없습니다. 불편을 드려 죄송합니다.😥")
            return
        }
        
        if selectedUser == User.shared.userUID { return }
    
        presentAlertWithCancelAction(title: "해당 사용자를 강퇴 시키시겠습니까?🧐",
                                     message: "강퇴를 2번 이상 시키면 다시는 채팅방에 들어오지 못합니다.") { selectedOk in
            
            if selectedOk {
                self.banUser(uid: selectedUser)
            }
        }

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
}

//MARK: - ChatMemberTableViewCellDelegate

extension ChatMemberViewController: ChatMemberTableViewCellDelegate {
    
    func presentUserReportVC(userToReport: String) {
        self.presentReportUserVC(userToReport: userToReport)
    }
    
    func failedPresentingUserReportVC() {
        self.showSimpleBottomAlert(with: "일시적인 서비스 오류입니다. 잠시 후 다시 시도해주세요 😥")
    }
}

//MARK: - UI Configuration & Initialization

extension ChatMemberViewController {
    
    func initialize() {
        
        initializeTableView()
        initializeTopView()
        
    }
    
    func initializeTableView() {
        
        memberTableView.delegate = self
        memberTableView.dataSource = self
    }
    
    func initializeTopView() {
        
        postMemberCountLabel.text = "\(self.roomInfo?.post.currentlyGatheredPeople ?? 0)"
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
