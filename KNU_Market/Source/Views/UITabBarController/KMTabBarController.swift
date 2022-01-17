//
//  KMTabBarController.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2022/01/14.
//

import UIKit

class KMTabBarController:   UITabBarController,
                            UITabBarControllerDelegate {
    
    let customTabBarView: UIView = {
        
        let view = UIView(frame: .zero)
        
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.clipsToBounds = true
        
        view.layer.masksToBounds = false
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: -8.0)
        view.layer.shadowOpacity = 0.12
        view.layer.shadowRadius = 10.0
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.tabBar.tintColor = UIColor(named: K.Color.appColor) ?? .systemPink
        self.tabBar.barTintColor = .white
        
        addCustomTabBarView()
        hideTabBarBorder()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        customTabBarView.frame = tabBar.frame
    }
    
    override func viewDidAppear(_ animated: Bool) {
        var newSafeArea = UIEdgeInsets()
        
        newSafeArea.bottom += customTabBarView.bounds.size.height
        self.children.forEach({$0.additionalSafeAreaInsets = newSafeArea})
    }
    
    private func addCustomTabBarView() {
        customTabBarView.frame = tabBar.frame
        view.addSubview(customTabBarView)
        view.bringSubviewToFront(self.tabBar)
    }
    
    func hideTabBarBorder()  {
        let tabBar = self.tabBar
        tabBar.backgroundImage = UIImage.from(color: .clear)
        tabBar.shadowImage = UIImage()
        tabBar.clipsToBounds = true
    }
}

extension UIImage {
    static func from(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
}
