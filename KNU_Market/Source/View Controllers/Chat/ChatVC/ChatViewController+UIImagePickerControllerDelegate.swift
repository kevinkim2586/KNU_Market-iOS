//
//  ChatViewController+UIImagePickerControllerDelegate.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2021/11/29.
//

import UIKit

extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        
        guard
            let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage,
            let imageData = image.jpegData(compressionQuality: 0.8) else {
            return
        }
        
        // Upload Message
        showProgressBar()
        viewModel.uploadImage(imageData: imageData)

    }
}
