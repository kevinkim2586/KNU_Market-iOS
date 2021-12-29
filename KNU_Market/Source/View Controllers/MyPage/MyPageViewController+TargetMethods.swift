//
//  MyPageViewController+TargetMethods.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2021/12/06.
//

import UIKit


//MARK: - Target Methods & Profile Image Modification Methods

extension MyPageViewController {
    
    @objc func pressedSettingsBarButtonItem() {
        pushViewController(with: AccountManagementViewController(userDefaultsGenericService: UserDefaultsGenericService.shared))
    }
    
    @objc func pressedProfileImageButton(_ sender: UIButton) {
        presentActionSheet()
    }
    
    func initializeProfileImageButton() {
        profileImageButton.setImage(UIImage(named: K.Images.pickProfileImage), for: .normal)
        profileImageButton.layer.masksToBounds = false
        profileImageButton.isUserInteractionEnabled = true
        profileImageButton.contentMode = .scaleAspectFit
        profileImageButton.layer.cornerRadius = profileImageButton.frame.height / 2
    }
    
    
    func updateProfileImageButton(with image: UIImage) {
        profileImageButton.setImage(image, for: .normal)
        profileImageButton.contentMode = .scaleAspectFit
        profileImageButton.layer.masksToBounds = true
    }
    
    func presentActionSheet() {
        
        let library = UIAlertAction(
            title: "앨범에서 선택",
            style: .default
        ) { [weak self] _ in
            guard let self = self else { return }
            self.present(self.imagePicker, animated: true)
        }
        let remove = UIAlertAction(
            title: "프로필 사진 제거",
            style: .default
        ) { [weak self] _ in
            self?.presentAlertWithCancelAction(
                title: "프로필 사진 제거",
                message: "정말로 제거하시겠습니까?"
            ) { selectedOk in
                
                if selectedOk { self?.viewModel.removeProfileImage() }
                else { return }
            }
        }

        let alert = UIHelper.createActionSheet(with: [library, remove], title: "프로필 사진 변경")
        present(alert, animated: true, completion: nil)
    }
    
}
