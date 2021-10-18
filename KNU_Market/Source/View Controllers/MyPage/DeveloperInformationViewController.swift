import UIKit
import SnapKit

class DeveloperInformationViewController: BaseViewController {
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: K.Images.developerInfo)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "팀 정보"
    }
    
    override func setupLayout() {
        view.addSubview(imageView)
    }
    
    override func setupConstraints() {
        imageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    override func setupStyle() {
        super.setupStyle()
        view.backgroundColor = .white
    }
    
}


#if canImport(SwiftUI) && DEBUG
import SwiftUI

@available(iOS 13.0, *)
struct DeveloperInfoVC: PreviewProvider {
    
    static var previews: some View {
        DeveloperInformationViewController().toPreview()
    }
}
#endif
