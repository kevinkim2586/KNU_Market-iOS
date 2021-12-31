//
//  MyPageViewController_+MyPageViewModelDelegate.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2021/12/06.
//

import UIKit

//MARK: - MyPageViewModelDelegate

extension MyPageViewController: MyPageViewModelDelegate {
    
    func didLoadUserProfileInfo() {
        userNicknameLabel.text = "\(viewModel.userNickname)\n(\(viewModel.userId))"
        
        userVerifiedImage.image = detectIfVerifiedUser()
        ? Images.userVerifiedImage
        : Images.userUnVerifiedImage
        
        settingsTableView.reloadData()
    }
    
    func didFetchProfileImage() {
        if viewModel.profileImage != nil {
            profileImageButton.setImage(
                viewModel.profileImage,
                for: .normal
            )
            profileImageButton.layer.masksToBounds = true
        } else {
            profileImageButton.setImage(UIImage(named: K.Images.pickProfileImage),
                                        for: .normal)
            profileImageButton.layer.masksToBounds = false
        }
    }
    
    func failedLoadingUserProfileInfo(with error: NetworkError) {
        self.showSimpleBottomAlert(with: "프로필 정보 가져오기 실패. 로그아웃 후 다시 시도해주세요.")
        userNicknameLabel.text = "닉네임 불러오기 실패"
    }
    
    //이미지 먼저 서버에 업로드
    func didUploadImageToServerFirst(with uid: String) {
        viewModel.updateUserProfileImage(with: uid)
    }
    
    func didRemoveProfileImage() {
        showSimpleBottomAlert(with: "프로필 사진 제거 성공 🎉")

        User.shared.profileImage = nil
    }
    
    func failedUploadingImageToServerFirst(with error: NetworkError) {
        self.showSimpleBottomAlert(with: error.errorDescription)
 
    }
    
    // 프로필 사진 실제 DB상 수정
    func didUpdateUserProfileImage() {
        viewModel.loadUserProfile()
        self.showSimpleBottomAlert(with: "프로필 이미지 변경 성공 🎉")
    }
    
    func failedUpdatingUserProfileImage(with error: NetworkError) {
        self.showSimpleBottomAlert(with: error.errorDescription)
    }
    
    func showErrorMessage(with message: String) {
        self.showSimpleBottomAlert(with: message)
    }
}
