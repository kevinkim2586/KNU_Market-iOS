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
    
    func showToast(message : String, font: UIFont) {

        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-150, width: 150, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.font = font
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
             toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}
 
