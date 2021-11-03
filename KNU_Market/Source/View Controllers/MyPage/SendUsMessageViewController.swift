import UIKit
import SnapKit

class SendUsMessageViewController: BaseViewController {
    
    //MARK: - Properties
    
    private var userManager: UserManager?
    
    //MARK: - Constants
    
    fileprivate struct Metric {
        // View
        static let viewSide = 20.f
        
        // title
        static let titleTop = 35.f
    }
    
    fileprivate struct Fonts {
        static let titleFont = UIFont.systemFont(ofSize: 14, weight: .light)
        static let tintFont = UIFont.systemFont(ofSize: 16, weight: .bold)
    }
    
    fileprivate struct Texts {
        
    }
    
    //MARK: - UI
    let describeLabel: UILabel = {
        let label = UILabel()
        label.text = "저희에게 궁금한 점이 있거나 부탁하고싶은 점을 말해주세요!\n빠른 시일내로 답변드리겠습니다"
        label.adjustsFontSizeToFitWidth = true
        label.font = Fonts.titleFont
        label.numberOfLines = 2
        return label
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "문의 및 건의 내용"
        label.font = Fonts.tintFont
        return label
    }()
    
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
        
        self.view.addSubview(self.describeLabel)
        self.view.addSubview(self.titleLabel)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        self.describeLabel.snp.makeConstraints {
            $0.top.equalToSafeArea(self.view).offset(Metric.titleTop)
            $0.leading.equalToSafeArea(self.view).offset(Metric.viewSide)
            $0.trailing.equalToSafeArea(self.view)
                .offset(-Metric.viewSide)
        }
        
        self.titleLabel.snp.makeConstraints {
            $0.top.equalTo(self.describeLabel.snp.bottom).offset(Metric.titleTop)
            $0.leading.equalToSafeArea(self.view).offset(Metric.viewSide)
            $0.trailing.equalToSafeArea(self.view)
                .offset(-Metric.viewSide)
        }
    }
    
    override func setupStyle() {
        super.setupStyle()
    
        self.title = "크누마켓팀과 대화하기"
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
