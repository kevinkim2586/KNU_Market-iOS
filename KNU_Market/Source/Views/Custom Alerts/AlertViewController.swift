import UIKit

class AlertViewController: UIViewController {
    
    let containerView   = UIView()
    let titleLabel      = KMAlertTitleLabel(textAlignment: .center, fontSize: 20)
    var messageLabel    = KMAlertBodyLabel(textAlignment: .center)
    let actionButton    = KMAlertButton(backgroundColor: UIColor(named: K.Color.appColor)!, title: "확인")

    var alertTitle: String?
    var message: String?
    var buttonTitle: String?
    var attributedMessageString: NSAttributedString?
    
    let padding: CGFloat = 20
    
    init(title: String, message: String, buttonTitle: String, attributedMessageString: NSAttributedString? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.alertTitle = title
        self.message = message
        self.buttonTitle = buttonTitle
        if let attributedMessageString = attributedMessageString {
            self.attributedMessageString = attributedMessageString
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.75)
        configureContainerView()
        configureTitleLabel()
        configureActionButton()
        configureMessageLabel()
    }
    
    func configureContainerView() {
        view.addSubview(containerView)
        containerView.backgroundColor = .systemBackground
        containerView.layer.cornerRadius = 16
        containerView.layer.borderWidth = 2
        containerView.layer.borderColor = UIColor.white.cgColor
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 280),
            containerView.heightAnchor.constraint(equalToConstant: 220)
        ])
    }
    
    func configureTitleLabel() {
        containerView.addSubview(titleLabel)
        titleLabel.text = alertTitle ?? "표시 오류"
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: padding),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: padding),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -padding),
            titleLabel.heightAnchor.constraint(equalToConstant: 28)
        ])
    }
    
    func configureMessageLabel() {
        containerView.addSubview(messageLabel)
        
        if let attributedMessageString = attributedMessageString {
            messageLabel.attributedText = attributedMessageString
        } else {
            messageLabel.text = message ?? "표시 오류"
        }
        messageLabel.numberOfLines = 5
        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            messageLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: padding),
            messageLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -padding),
            messageLabel.bottomAnchor.constraint(equalTo: actionButton.topAnchor, constant: -12)
        ])
    }
    
    func configureActionButton() {
        containerView.addSubview(actionButton)
        actionButton.setTitle(buttonTitle ?? "확인", for: .normal)
        actionButton.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
        actionButton.addBounceAnimationWithNoFeedback()
        
        NSLayoutConstraint.activate([
            actionButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -padding),
            actionButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: padding),
            actionButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -padding),
            actionButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    

}
