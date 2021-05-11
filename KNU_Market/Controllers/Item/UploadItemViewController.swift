import UIKit
import Alamofire
import GMStepper

class UploadItemViewController: UIViewController {
    
    @IBOutlet weak var itemTitleTextField: UITextField!
    @IBOutlet var itemImagesCollectionView: UICollectionView!
    @IBOutlet weak var stepper: GMStepper!
    @IBOutlet weak var totalGatheringPeopleLabel: UILabel!
    @IBOutlet weak var tradeLocationTextField: UITextField!
    @IBOutlet weak var expandButton: UITextField!
    
    
    var viewModel = UploadItemViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialize()
    }
    
    @IBAction func pressedStepper(_ sender: GMStepper) {

        totalGatheringPeopleLabel.text = "\(String(Int(stepper.value))) 명"
    
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
        
        let selectedLocation = viewModel.locationArray[row]
        viewModel.location = selectedLocation
        
        tradeLocationTextField.text = selectedLocation
    }
    
    
}

//MARK: - UI Configuration

extension UploadItemViewController {
    
    func initialize() {
        
        initializeCollectionView()
        initializeStepper()
        initializePickerView()
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
        stepper.labelTextColor = UIColor(named: "AppDefaultColor")!
        stepper.labelBackgroundColor = #colorLiteral(red: 0.9050354388, green: 0.9050354388, blue: 0.9050354388, alpha: 1)
        stepper.limitHitAnimationColor = .white
        stepper.cornerRadius = 0
    }
    
    func initializePickerView() {
        
        let pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        
        expandButton.inputView = pickerView
        tradeLocationTextField.inputView = pickerView
        
        
    }
    
}
