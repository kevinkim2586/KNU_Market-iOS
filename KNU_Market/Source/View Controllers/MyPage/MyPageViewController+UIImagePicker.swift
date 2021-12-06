//
//  MyPageViewController+UIImagePicker.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2021/12/06.
//

import UIKit


//MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate

extension MyPageViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let originalImage: UIImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            dismiss(animated: true) {
                self.presentAlertWithCancelAction(
                    title: "프로필 사진 변경",
                    message: "선택하신 이미지로 프로필 사진을 변경하시겠습니까?"
                ) { selectedOk in
                    if selectedOk {
                        self.updateProfileImageButton(with: originalImage)
                        showProgressBar()
                        OperationQueue().addOperation {
                            self.viewModel.uploadImageToServerFirst(with: originalImage)
                            dismissProgressBar()
                        }
                    } else {
                        self.imagePickerControllerDidCancel(self.imagePicker)
                    }
                }
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
