import UIKit
import SnapKit

class SendUsMessageViewController: BaseViewController {
    
    //MARK: - Properties
    
    private var userManager: UserManager?
    
    //MARK: - Constants
    
    fileprivate struct Metric {
        static let viewSide = 20.f
    }
    
    fileprivate struct Fonts {
        
    }
    
    fileprivate struct Texts {
        
    }
    
    //MARK: - UI
    
    
    //MARK: - Initialization
    
    init(userManager: UserManager) {
        super.init()
        self.userManager = userManager
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: - UI Setup

    override func setupLayout() {
        super.setupLayout()
        
        self.title = "크누마켓팀과 대화하기"
        
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
    }
    
    override func setupStyle() {
        super.setupStyle()
    
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
}

//MARK: - Actions

extension SendUsMessageViewController {
    
}

//MARK: - UITextViewDelegate

extension SendUsMessageViewController: UITextViewDelegate {
    
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI

@available(iOS 13.0, *)
struct SendUsMessageVC: PreviewProvider {
    
    static var previews: some View {
        SendUsMessageViewController(userManager: UserManager()).toPreview()
    }
}
#endif
