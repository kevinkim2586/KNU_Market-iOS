import UIKit

class ChatListViewController: UIViewController {

    @IBOutlet weak var chatListTableView: UITableView!
    
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: Constants.Color.appColor)]
        
        initialize()

    }
    
}

//MARK: - UITableViewDelegate, UITableViewDataSource

extension ChatListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = Constants.cellID.chatTableViewCell
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ChatTableViewCell else {
            fatalError("Failed to dequeue cell for ItemTableViewCell")
        }
        
        cell.chatImageView.image = UIImage(named: "chat_bubble_icon")
        cell.chatTitleLabel.text = "공차 시키실 분?"
        cell.chatParticipatingCountLabel.text = "2" + " 명"
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @objc func refreshTableView() {
        
        chatListTableView.reloadData()
        chatListTableView.refreshControl?.endRefreshing()
    }
    
}



//MARK: - UI Configuration

extension ChatListViewController {
    
    func initialize() {
        
        self.navigationController?.view.backgroundColor = .white
        
        initializeTableView()
    }
    
    func initializeTableView() {
        
        chatListTableView.delegate = self
        chatListTableView.dataSource = self
        chatListTableView.refreshControl = refreshControl
        
        refreshControl.addTarget(self, action: #selector(refreshTableView), for: .valueChanged)
        
    }
}
