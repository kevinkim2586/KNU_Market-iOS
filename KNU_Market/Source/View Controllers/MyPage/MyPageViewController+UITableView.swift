//
//  MyPageViewController+UITableView.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2021/12/06.
//

import UIKit

//MARK: - UITableViewDelegate, UITableViewDataSource

extension MyPageViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 0: return viewModel.tableViewSection_1.count
        case 1: return viewModel.tableViewSection_2.count
        default: return 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "사용자 설정"
        case 1: return "기타"
        default: break
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 25))
        view.backgroundColor = .white
        
        let label = UILabel(frame: CGRect(x: 16, y: 5, width: tableView.frame.width, height: 20))
        
        switch section {
        case 0: label.text = "사용자 설정"
        case 1: label.text = "기타"
        default: break
        }
        
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textAlignment = .left
        label.textColor = .darkGray
        view.addSubview(label)
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: MyPageTableViewCell.cellId,
            for: indexPath
        ) as! MyPageTableViewCell
        
        cell.leftImageView.tintColor = .black
        
        switch indexPath.section {
        case 0:
            cell.settingsTitleLabel.text = viewModel.tableViewSection_1[indexPath.row]
            cell.leftImageView.image = UIImage(systemName: K.Images.myPageSection_1_Images[indexPath.row])
        case 1:
            cell.settingsTitleLabel.text = viewModel.tableViewSection_2[indexPath.row]
            if indexPath.row == 0 {
                cell.leftImageView.image = UIImage(named: K.Images.myPageSection_2_Images[indexPath.row])
                cell.notificationBadgeImageView.isHidden = viewModel.isReportChecked
            } else {
                cell.leftImageView.image = UIImage(systemName: K.Images.myPageSection_2_Images[indexPath.row])
            }
        default: break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0: pushViewController(with: MyPostsViewController(viewModel: PostListViewModel(postManager: PostManager(), chatManager: ChatManager(), userManager: UserManager(), popupService: PopupService(network: Network<PopupAPI>()))))
            case 1: pushViewController(with: AccountManagementViewController())
            case 2: pushViewController(with: VerifyOptionViewController())
            default: break
            }
        case 1:
            switch indexPath.row {
            case 0: pushViewController(with: SendUsMessageViewController(reactor: SendUsMessageReactor()))
            case 1:
                let url = URL(string: K.URL.termsAndConditionNotionURL)!
                presentSafariView(with: url)
            case 2:
                let url = URL(string: K.URL.privacyInfoConditionNotionURL)!
                presentSafariView(with: url)
            case 3: pushViewController(with: DeveloperInformationViewController())
            default: break
            }
        default: return
        }
    }
    
    func pushViewController(with vc: UIViewController) {
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
}
