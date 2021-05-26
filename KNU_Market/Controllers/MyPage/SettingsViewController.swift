import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet var userNicknameLabel: UILabel!
    
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        initialize()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        initialize()
    
    }

    
    
    func initialize() {
        
        userNicknameLabel.text = User.shared.nickname
        
    }


}
