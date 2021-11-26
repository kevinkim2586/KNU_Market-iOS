import UIKit
import SDWebImage
import Hero

class ImageViewController: UIViewController {

    @IBOutlet weak var imageScrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!

    var imageURL: URL?
    var heroID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        configureScrollView()
        configureImageView()
    }
    
    @IBAction func pressedDismissButton(_ sender: UIButton) {
        hero.dismissViewController()
    }
    
    func configureScrollView() {
        
        imageScrollView.delegate = self
        imageScrollView.minimumZoomScale = 1.0
        imageScrollView.maximumZoomScale = 3.0
    }
    
    func configureImageView() {

        if let heroID = heroID {
            imageView.heroID = heroID
        }
        imageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
        imageView.sd_setImage(with: imageURL,
                              placeholderImage: nil,
                              options: .continueInBackground,
                              completed: nil)
        imageView.contentMode = .scaleAspectFit
  
    }
    
    @IBAction func handlePanGesture(_ sender: UIPanGestureRecognizer) {
  
        let translation = sender.translation(in: nil)
        let progress = translation.y / 2 / view.bounds.height
        
        switch sender.state {
        
        case .began:
            hero.dismissViewController()
        case .changed:
            Hero.shared.update(progress)
            
            let currentPosition = CGPoint(x: translation.x  + imageView.center.x, y: translation.y + imageView.center.y)
            Hero.shared.apply(modifiers: [.position(currentPosition)], to: imageView)
        default:
            if progress + sender.velocity(in: nil).y / view.bounds.height > 0.2 {
                Hero.shared.finish()
            } else {
                Hero.shared.cancel()
            }
        }
    }
    
 
}

//MARK: - UIScrollViewDelegate

extension ImageViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
