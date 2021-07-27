import UIKit
import PanModal

class ChatMemberViewController: UIViewController {
    
    @IBOutlet weak var postTitleLabel: UILabel!
    @IBOutlet weak var postMemberCountLabel: UILabel!
    @IBOutlet weak var memberTableView: UITableView!
    
    var roomInfo: RoomInfo?

    override func viewDidLoad() {
        super.viewDidLoad()

        initialize()
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
            
            cell.configure(with: cellVM.userUID)
             
        } else {
            cell.nicknameLabel.text = "ERROR"
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
