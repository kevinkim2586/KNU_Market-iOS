//
//  ChatViewController+MessageCellDelegate.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2021/11/29.
//

import UIKit
import MessageKit

extension ChatViewController: MessageCellDelegate {
    
    func didTapMessageTopLabel(in cell: MessageCollectionViewCell) {
        
        if viewModel.messages.count == 0 { return }
        
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else { return }
        guard let message = messageForItem(
                at: indexPath,
                in: messagesCollectionView
        ) as? Message else { return }
        
        let nickname = message.usernickname
        
        presentAlertWithCancelAction(
            title: "\(nickname)을 신고하시겠습니까?",
            message: ""
        ) { selectedOk in
            if selectedOk { self.presentReportUserVC(userToReport: nickname) }
        }
    }

    
    func detectorAttributes(for detector: DetectorType, and message: MessageType, at indexPath: IndexPath) -> [NSAttributedString.Key : Any] {
        if viewModel.messages.count == 0 { return [:] }
        switch detector {
        case .url:
            if viewModel.messages[indexPath.section].userUID == User.shared.userUID {
                return [.foregroundColor: UIColor.white,  .underlineStyle: NSUnderlineStyle.single.rawValue]
            } else {
                return [.foregroundColor: UIColor.black, .underlineStyle: NSUnderlineStyle.single.rawValue]
            }
        default:
            return MessageLabel.defaultAttributes
        }
    }
    
    func enabledDetectors(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> [DetectorType] {
        return [.url]
    }
    
    func didSelectURL(_ url: URL) {
        presentSafariView(with: url)
    }
    
    func didTapImage(in cell: MessageCollectionViewCell) {
        if viewModel.messages.count == 0 { return }
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else { return }
        let message = messageForItem(at: indexPath, in: messagesCollectionView)
        let heroID = viewModel.messages[indexPath.section].heroID
        
        switch message.kind {
        case .photo(let photoItem):
            if let url = photoItem.url {
                presentImageVC(url: url, heroID: heroID)
            } else {
                self.presentKMAlertOnMainThread(
                    title: "오류 발생",
                    message: "유효하지 않은 사진이거나 요청을 처리하지 못했습니다. 불편을 드려 죄송합니다.😥",
                    buttonTitle: "확인"
                )
            }
        default: break
        }
    }
    
    func presentImageVC(url: URL, heroID: String) {
        
        let chatImageVC = ChatImageViewController(imageUrl: url, heroId: heroID)
        chatImageVC.modalPresentationStyle = .overFullScreen
        present(chatImageVC, animated: true)

    }
}
