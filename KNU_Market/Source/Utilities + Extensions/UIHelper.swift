import UIKit

struct UIHelper {
    
    
    static func addNavigationBarWithDismissButton(in view: UIView, title: String = "") {
        
        var statusBarHeight: CGFloat = 0
        statusBarHeight = UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0

        let naviBar = UINavigationBar(frame: .init(
            x: 0,
            y: statusBarHeight,
            width: view.frame.width,
            height: statusBarHeight)
        )
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        naviBar.standardAppearance = appearance
        naviBar.scrollEdgeAppearance = appearance
    
        let naviItem = UINavigationItem(title: title)
        
        // X 버튼
        let stopBarButtonItem =  UIBarButtonItem(
            barButtonSystemItem: .stop,
            target: self,
            action: #selector(UIViewController.dismissVC)
        )
        stopBarButtonItem.tintColor = .black
    
        naviItem.rightBarButtonItem = stopBarButtonItem
        naviBar.items = [naviItem]
        view.addSubview(naviBar)
    }
}
