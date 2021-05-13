import UIKit
import IQKeyboardManagerSwift

class ChatViewController: UIViewController {
    
    
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initialize()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        IQKeyboardManager.shared.enableAutoToolbar = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enableAutoToolbar = false
    }
    
    
    
    
    
    
    

    @IBAction func pressedSendButton(_ sender: UIButton) {
        
        //TEST
//        let indexPath = IndexPath(row: 8 - 1, section: 0)
//        chatTableView.scrollToRow(at: indexPath, at: .top, animated: true)
    }
    
}

//MARK: - UITableViewDelegate, UITableViewDataSource

extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 15
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellID.sendCell, for: indexPath) as? SendCell else {
            fatalError("Failed to dequeue cell for Chat View Controller")
        }
        
        cell.chatMessageLabel.text = "시험입니다"
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
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
        
        let sendCellNib = UINib(nibName: Constants.XIB.sendCell, bundle: nil)
        let sendCellID = Constants.cellID.sendCell
        chatTableView.register(sendCellNib, forCellReuseIdentifier: sendCellID)
    }
    
}
