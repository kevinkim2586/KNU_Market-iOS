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


struct Settings {
    
    // HomeViewController의 UITableView가 로딩이 다시 필요한지 판별 
    static var needsToReloadData: Bool = false
}
