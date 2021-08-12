import UIKit

extension UILabel {
    
    func changeTextAttributeColor(fullText : String , changeText : String ) {
        let strNumber: NSString = fullText as NSString
        let range = (strNumber).range(of: changeText)
        let attribute = NSMutableAttributedString.init(string: fullText)
        attribute.addAttribute(NSAttributedString.Key.foregroundColor,
                               value: UIColor(named: Constants.Color.appColor)! ,
                               range: range)
        self.attributedText = attribute
    }
}
