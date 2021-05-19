import Foundation
import ProgressHUD

func showProgressBar() {
    ProgressHUD.animationType = .circleRotateChase
    ProgressHUD.colorAnimation = UIColor(named: Constants.Color.appColor) ?? .systemGray
    ProgressHUD.show()
}

func dismissProgressBar() {
    ProgressHUD.dismiss()
}
