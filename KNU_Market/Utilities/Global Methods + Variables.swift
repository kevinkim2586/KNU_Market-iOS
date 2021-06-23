import Foundation
import ProgressHUD
import SnackBar_swift

//MARK: - Progress Bar related methods
func showProgressBar() {
    ProgressHUD.animationType = .circleRotateChase
    ProgressHUD.colorAnimation = UIColor(named: Constants.Color.appColor) ?? .systemGray
    ProgressHUD.show()
}

func dismissProgressBar() {
    ProgressHUD.dismiss()
}


struct GlobalVariable {
    
    static var needsToReloadData: Bool = false
}
