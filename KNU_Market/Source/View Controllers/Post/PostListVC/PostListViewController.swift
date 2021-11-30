import UIKit
import SPIndicator
import ViewAnimator
import HGPlaceholders
import PMAlertController
import SnapKit

class PostListViewController: BaseViewController {

    //MARK: - Properties
    
    var viewModel: PostListViewModel!
    
    //MARK: - Constants
    
    struct Metrics {
        static let addPostButtonSize: CGFloat = 55
    }
    
    //MARK: - UI
    
    lazy var postListsTableView: TableView = {
        let tableView = TableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.placeholderDelegate = self   
        tableView.register(
            PostTableViewCell.self,
            forCellReuseIdentifier: PostTableViewCell.cellId
        )
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(
            self,
            action: #selector(refreshTableView),
            for: .valueChanged
        )
        return tableView
    }()
    
    
    lazy var logoBarButtonItem: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.title = "크누마켓"
        button.style = .done
        button.target = self
        button.action = #selector(pressedLogoBarButton)
        return button
    }()
    
    lazy var searchBarButtonItem: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.image = UIImage(systemName: "magnifyingglass")
        button.style = .plain
        button.target = self
        button.action = #selector(pressedSearchBarButton)
        return button
    }()
    
    lazy var filterBarButtonItem: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.image = UIImage(named: K.Images.homeMenuIcon) ?? UIImage(systemName: "gear")
        button.style = .plain
        button.target = self
        button.action = #selector(pressedFilterBarButton)
        return button
    }()
    
    lazy var addPostButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(named: K.Color.appColor)
        button.addBounceAnimation()
        let font = UIFont.systemFont(ofSize: 23, weight: .medium)
        let configuration = UIImage.SymbolConfiguration(font: font)
        let buttonImage = UIImage(
            systemName: "plus",
            withConfiguration: configuration
        )
        button.tintColor = .white
        button.setImage(buttonImage, for: .normal)
        button.layer.cornerRadius = Metrics.addPostButtonSize / 2
        button.backgroundColor = UIColor(named: K.Color.appColor)
        button.addTarget(
            self,
            action: #selector(pressedAddPostButton),
            for: .touchUpInside
        )
        return button
    }()
    
    //MARK: - Initialization
    
    init(postViewModel: PostListViewModel) {
        super.init()
        self.viewModel = postViewModel
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    //MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.post(
            name: .getBadgeValue,
            object: nil
        )
    }
    

    //MARK: - UI Setup
    
    override func setupLayout() {
        super.setupLayout()
        
        navigationItem.leftBarButtonItem = logoBarButtonItem
        navigationItem.rightBarButtonItems = [filterBarButtonItem, searchBarButtonItem]
        
        view.addSubview(postListsTableView)
        view.addSubview(addPostButton)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        postListsTableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        addPostButton.snp.makeConstraints {
            $0.width.height.equalTo(Metrics.addPostButtonSize)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
            $0.right.equalToSuperview().offset(-25)
        }
    }
    
    override func setupStyle() {
        super.setupStyle()
    }
    
    override func setupActions() {
        super.setupActions()
    }
    
    private func configure() {
        
        viewModel.delegate = self
        viewModel.loadInitialMethods()
        askForNotificationPermission()
        setBackBarButtonItemTitle()
        setNavigationBarAppearance(to: .white)
        postListsTableView.showLoadingPlaceholder()
        createObservers()
    }
}

