//
//  ChatListViewController+UITableView.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2021/11/29.
//

import UIKit

extension ChatListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.roomList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row > viewModel.roomList.count || viewModel.roomList.count == 0 {
            return UITableViewCell()
        }
        tableView.restoreEmptyView()
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ChatListTableViewCell.cellId,
                for: indexPath
        ) as? ChatListTableViewCell else { return UITableViewCell() }
        
        cell.configure(with: self.viewModel.roomList[indexPath.row])
        tableView.tableFooterView = UIView(frame: .zero)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if viewModel.roomList.count == 0 { return }
        
        let chatVC = ChatViewController()
        
        chatVC.roomUID = viewModel.roomList[indexPath.row].uuid
        chatVC.chatRoomTitle = viewModel.roomList[indexPath.row].title
        chatVC.postUploaderUID = viewModel.roomList[indexPath.row].userUID
        navigationController?.pushViewController(chatVC, animated: true)
        
        if let index = ChatNotifications.list.firstIndex(of: viewModel.roomList[indexPath.row].uuid) {
            ChatNotifications.list.remove(at: index)
        }
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    @objc func refreshTableView() {
        viewModel.fetchChatList()
    }
    
}
