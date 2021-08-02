import UIKit
import Alamofire
import GMStepper
import SnackBar_swift

class UploadItemViewController: UIViewController {
    
    @IBOutlet weak var itemTitleTextField: UITextField!
    @IBOutlet var itemImagesCollectionView: UICollectionView!
    @IBOutlet weak var stepper: GMStepper!
    @IBOutlet weak var totalGatheringPeopleLabel: UILabel!
    @IBOutlet weak var tradeLocationTextField: UITextField!
    @IBOutlet weak var expandButton: UITextField!
    @IBOutlet weak var itemDetailTextView: UITextView!
    
    var viewModel = UploadItemViewModel()
    var editModel: EditPostModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialize()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        dismissProgressBar()
    }
    
    @IBAction func pressedStepper(_ sender: GMStepper) {
        totalGatheringPeopleLabel.text = "\(String(Int(stepper.value))) 명"
        viewModel.peopleGathering = Int(stepper.value)
    }
    
    @IBAction func pressedFinishButton(_ sender: UIBarButtonItem) {
        
        itemDetailTextView.resignFirstResponder()
        
        if !validateUserInput() { return }
        
        self.presentAlertWithCancelAction(title: "작성하신 글을 올리시겠습니까?", message: "") { selectedOk in
            
            if selectedOk {
                
                showProgressBar()
                
                if !self.viewModel.userSelectedImages.isEmpty {
                    
                    self.viewModel.uploadImageToServerFirst()
                    
                } else {
                    self.viewModel.uploadItem()
                }
            }
        }
    }
    
    func validateUserInput() -> Bool {
        
        guard let itemTitle = itemTitleTextField.text else {
            
            self.showSimpleBottomAlert(with: UserInputError.titleTooShortOrLong.errorDescription)
            return false
        }
        viewModel.itemTitle = itemTitle
        
        do {
            try viewModel.validateUserInputs()
            
        } catch UserInputError.titleTooShortOrLong {
            
            self.showSimpleBottomAlert(with: UserInputError.titleTooShortOrLong.errorDescription)
            return false
            
        } catch UserInputError.detailTooShortOrLong {
            
            self.showSimpleBottomAlert(with: UserInputError.detailTooShortOrLong.errorDescription)
            return false
            
        } catch { return false }
        
        return true
    }
}

//MARK: - UploadItemDelegate

extension UploadItemViewController: UploadItemDelegate {
    
    func didCompleteUpload() { 
        
        dismissProgressBar()
        print("UploadItemVC - didCompleteUpload")
        navigationController?.popViewController(animated: true)
        let name = Notification.Name(rawValue: Constants.NotificationKey.updateItemList)
        NotificationCenter.default.post(name: name, object: nil)
    }
    
    func failedUploading(with error: NetworkError) {
        
        dismissProgressBar()
        
        print("UploadItemVC - failedUploading: \(error.errorDescription)")
        self.showSimpleBottomAlert(with: "업로드 실패: \(error.errorDescription)")
        navigationController?.popViewController(animated: true)
    }
}

//MARK: - UserPickedItemImageCellDelegate

extension UploadItemViewController: UserPickedItemImageCellDelegate {
    
    func didPressDeleteImageButton(at index: Int) {
        
        viewModel.userSelectedImages.remove(at: index - 1)
        itemImagesCollectionView.reloadData()
    }
    
}

extension UploadItemViewController: AddImageDelegate {
    
    func didPickImagesToUpload(images: [UIImage]) {
        
        viewModel.userSelectedImages = images
        itemImagesCollectionView.reloadData()
    }
}

//MARK: - UICollectionViewDelegate, UICollectionViewDataSource

extension UploadItemViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.userSelectedImages.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let addImageButtonID  = Constants.cellID.addItemImageCell
        let newItemImageID    = Constants.cellID.userPickedItemImageCell
        
        if indexPath.item == 0 {
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: addImageButtonID, for: indexPath) as? AddImageButtonCollectionViewCell else {
                fatalError()
            }
            cell.delegate = self
            return cell
        }
        else {
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: newItemImageID, for: indexPath) as? UserPickedItemImageCollectionViewCell else {
                fatalError()
            }
            cell.delegate = self
            cell.indexPath = indexPath.item
       
            
            if viewModel.userSelectedImages.count > 0 {
                cell.userPickedImageView.image = viewModel.userSelectedImages[indexPath.item - 1]
            }
            return cell
        }
    }
}

//MARK: - UIPickerViewDataSource, UIPickerViewDelegate

extension UploadItemViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return viewModel.locationArray.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return viewModel.locationArray[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        viewModel.location = row
        tradeLocationTextField.text = viewModel.locationArray[row]
    }
}
//MARK: - UITextViewDelegate

extension UploadItemViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
    
        if textView.text.isEmpty {
            textView.text = "공구 내용을 작성해주세요. (중고 거래 또는 크누마켓의 취지와 맞지 않는 글은 게시가 제한될 수 있습니다.) \n\n 게시 가능 글 종류: \n- 배달음식 공구 \n- 온라인 쇼핑 공구 \n- 물물교환 및 나눔"
            textView.textColor = UIColor.lightGray
            return
        }
        viewModel.itemDetail = textView.text
    }
}

//MARK: - UI Configuration & Initialization

extension UploadItemViewController {
    
    func initialize() {
        
        viewModel.delegate = self
        
        let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        
        initializeCollectionView()
        initializeStepper()
        initializePickerView()
        initializeTextView()
        
        if self.editModel != nil {
            configurePageWithPriorData()
        }
    }
    
    func initializeCollectionView() {
        
        itemImagesCollectionView.delegate = self
        itemImagesCollectionView.dataSource = self
    }
    
    func initializeStepper() {
        
        stepper.value = 2
        stepper.minimumValue = 2
        stepper.maximumValue = 10
        stepper.stepValue = 1
        stepper.buttonsTextColor = .white
        stepper.buttonsBackgroundColor = UIColor(named: Constants.Color.appColor)!
        stepper.buttonsFont = UIFont(name: "AvenirNext-Bold", size: 15.0)!
        stepper.labelFont = .systemFont(ofSize: 15)
        stepper.labelTextColor = UIColor(named:Constants.Color.appColor)!

        stepper.labelBackgroundColor = UIColor.systemGray6
        stepper.limitHitAnimationColor = .white
        stepper.cornerRadius = 5
    }
    
    func initializePickerView() {
        
        let pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        
        expandButton.inputView = pickerView
        tradeLocationTextField.inputView = pickerView
        
    }
    
    func initializeTextView() {
        
        itemDetailTextView.delegate = self
        itemDetailTextView.layer.borderWidth = 1.0
        itemDetailTextView.layer.cornerRadius = 10.0
        itemDetailTextView.layer.borderColor = UIColor.lightGray.cgColor
        itemDetailTextView.clipsToBounds = true
        itemDetailTextView.text = "공구 내용을 작성해주세요. (중고 거래 또는 크누마켓의 취지와 맞지 않는 글은 게시가 제한될 수 있습니다.) \n\n 게시 가능 글 종류: \n- 배달음식 공구 \n- 온라인 쇼핑 공구 \n- 물물교환 및 나눔"
        itemDetailTextView.textColor = UIColor.lightGray
    }

    
    func configurePageWithPriorData() {
        
        print("✏️ configurePageWithPriorData ACTIVATED")
      
        itemTitleTextField.text = editModel!.title
        
        // 현재 모집된 인원이 1명이면, 최소 모집 인원인 2명으로 자동 설정할 수 있게끔 실행
        stepper.minimumValue = editModel!.currentlyGatheredPeople == 1 ? 2 : Double(editModel!.currentlyGatheredPeople)
        stepper.value = Double(editModel!.currentlyGatheredPeople)
        
        totalGatheringPeopleLabel.text = String(editModel!.totalGatheringPeople)
        tradeLocationTextField.text = self.viewModel.locationArray[editModel!.location]
        
        itemDetailTextView.text = editModel!.itemDetail
        itemDetailTextView.textColor = UIColor.black
        
        // 이미지 url 이 있으면 실행
        if let imageURLs = editModel!.imageURLs {
            self.viewModel.editImageURLs = imageURLs
        }
       
        
    }
    
}
