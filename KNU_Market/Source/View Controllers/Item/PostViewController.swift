import UIKit
import SnapKit
import ImageSlideshow

class PostViewController: BaseViewController {
    
    //MARK: - Properties
    
    //MARK: - Constants
    
    //MARK: - UI
    
    lazy var postControlButtonView: KMPostButtonView = {
        let view = KMPostButtonView()
        view.delegate = self
        return view
    }()
    
//    lazy var postHeaderView: PostHeaderView = {
//        let view = PostHeaderView()
//        return view
//    }()
    
    lazy var postTableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorColor = .clear
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        return tableView
    }()
    
    

    
    //MARK: - Initialization
    
//    init(userManager: UserManager) {
//        super.init()
//
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    //MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
 
    
    //MARK: - UI Setup

    override func setupLayout() {
        super.setupLayout()
        
        view.addSubview(postControlButtonView)
    
    }
    
    override func setupConstraints() {
        super.setupConstraints()
    
//        postHeaderView.snp.makeConstraints {
//            $0.top.left.right.equalToSuperview()
//            $0.height.equalToSuperview().multipliedBy(0.5)
//        }
        
        postControlButtonView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.height.equalTo(50)
            $0.left.right.equalToSuperview()
        }
        
    }
    
    private func configure() {
        
    }
    
    private func configureHeaderView() {
    
        let headerView = PostHeaderView(
            frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height * 0.5),
            currentVC: self,
            imageSources: <#T##[InputSource]#>,
            postTitle: <#T##String#>,
            profileImageUid: <#T##String#>,
            userNickname: <#T##String#>,
            locationName: <#T##String#>,
            dateString: <#T##String#>
        )
    }
    
    


}

//MARK: - Target Methods

extension PostViewController {
    
}

//MARK: - KMPostButtonViewDelegate

extension PostViewController: KMPostButtonViewDelegate {
    
    func didPressBackButton() {
        print("✅ didPressBackButton")
    }
    
    func didPressGatheringStatusButton() {
        print("✅ didPressGatheringStatusButton")
    }
    
    func didPresseTrashButton() {
        print("✅ didPresseTrashButton")
    }
    
    func didPressMenuButton() {
        print("✅ didPressMenuButton")
    }
    
    
}

//MARK: - UITableViewDelegate, UITableViewDataSource

extension PostViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        return UITableViewCell()
    }
    
    
    
}


extension PostViewController {
    
}

extension PostViewController {
    
}


extension PostViewController {
    
}


