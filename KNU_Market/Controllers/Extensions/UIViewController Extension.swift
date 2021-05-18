import Foundation
import UIKit

extension UIViewController {
    
    
    func presentSimpleAlert(title: String, message: String) {
        
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "확인",
                                     style: .default)
        
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func presentAlert(title: String, message: String, withCancelAction: Bool, completion: @escaping ((Bool) -> Void)) {
        
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        
        if withCancelAction {
            
            let okAction = UIAlertAction(title: "확인",
                                         style: .default) { pressedOk in
                completion(true)
            }
            let cancelAction = UIAlertAction(title: "취소",
                                             style: .cancel,
                                             handler: nil)
            
            alertController.addAction(okAction)
            alertController.addAction(cancelAction)
            
        } else {
            let okAction = UIAlertAction(title: "확인",
                                         style: .default,
                                         handler: nil)
            alertController.addAction(okAction)
        }
        

        self.present(alertController, animated: true, completion: nil)
    }
}
 
