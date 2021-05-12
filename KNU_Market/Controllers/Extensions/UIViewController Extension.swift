import Foundation
import UIKit

extension UIViewController {
    
    func presentAlert(title: String, message: String, withCancelAction: Bool, completion: @escaping (Bool) -> Void) {
        
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "확인",
                                     style: .default) { pressedOk in
            completion(true)
        }
        alertController.addAction(okAction)
        
        if withCancelAction {
            let cancelAction = UIAlertAction(title: "취소",
                                             style: .cancel,
                                             handler: nil)
            alertController.addAction(cancelAction)
        } 

        self.present(alertController, animated: true, completion: nil)
    }
}
 
