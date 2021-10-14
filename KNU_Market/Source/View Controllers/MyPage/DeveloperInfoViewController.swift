import UIKit

class DeveloperInfoViewController: UIViewController {

    @IBOutlet weak var developerInfoImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "팀 정보"
        developerInfoImageView.contentMode = .scaleAspectFit
    }
}
