//
//  UploadPostViewController+TargetMethods.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2021/11/29.
//

import UIKit
import GMStepper

extension UploadPostViewController {
    
    @objc func pressedUploadButton() {
        view.endEditing(true)
        if !validateUserInput() { return }
        editModel != nil ? askToUpdatePost() : askToUploadPost()
    }
    
    
    func askToUploadPost() {
        
        self.presentAlertWithCancelAction(
            title: "작성하신 글을 올리시겠습니까?",
            message: ""
        ) { selectedOk in
            if selectedOk {
                showProgressBar()
                if !self.viewModel.userSelectedImages.isEmpty {
                    self.viewModel.uploadImageToServerFirst()
                } else {
                    self.viewModel.uploadPost()
                }
            }
        }
    }
    
    func askToUpdatePost() {
        
        self.presentAlertWithCancelAction(
            title: "수정하시겠습니까?",
            message: ""
        ) { selectedOk in
            
            if selectedOk {
                showProgressBar()
                
                if !self.viewModel.userSelectedImages.isEmpty {
                    self.viewModel.deletePriorImagesInServerFirst()
                    self.viewModel.uploadImageToServerFirst()
                } else {
                    self.viewModel.updatePost()
                }
            }
        }
    }
    

    func validateUserInput() -> Bool {
        
        guard let postTitle = postTitleTextField.text else {
            
            self.showSimpleBottomAlert(with: ValidationError.OnUploadPost.titleTooShortOrLong.rawValue)
            return false
        }
        viewModel.postTitle = postTitle
        do {
            try viewModel.validateUserInputs()
            
        } catch ValidationError.OnUploadPost.titleTooShortOrLong {
            
            self.showSimpleBottomAlert(with: ValidationError.OnUploadPost.titleTooShortOrLong.rawValue)
            return false
            
        } catch ValidationError.OnUploadPost.detailTooShortOrLong {
            
            self.showSimpleBottomAlert(with: ValidationError.OnUploadPost.detailTooShortOrLong.rawValue)
            return false
            
        }
        catch { return false }
        
        return true
    }
    
    @objc func pressedStepper(_ sender: GMStepper) {
        totalGatheringPeopleLabel.text = "\(String(Int(gatheringPeopleStepper.value))) 명"
        viewModel.totalPeopleGathering = Int(gatheringPeopleStepper.value)
    }
    
    func configurePageWithPriorData() {
        
        viewModel.editPostModel = editModel
        
        viewModel.postTitle = editModel!.title
        viewModel.location = editModel!.location - 1
        viewModel.totalPeopleGathering = editModel!.totalGatheringPeople
        viewModel.postDetail = editModel!.postDetail
        viewModel.currentlyGatheredPeople = editModel!.currentlyGatheredPeople
        
        // 이미지 url 이 있으면 실행
        if let imageURLs = editModel!.imageURLs, let imageUIDs = editModel!.imageUIDs {
            viewModel.priorImageURLs = imageURLs
            viewModel.priorImageUIDs = imageUIDs
        }
    
        postTitleTextField.text = editModel!.title
        
        // 현재 모집된 인원이 1명이면, 최소 모집 인원인 2명으로 자동 설정할 수 있게끔 실행
        gatheringPeopleStepper.minimumValue = editModel!.currentlyGatheredPeople == 1 ?
        Double(viewModel.requiredMinimumPeopleToGather) : Double(editModel!.currentlyGatheredPeople)
        
        gatheringPeopleStepper.value = Double(editModel!.currentlyGatheredPeople)
        
        totalGatheringPeopleLabel.text = String(editModel!.totalGatheringPeople) + " 명"
        tradeLocationTextField.text = self.viewModel.locationArray[editModel!.location - 1]
        
        postDetailTextView.text = editModel!.postDetail
        postDetailTextView.textColor = UIColor.black
    
    }
}



