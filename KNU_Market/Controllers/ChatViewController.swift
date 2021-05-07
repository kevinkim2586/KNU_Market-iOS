import UIKit

class ChatViewController: UIViewController {

    @IBOutlet weak var chatTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialize()

    }


}

//MARK: - UITableViewDelegate, UITableViewDataSource

extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = Constants.cellID.chatTableViewCell
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ChatTableViewCell else {
            fatalError("Failed to dequeue cell for ItemTableViewCell")
        }
        
        cell.chatImageView.image = UIImage(named: "chat_bubble_icon")
        cell.chatTitleLabel.text = "공차 시키실 분?"
        cell.chatParticipatingCountLabel.text = "2명"
        
        
        return cell
    }
    
    
}



//MARK: - UI Configuration

extension ChatViewController {
    
    func initialize() {
        
        initializeTableView()
    }
    
    func initializeTableView() {
        
        chatTableView.delegate = self
        chatTableView.dataSource = self
    }
}
