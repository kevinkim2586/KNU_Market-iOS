import UIKit

extension PostViewController: KMPostButtonViewDelegate {
    
    func didPressBackButton() {
        navigationController?.popViewController(animated: true)
    }
    
    func didPressGatheringStatusButton() {

        if let isCompletelyDone = viewModel.model?.isCompletelyDone {
            
            if isCompletelyDone {
                let cancelMarkDoneAction = UIAlertAction(
                    title: "다시 모집하기",
                    style: .default
                ) { [weak self] _ in
                    guard let self = self else { return }
                    self.viewModel.cancelMarkPostDone()
                }
                presentActionSheet(with: [cancelMarkDoneAction], title: "모집 상태 변경")
            } else {
                let doneAction = UIAlertAction(
                    title: "모집 완료하기",
                    style: .default
                ) { [weak self] _ in
                    guard let self = self else { return }
                    self.viewModel.markPostDone()
                }
                presentActionSheet(with: [doneAction], title: "모집 상태 변경")
            }
        }
    }
    
    func didPresseTrashButton() {
    
        let deleteAction = UIAlertAction(
            title: "공구 삭제하기",
            style: .destructive
        ) { [weak self] _ in
            guard let self = self else { return }
            self.presentAlertWithCancelAction(
                title: "정말 삭제하시겠습니까?",
                message: ""
            ) { selectedOk in
                if selectedOk {
                    showProgressBar()
                    self.viewModel.deletePost()
                }
            }
        }
        presentActionSheet(with: [deleteAction], title: nil)
    }
    
    func didPressMenuButton() {

        if viewModel.postIsUserUploaded {
                        
            let editAction = UIAlertAction(
                title: "글 수정하기",
                style: .default
            ) { [weak self] _ in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    
                    let vc = UploadPostViewController(
                        viewModel: UploadPostViewModel(
                            postManager: PostManager(),
                            mediaManager: MediaManager()
                        ),
                        editModel: self.viewModel.modelForEdit
                    )
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            presentActionSheet(with: [editAction], title: nil)
        } else {
            
            let reportAction = UIAlertAction(
                title: "게시글 신고하기",
                style: .default
            ) { [weak self] _ in
                guard let self = self else { return }
                guard let nickname = self.viewModel.model?.nickname else { return }
                self.presentReportUserVC(
                    userToReport: nickname,
                    postUID: self.viewModel.pageID
                )
            }
            let blockAction = UIAlertAction(
                title: "이 사용자의 글 보지 않기",
                style: .default
            ) { [weak self] _ in
                guard let self = self else { return }
                self.askToBlockUser()
            }
            presentActionSheet(with: [reportAction, blockAction], title: nil)

        }
    }
    
    
    func askToBlockUser() {
        
        guard let reportNickname = viewModel.model?.nickname,
              let reportUID = viewModel.model?.userUID else {
            showSimpleBottomAlert(with: "현재 해당 기능을 사용할 수 없습니다.😥")
            return
        }
    
        guard !User.shared.bannedPostUploaders.contains(reportUID) else {
            showSimpleBottomAlert(with: "이미 \(reportNickname)의 글을 안 보기 처리하였습니다.🧐")
            return
        }
        
        presentAlertWithCancelAction(
            title: "\(reportNickname)님의 글 보지 않기",
            message: "홈화면에서 위 사용자의 게시글이 더는 보이지 않도록 설정하시겠습니까? 한 번 설정하면 해제할 수 없습니다."
        ) { selectedOk in
            if selectedOk { self.viewModel.blockUser(userUID: reportUID) }
        }
    }
}
