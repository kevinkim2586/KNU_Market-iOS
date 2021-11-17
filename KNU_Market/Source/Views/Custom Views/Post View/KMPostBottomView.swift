import UIKit
import SnapKit

protocol KMPostBottomViewDelegate: AnyObject {
    func didPressEnterChatButton()
}

class KMPostBottomView: UIView {
    
    //MARK: - Properties
    
    weak var delegate: KMPostBottomViewDelegate?
    
    //MARK: - Constants
    
    fileprivate struct Metrics {
        static let personImageViewSize: CGFloat = 20
    }
    
    //MARK: - UI
    
    let gatheringPeopleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.text = "모집 완료"
        label.numberOfLines = 1
        label.textColor = .black
        return label
    }()
    
    let personImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: K.Images.peopleIcon)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    lazy var enterChatButton: UIButton = {
        let button = UIButton()
        button.setTitle("모집 완료", for: .normal)
        button.layer.cornerRadius = 7
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        button.titleLabel?.textColor = .white
        button.addTarget(
            self,
            action: #selector(pressedEnterChatButton),
            for: .touchUpInside
        )
        button.addBounceAnimation()
        return button
    }()
    
    //MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        addTopBorder(with: .systemGray6, andWidth: 0.8)
        setupLayout()
        setupConstraints()
    }
    
 
    required init?(coder: NSCoder) {
        fatalError()
    }
        
    //MARK: - UI Setup
    
    private func setupLayout() {
        
        addSubview(gatheringPeopleLabel)
        addSubview(personImageView)
        addSubview(enterChatButton)
    }
    
    private func setupConstraints() {
        
        gatheringPeopleLabel.snp.makeConstraints {
            $0.left.equalToSuperview().offset(40)
            $0.centerY.equalToSuperview()
        }
        
        personImageView.snp.makeConstraints {
            $0.width.height.equalTo(Metrics.personImageViewSize)
            $0.left.equalTo(gatheringPeopleLabel.snp.right).offset(20)
            $0.centerY.equalToSuperview()
        }
        
        enterChatButton.snp.makeConstraints {
            $0.width.equalTo(170)
            $0.height.equalTo(40)
            $0.right.equalToSuperview().offset(-15)
            $0.centerY.equalToSuperview()
        }
        
    }
    
    //MARK: - Data Configuration
    
    func updateData(
        isPostCompletelyDone: Bool,
        currentCount: Int,
        totalCount: Int,
        enableChatEnterButton: Bool
    ) {
        
        configureGatheringPeopleLabel(
            isPostCompletelyDone: isPostCompletelyDone,
            currentCount: currentCount,
            totalCount: totalCount
        )
        configureEnterChatButton(enableChatEnterButton: enableChatEnterButton)

    }
    
    private func configureGatheringPeopleLabel(
        isPostCompletelyDone: Bool,
        currentCount: Int,
        totalCount: Int
    ) {
        if isPostCompletelyDone {
            gatheringPeopleLabel.text = "모집 완료"
            personImageView.isHidden = true
        } else {
            gatheringPeopleLabel.text = "모집 중    \(currentCount)" + "/" + "\(totalCount)"
            personImageView.isHidden = false
        }
    }
    
    private func configureEnterChatButton(enableChatEnterButton: Bool) {
        
        if enableChatEnterButton {
            enterChatButton.isUserInteractionEnabled = true
            enterChatButton.backgroundColor = UIColor(named: K.Color.appColor)
            enterChatButton.setTitle("채팅방 입장", for: .normal)
            
        } else {
            enterChatButton.isUserInteractionEnabled = false
            enterChatButton.setTitle("모집 완료", for: .normal)
            enterChatButton.backgroundColor = UIColor.lightGray
        }
    }
    
}

//MARK: - Target Methods

extension KMPostBottomView {
    
    @objc private func pressedEnterChatButton() {
        delegate?.didPressEnterChatButton()
    }
}
