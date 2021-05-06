import UIKit
import Alamofire

class HomeViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialize()

    }
    
}


extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 145.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = Constants.cellID.itemTableViewCell
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ItemTableViewCell else {
            fatalError("Failed to dequeue cell for ItemTableViewCell")
        }
        
        cell.itemImageView.image = UIImage(named: "pizza")
        cell.itemTitleLabel.text = "공구 구합니다"
        cell.locationLabel.text = "북문"
        cell.gatheringLabel.text = "모집 중"
        cell.personImageView.image = UIImage(named: "person_icon")
        cell.currentlyGatheredPeopleLabel.text = "1"

        
        return cell
    }
    
    
}


//MARK: - UI Configuration

extension HomeViewController {
    
    func initialize() {
        
        initializeTableView()
    }
    
    func initializeTableView() {
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
}
