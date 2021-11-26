import UIKit
import ImageSlideshow
import SDWebImage

class PhotoDetailViewController: UIViewController {
    
    @IBOutlet weak var slideShow: ImageSlideshow!
    
    var imageURLs: [URL] = [URL]()
    
    var imageSources: [InputSource] = [InputSource]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }

    func initialize() {
        
        initializeImageSources()
        initializeSlideShow()
    }
    
    func initializeImageSources() {
        
        for url in imageURLs {
            imageSources.append(SDWebImageSource(url: url,
                                                 placeholder: UIImage(named: K.Images.defaultItemImage)))
            
        }
    }
    
    func initializeSlideShow() {
        
        slideShow.setImageInputs(imageSources)
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(self.didTap))
        
        slideShow.addGestureRecognizer(recognizer)
    }
    
    @objc func didTap() {
        let fullScreenController = slideShow.presentFullScreenController(from: self)
        fullScreenController.slideshow.activityIndicator = DefaultActivityIndicator(style: .gray, color: nil)
    }
    
}


