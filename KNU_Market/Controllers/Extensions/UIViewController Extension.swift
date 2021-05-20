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
    
    func presentAlertWithCancelAction(title: String, message: String, completion: @escaping ((Bool) -> Void)) {
        
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "확인",
                                     style: .default) { pressedOk in
            completion(true)
        }
        let cancelAction = UIAlertAction(title: "취소",
                                         style: .cancel) { pressedCancel in
            completion(false)
        }
        
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
    
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showToast(message : String, font: UIFont = .systemFont(ofSize: 14.0)) {

        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75,
                                               y: self.view.frame.size.height-150,
                                               width: 150,
                                               height: 35))
        
        toastLabel.backgroundColor = .white
        toastLabel.textColor = UIColor.black
        toastLabel.font = font
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        toastLabel.layer.borderWidth = 1
        toastLabel.layer.borderColor = UIColor.black.cgColor
        
        self.view.addSubview(toastLabel)
        
        UIView.animate(withDuration: 4.0,
                       delay: 0.1,
                       options: .curveEaseOut,
                       animations: { toastLabel.alpha = 0.0 },
                       completion: { isCompleted in
                        toastLabel.removeFromSuperview()
                       })
    }
}
 
