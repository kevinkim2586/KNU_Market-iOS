import UIKit
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit
import BSImagePicker
import Photos

class StudentIdVerificationViewController: BaseViewController, View {
    
    typealias Reactor = StudentIdVerificationViewReactor
    
    //MARK: - Properties

    
    //MARK: - Constants
    
    fileprivate struct Metrics {
        static let labelSidePadding = 30.f
        static let textFieldHeight  = 60.f
    }
    
    fileprivate struct Fonts {
        static let titleLabels       = UIFont.systemFont(ofSize: 19, weight: .semibold)
    }
    
    fileprivate struct Images {
        static let plusImage        = UIImage(systemName: "plus")?.withRenderingMode(.alwaysOriginal).withTintColor(.black)
    }
    
    fileprivate struct Texts {
        static let alertMessage     = "첨부하신 학생증은 입력하신 정보 (학번, 생년월일)와의 대조를 위해서만 사용되며, 크누마켓은 절대 이를 원본으로 수집하지 않습니다.\n입력된 정보와 학생증 내의 정보가 일치하지 않을 시, 크누마켓 이용이 제한됩니다."
    }
    
    //MARK: - UI
    
    let studentIdLabel = UILabel().then {
        $0.font = Fonts.titleLabels
        $0.textColor = UIColor(named: K.Color.appColor)
        $0.text = "학번"
    }
    
    let studentIdTextField = KMTextField(placeHolderText: "학번을 입력해주세요")
    
    let checkDuplicateButton = UIButton(type: .system).then {
        $0.layer.cornerRadius = 6
        $0.setTitle("중복 확인", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        $0.backgroundColor = UIColor(named: K.Color.appColor)
        $0.addBounceAnimation()
    }
    
    let birthDateLabel = UILabel().then {
        $0.font = Fonts.titleLabels
        $0.textColor = UIColor(named: K.Color.appColor)
        $0.text = "생년월일"
    }
    
    let birthDateTextField = KMTextField(placeHolderText: "생년월일 6자리 (예:981121)")
    
    let captureLabel = UILabel().then {
        $0.font = Fonts.titleLabels
        $0.textColor = UIColor(named: K.Color.appColor)
        $0.text = "모바일 학생증 캡쳐"
    }
    
    let captureGuideLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 16,weight: .medium)
        $0.textColor = .black
        $0.text = "반드시 학번, 생년월일이 보이게 캡쳐해주세요."
    }
    
    let selectImageButton = UIButton(type: .system).then {
        $0.setImage(Images.plusImage, for: .normal)
        $0.widthAnchor.constraint(equalToConstant: 90).isActive = true
        $0.heightAnchor.constraint(equalToConstant: 90).isActive = true
        $0.layer.borderWidth = 0.5
        $0.layer.borderColor = UIColor.lightGray.cgColor
        $0.layer.cornerRadius = 6
    }
    
    let studentIdImageView = UIImageView().then {
        $0.image = UIImage(named: K.Images.chatBubbleIcon)
        $0.widthAnchor.constraint(equalToConstant: 90).isActive = true
        $0.heightAnchor.constraint(equalToConstant: 90).isActive = true
        $0.contentMode = .scaleAspectFill
        $0.layer.borderWidth = 0.5
        $0.layer.borderColor = UIColor.lightGray.cgColor
        $0.layer.cornerRadius = 6
        $0.clipsToBounds = true
    }
    
    lazy var captureStudentIdStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalCentering
        stackView.spacing = 60
        [selectImageButton, studentIdImageView].forEach { stackView.addArrangedSubview($0) }
        return stackView
    }()
    
    lazy var captureStudentIdView: UIView = {
        let view = UIView()
        view.layer.borderWidth = 0.5
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.cornerRadius = 6
        view.addSubview(captureStudentIdStackView)
        captureStudentIdStackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        return view
    }()
    
    let bottomButton = KMBottomButton(buttonTitle: "인증 완료하기").then {
        $0.heightAnchor.constraint(equalToConstant: $0.heightConstantForKeyboardHidden).isActive = true
        $0.setTitle("인증 완료하기", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
    }
    
    let imagePicker = ImagePickerController().then {
        $0.modalPresentationStyle = .fullScreen
        $0.settings.selection.max = 1
        $0.settings.theme.selectionStyle = .numbered
        $0.settings.fetch.assets.supportedMediaTypes = [.image]
        $0.settings.theme.selectionFillColor = UIColor(named: K.Color.appColor)!
        $0.doneButton.tintColor = UIColor(named: K.Color.appColor)!
        $0.doneButtonTitle = "완료"
        $0.cancelButton.tintColor = UIColor(named: K.Color.appColor)!
    }
    
    //MARK: - Initialization
    
    init(reactor: Reactor) {
        super.init()
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "모바일 학생증 인증"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        studentIdTextField.becomeFirstResponder()
    }
    
    //MARK: - UI Setup
    override func setupLayout() {
        super.setupLayout()
        
        view.addSubview(studentIdLabel)
        view.addSubview(studentIdTextField)
        view.addSubview(checkDuplicateButton)
        view.addSubview(birthDateLabel)
        view.addSubview(birthDateTextField)
        view.addSubview(captureLabel)
        view.addSubview(captureGuideLabel)
        view.addSubview(captureStudentIdView)
        view.addSubview(bottomButton)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        studentIdLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(35)
            $0.left.equalTo(view.snp.left).offset(Metrics.labelSidePadding)
            $0.right.equalTo(view.snp.right).offset(-Metrics.labelSidePadding)
        }
        
        checkDuplicateButton.snp.makeConstraints { 
            $0.width.equalTo(80)
            $0.right.equalTo(view.snp.right).offset(-Metrics.labelSidePadding)
            $0.top.equalTo(studentIdLabel.snp.bottom).offset(35)
        }
        
        studentIdTextField.snp.makeConstraints {
            $0.top.equalTo(studentIdLabel.snp.bottom).offset(6)
            $0.left.equalTo(view.snp.left).offset(Metrics.labelSidePadding)
            $0.height.equalTo(Metrics.textFieldHeight)
        }
        
        birthDateLabel.snp.makeConstraints {
            $0.top.equalTo(studentIdTextField.snp.bottom).offset(20)
            $0.left.equalTo(view.snp.left).offset(Metrics.labelSidePadding)
            $0.right.equalTo(view.snp.right).offset(-Metrics.labelSidePadding)
        }
        
        birthDateTextField.snp.makeConstraints {
            $0.top.equalTo(birthDateLabel.snp.bottom).offset(6)
            $0.left.equalTo(view.snp.left).offset(Metrics.labelSidePadding)
            $0.height.equalTo(Metrics.textFieldHeight)
        }
        
        captureLabel.snp.makeConstraints {
            $0.top.equalTo(birthDateTextField.snp.bottom).offset(20)
            $0.left.equalTo(view.snp.left).offset(Metrics.labelSidePadding)
            $0.right.equalTo(view.snp.right).offset(-Metrics.labelSidePadding)
        }
        
        captureGuideLabel.snp.makeConstraints {
            $0.top.equalTo(captureLabel.snp.bottom).offset(10)
            $0.left.equalTo(view.snp.left).offset(Metrics.labelSidePadding)
            $0.right.equalTo(view.snp.right).offset(-Metrics.labelSidePadding)
        }

        bottomButton.snp.makeConstraints {
            $0.bottom.equalToSuperview()
            $0.left.equalTo(view.snp.left)
            $0.right.equalTo(view.snp.right)
            $0.height.equalTo(bottomButton.heightConstantForKeyboardHidden)
        }
        
        captureStudentIdView.snp.makeConstraints {
            $0.top.equalTo(captureGuideLabel.snp.bottom).offset(15)
            $0.left.equalTo(view.snp.left).offset(Metrics.labelSidePadding)
            $0.right.equalTo(view.snp.right).offset(-Metrics.labelSidePadding)
            $0.bottom.equalTo(bottomButton.snp.top).offset(-20)
        }
    }
    
    override func setupStyle() {
        super.setupStyle()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }

                            
    //MARK: - Binding
    
    func bind(reactor: StudentIdVerificationViewReactor) {
        
        // Input
        
        studentIdTextField.rx.text
            .orEmpty
            .asObservable()
            .map { Reactor.Action.updateStudentId($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        birthDateTextField.rx.text
            .orEmpty
            .asObservable()
            .map { Reactor.Action.updateStudentBirthDate($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        studentIdTextField.rx.controlEvent([.editingDidBegin])
            .asObservable()
            .map { Reactor.Action.textFieldChanged }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        checkDuplicateButton.rx.tap
            .map { Reactor.Action.checkStudentIdDuplication }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        selectImageButton.rx.tap
            .flatMap { [unowned self] in
                self.presentAlert(title: "안내드립니다.", message: Texts.alertMessage)
            }
            .asObservable()
            .withUnretained(self)
            .subscribe(onNext: { _ in
                self.presentImagePicker()
            })
            .disposed(by: disposeBag)
        
        bottomButton.rx.tap
            .asObservable()
            .map { Reactor.Action.verifyStudentId }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // Output
        
        reactor.state
            .map { $0.studentIdImage }
            .distinctUntilChanged()
            .bind(to: studentIdImageView.rx.image)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.alertMessage }
            .filter { $0 != nil }
            .withUnretained(self)
            .subscribe { (_, alertMessage) in
                self.view.endEditing(true)
                self.showSimpleBottomAlert(with: alertMessage!)
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.isVerified }
            .distinctUntilChanged()
            .filter { $0 == true }
            .withUnretained(self)
            .subscribe(onNext: { _ in
                self.view.endEditing(true)
                self.showSimpleBottomAlertWithAction(
                    message:  "인증 완료되었습니다😁",
                    buttonTitle: "홈으로"
                ) {
                    if let vcPopCount = self.navigationController?.viewControllers.count {
                        self.popVCsFromNavController(count: vcPopCount - 1)
                    }
                }
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.isLoading }
            .distinctUntilChanged()
            .subscribe(onNext: {
                $0 ? showProgressBar() : dismissProgressBar()
            })
            .disposed(by: disposeBag)
    }
}

extension StudentIdVerificationViewController {
    
    func convertAssetToImage(_ assets: [PHAsset]) -> [UIImage] {
        var result: [UIImage] = []
        if assets.count != 0 {
            for i in 0 ..< assets.count {
                let imageManager = PHImageManager.default()
                let option = PHImageRequestOptions()
                option.isSynchronous = true
                var thumbnail = UIImage()
                imageManager.requestImage(
                    for: assets[i],
                       targetSize: CGSize(width: 1000, height: 1000),
                       contentMode: .aspectFill,
                       options: option
                ) {
                    (result, _) in
                    thumbnail = result!
                }
                
                let data = thumbnail.jpegData(compressionQuality: 1)
                let newImage = UIImage(data: data!)
                result.append(newImage! as UIImage)
            }
        }
        return result
    }
    
    func presentImagePicker() {
        
        presentImagePicker(self.imagePicker, select: {
            (asset) in
        }, deselect: {
            (asset) in
        }, cancel: {
            (assets) in
        }, finish: {
            [weak self] (assets) in
            guard let self = self else { return }
            Observable<[UIImage]>.just(self.convertAssetToImage(assets))
                .map { Reactor.Action.updateStudentIdImage($0[0]) }
                .bind(to: self.reactor!.action )
                .disposed(by: self.disposeBag)
        })
    }
}
