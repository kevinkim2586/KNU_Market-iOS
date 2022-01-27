import UIKit
import SnapKit
import Then

class DeveloperInformationViewController: BaseViewController {
    
    let imageView = UIImageView().then {
        $0.image = UIImage(named: K.Images.developerInfo)
        $0.contentMode = .scaleAspectFit
    }

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
