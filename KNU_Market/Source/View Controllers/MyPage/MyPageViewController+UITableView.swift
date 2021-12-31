//
//  MyPageViewController+UITableView.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2021/12/06.
//

import UIKit

//MARK: - UITableViewDelegate, UITableViewDataSource

extension MyPageViewController: UITableViewDelegate {
    

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(
//            withIdentifier: MyPageTableViewCell.cellId,
//            for: indexPath
//        ) as! MyPageTableViewCell
//
//        cell.leftImageView.tintColor = .black
//
//        switch indexPath.section {
//        case 0:
//            cell.settingsTitleLabel.text = viewModel.tableViewSection_1[indexPath.row]
//            cell.leftImageView.image = UIImage(systemName: K.Images.myPageSection_1_Images[indexPath.row])
//        case 1:
//            cell.settingsTitleLabel.text = viewModel.tableViewSection_2[indexPath.row]
//            if indexPath.row == 0 {
//                cell.leftImageView.image = UIImage(named: K.Images.myPageSection_2_Images[indexPath.row])
//                cell.notificationBadgeImageView.isHidden = viewModel.isReportChecked
//            } else {
//                cell.leftImageView.image = UIImage(systemName: K.Images.myPageSection_2_Images[indexPath.row])
//            }
//        default: break
//        }
//        return cell
//    }
//

}
