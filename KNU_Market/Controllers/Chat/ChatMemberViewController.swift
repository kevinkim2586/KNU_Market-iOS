import UIKit
import PanModal

protocol ChatMemberViewDelegate: AnyObject {
    
    func didChooseToExitPost()
}

class ChatMemberViewController: UIViewController {
    
    @IBOutlet weak var postTitleLabel: UILabel!
    @IBOutlet weak var postMemberCountLabel: UILabel!
    @IBOutlet weak var memberTableView: UITableView!
    
    var roomInfo: RoomInfo?
    
    weak var delegate: ChatMemberViewDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        initialize()
    }
    

    @IBAction func pressedSettingsButton(_ sender: UIButton) {
        
        
        print("✏️ pressedSettingsButtons")
        
        let alert = UIAlertController(title: nil,
                                      message: nil,
                                      preferredStyle: .actionSheet)
        
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
        
        let cancel = UIAlertAction(title: "취소",
                                   style: .cancel,
                                   handler: nil)
        alert.addAction(exitChatRoom)
        alert.addAction(cancel)
        self.present(alert, animated: true)
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
            cell.nicknameLabel.text = "정보를 가져오는 데 실패했습니다. 🧐"
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
        return .contentHeight(view.bounds.height / 3)
    }
    
    var longFormHeight: PanModalHeight {
        return .maxHeightWithTopInset(50)
    }
    
}
