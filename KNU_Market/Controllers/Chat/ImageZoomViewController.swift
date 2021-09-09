import UIKit
import SnapKit
import SDWebImage

class ImageZoomViewController: UIViewController {
    
    let scrollView = UIScrollView()
    let imageView = UIImageView()
    let swipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(_:)))
    
    var imageURL: URL?

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    func configure() {
        
        view.addGestureRecognizer(swipeRecognizer)
        swipeRecognizer.direction = .down
        configureScrollView()
        configureImageView()
        
        
        let button = UIButton()
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)
        
        scrollView.addSubview(button)
//        
//        NSLayoutConstraint.activate([
//            button.widthAnchor.constraint(equalToConstant: 25),
//            button.heightAnchor.constraint(equalToConstant: 25),
//            button.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 10),
//            button.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -10)
//        ])
//        
        
    }
    
    func configureScrollView() {
        
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 3.0
        
        scrollView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.bottom.equalTo(self.view)
        }
    }
    
    func configureImageView() {
        
        imageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
        imageView.sd_setImage(with: imageURL,
                              placeholderImage: nil,
                              options: .continueInBackground,
                              completed: nil)
        imageView.contentMode = .scaleAspectFit
        imageView.addGestureRecognizer(swipeRecognizer)

        
        imageView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.bottom.equalToSuperview()
            make.centerX.centerY.equalToSuperview()
        }
    }
    
    @objc func swipeAction(_ sender: UISwipeGestureRecognizer) {
        print("✏️ swipeAction")
        dismiss(animated: true, completion: nil)
    }
}

//MARK: - UIScrollViewDelegate

extension ImageZoomViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
