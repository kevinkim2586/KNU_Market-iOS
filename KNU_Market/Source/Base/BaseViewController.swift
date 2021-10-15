import UIKit

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        setupConstraints()
        setupStyle()
        setupActions()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        dismissProgressBar()
    }
    
    func setupLayout() {
        
    }
    
    func setupConstraints() {
        
    }
    
    func setupStyle() {
        
    }
    
    func setupActions() {
        
    }
    
    

}
