import UIKit
import HGPlaceholders
import SnapKit

class SearchPostsViewController: BaseViewController {

    //MARK: - Properties
    
    var viewModel: SearchPostViewModel!
    
    //MARK: - Constants
    
    //MARK: - UI
    
    lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.placeholder = "검색어 입력"
        return searchBar
    }()
    
    lazy var searchTableView: UITableView = {
        let tableView = UITableView()
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(
            PostTableViewCell.self,
            forCellReuseIdentifier: PostTableViewCell.cellId
        )
        return tableView
    }()
    
    //MARK: - Initialization
    
    init(viewModel: SearchPostViewModel) {
        super.init()
        hidesBottomBarWhenPushed = true
        self.viewModel = viewModel
        viewModel.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    

    //MARK: - UI Setup
    
    override func setupLayout() {
        super.setupLayout()
        
        view.addSubview(searchBar)
        view.addSubview(searchTableView)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.right.equalToSuperview().inset(10)
        }
        
        searchTableView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
        
    }
    
    private func configure() {
        title = "공구 글 검색"
        searchTableView.showEmptyView(
            imageName: K.Images.emptySearchPlaceholder,
            text: K.placeHolderTitle.prepareSearchTitleList.randomElement()!
        )
    }
}

