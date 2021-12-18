import UIKit
import RxSwift
import RxCocoa

class BaseViewController: UIViewController {
    
    // MARK: - Rx
    var disposeBag = DisposeBag.init()
    
    //MARK: - Initialization
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - View Life Cycle

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
    
    //MARK: - Constraint, Style, Action Configuration
    
    func setupLayout() {
        
    }
    
    func setupConstraints() {
        
    }
    
    func setupStyle() {
        view.backgroundColor = .white
        setBackBarButtonItemTitle()
    }
    
    func setupActions() {
        
    }
    
    

}
