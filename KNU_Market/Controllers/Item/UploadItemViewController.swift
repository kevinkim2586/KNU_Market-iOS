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
        viewModel.totalPeopleGathering = Int(stepper.value)
    }
    
    @IBAction func pressedFinishButton(_ sender: UIBarButtonItem) {
        
        itemDetailTextView.resignFirstResponder()
        
        if !validateUserInput() { return }
        
        if self.editModel != nil {
            askToUpdatePost()
        } else {
            askToUploadPost()
        }
        

    }

    func askToUploadPost() {
        
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
    
    func askToUpdatePost() {
        
        self.presentAlertWithCancelAction(title: "수정하시겠습니까?",
                                          message: "") { selectedOk in
            
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
        
        print("✏️ UploadItemVC - didCompleteUpload")
        dismissProgressBar()
        navigationController?.popViewController(animated: true)
        NotificationCenter.default.post(name: Notification.Name.updateItemList, object: nil)
    }
    
    func failedUploading(with error: NetworkError) {
        
        print("✏️ UploadItemVC - failedUploading: \(error.errorDescription)")
        dismissProgressBar()
        self.showSimpleBottomAlert(with: "업로드 실패: \(error.errorDescription)")
        navigationController?.popViewController(animated: true)
    }
    
    func didUpdatePost() {
        
        print("✏️ UploadItemVC - didUpdatePost")
        dismissProgressBar()
        navigationController?.popViewController(animated: true)
    }
    
    func failedUpdatingPost(with error: NetworkError) {

        print("✏️ UploadItemVC - failedUpdatingPost: \(error.errorDescription)")
        dismissProgressBar()
        self.showSimpleBottomAlert(with: NetworkError.E000.errorDescription)
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
        createObservers()
        
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
        stepper.buttonsFont = UIFont.systemFont(ofSize: 15, weight: .semibold)
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
        itemDetailTextView.layer.borderWidth = 0.7
        itemDetailTextView.layer.cornerRadius = 5.0
        itemDetailTextView.layer.borderColor = UIColor.lightGray.cgColor
        itemDetailTextView.clipsToBounds = true
        itemDetailTextView.text = "공구 내용을 작성해주세요. (중고 거래 또는 크누마켓의 취지와 맞지 않는 글은 게시가 제한될 수 있습니다.) \n\n 게시 가능 글 종류: \n- 배달음식 공구 \n- 온라인 쇼핑 공구 \n- 물물교환 및 나눔"
        itemDetailTextView.textColor = UIColor.lightGray
    }

    
    func configurePageWithPriorData() {
        
 
        viewModel.editPostModel = editModel
        
        viewModel.itemTitle = editModel!.title
        viewModel.location = editModel!.location
        viewModel.totalPeopleGathering = editModel!.totalGatheringPeople
        viewModel.itemDetail = editModel!.itemDetail
        viewModel.currentlyGatheredPeople = editModel!.currentlyGatheredPeople
        
        // 이미지 url 이 있으면 실행
        if let imageURLs = editModel!.imageURLs, let imageUIDs = editModel!.imageUIDs {
            self.viewModel.priorImageURLs = imageURLs
            self.viewModel.priorImageUIDs = imageUIDs
        }
    
        itemTitleTextField.text = editModel!.title
        
        // 현재 모집된 인원이 1명이면, 최소 모집 인원인 2명으로 자동 설정할 수 있게끔 실행
        stepper.minimumValue = editModel!.currentlyGatheredPeople == 1 ? 2 : Double(editModel!.currentlyGatheredPeople)
        stepper.value = Double(editModel!.currentlyGatheredPeople)
        
        totalGatheringPeopleLabel.text = String(editModel!.totalGatheringPeople) + " 명"
        tradeLocationTextField.text = self.viewModel.locationArray[editModel!.location]
        
        itemDetailTextView.text = editModel!.itemDetail
        itemDetailTextView.textColor = UIColor.black
    
    }
    
    func createObservers() {
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(presentVerifyEmailVC),
                                               name: Notification.Name.presentVerifyEmailVC,
                                               object: nil)
    }
    
}
