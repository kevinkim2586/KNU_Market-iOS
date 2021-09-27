import UIKit

extension UILabel {
    
    // UILabel 특정 부분만 색상 바꾸기
    func changeTextAttributeColor(
        fullText : String,
        changeText : String,
        toColor: UIColor? = UIColor(named: Constants.Color.appColor)
    ) {
        let strNumber: NSString = fullText as NSString
        let range = (strNumber).range(of: changeText)
        let attribute = NSMutableAttributedString.init(string: fullText)
        attribute.addAttribute(
            NSAttributedString.Key.foregroundColor,
            value: UIColor(named: Constants.Color.appColor)! ,
            range: range
        )
        self.attributedText = attribute
    }
    
    /// 입력된 포지션에 따라 라벨의 문자열의 인덱스 반환
    /// - Parameter point: 인덱스 값을 알고 싶은 CGPoint
    func textIndex(at point: CGPoint) -> Int? {
          guard let attributedText = attributedText else { return nil }

          let layoutManager = NSLayoutManager()
          let textContainer = NSTextContainer(size: self.bounds.size)
          let textStorage = NSTextStorage(attributedString: attributedText)
          
          textStorage.addLayoutManager(layoutManager)
          textContainer.lineFragmentPadding = 0.0
          layoutManager.addTextContainer(textContainer)

          var textOffset = CGPoint.zero
          // 정확한 자체(glyph)의 범위를 구하고 그 범위의 CGRect 값을 구합니다.
          let range = layoutManager.glyphRange(for: textContainer)
          let textBounds = layoutManager.boundingRect(
              forGlyphRange: range,
              in: textContainer
          )
          
          // textOffset.x가 패딩을 제외한 부분부터 시작하도록 합니다.
          let paddingWidth = (self.bounds.size.width - textBounds.size.width) / 2
          if paddingWidth > 0 {
              textOffset.x = paddingWidth
          }
          
          // 눌려진 정확한 포인트를 구합니다.
          let newPoint = CGPoint(
              x: point.x - textOffset.x,
              y: point.y - textOffset.y
          )

          // textContainer내에서 newPoint 위치의 glyph index를 반환합니다
          return layoutManager.glyphIndex(for: newPoint, in: textContainer)
      }
    

}
