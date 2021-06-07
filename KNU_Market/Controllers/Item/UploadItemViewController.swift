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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialize()
    }
    
    @IBAction func pressedStepper(_ sender: GMStepper) {
        totalGatheringPeopleLabel.text = "\(String(Int(stepper.value))) 명"
    }
    
    @IBAction func pressedFinishButton(_ sender: UIBarButtonItem) {
        
        itemDetailTextView.resignFirstResponder()
        
        if !validateUserInput() { return }
        
        self.presentAlertWithCancelAction(title: "작성하신 글을 올리시겠습니까?", message: "") { selectedOk in
            
            if selectedOk {
                
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
            
            SnackBar.make(in: self.view,
                          message: UserInputError.titleTooShortOrLong.errorDescription,
                          duration: .lengthLong).show()
            return false
        }
        viewModel.itemTitle = itemTitle
        
        do {
            try viewModel.validateUserInputs()
            
        } catch UserInputError.titleTooShortOrLong {
            
            SnackBar.make(in: self.view,
                          message: UserInputError.titleTooShortOrLong.errorDescription,
                          duration: .lengthLong).show()
            return false
            
        } catch UserInputError.detailTooShortOrLong {
            SnackBar.make(in: self.view,
                          message: UserInputError.detailTooShortOrLong.errorDescription,
                          duration: .lengthLong).show()
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
    }
    
    func failedUploading(with error: NetworkError) {
        
        dismissProgressBar()
        
        print("UploadItemVC - failedUploading: \(error.errorDescription)")
        
        SnackBar.make(in: self.view,
                      message: "업로드 실패: \(error.errorDescription)",
                      duration: .lengthLong).show()
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
                fatalError("Failed to dequeue cell for AddImageButtonCollectionViewCell")
            }
            cell.delegate = self
            return cell
        }
        else {
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: newItemImageID, for: indexPath) as? UserPickedItemImageCollectionViewCell else {
                fatalError("Failed to dequeue cell for UserPickedFoodImageCollectionViewCell")
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
            textView.text = "공구 내용을 작성해주세요. (중고 거래 또는 크누마켓의 취지와 맞지 않는 글은 게시가 제한될 수 있습니다.)"
            textView.textColor = UIColor.lightGray
            return
        }
        viewModel.itemDetail = textView.text
    }
}

//MARK: - UI Configuration

extension UploadItemViewController {
    
    func initialize() {
        
        viewModel.delegate = self
        
        let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        
        initializeCollectionView()
        initializeStepper()
        initializePickerView()
        initializeTextView()
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
        stepper.buttonsBackgroundColor = UIColor(named: "AppDefaultColor")!
        stepper.buttonsFont = UIFont(name: "AvenirNext-Bold", size: 15.0)!
        stepper.labelFont = .systemFont(ofSize: 15)
        stepper.labelTextColor = UIColor(named:Constants.Color.appColor)!

        stepper.labelBackgroundColor = #colorLiteral(red: 0.9050354388, green: 0.9050354388, blue: 0.9050354388, alpha: 1)
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
        itemDetailTextView.text = "공구 내용을 작성해주세요. (중고 거래 또는 크누마켓의 취지와 맞지 않는 글은 게시가 제한될 수 있습니다.)"
        itemDetailTextView.textColor = UIColor.lightGray
    }
    
}
