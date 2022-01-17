//
//  KMTabBarController.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2022/01/14.
//

import UIKit

class KMTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    private var shapeLayer: CALayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.tintColor = UIColor(named: K.Color.appColor) ?? .systemPink
        tabBar.barTintColor = .white
        tabBar.shadowImage = UIImage() // this removes the top line of the tabBar
        tabBar.backgroundImage = UIImage()
        
        
        let tabBarAppearance = UITabBarItem.appearance()
        tabBarAppearance.setTitleTextAttributes([NSAttributedString.Key.font : UIFont(name: K.Fonts.notoSansBold, size: 9)], for: .normal)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        addShape()
    }

    private func addShape() {
        self.tabBar.isTranslucent = true
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = UIBezierPath(
            roundedRect: tabBar.bounds,
            byRoundingCorners: [.topLeft, .topRight],
            cornerRadii: CGSize(width: 20, height: 0.0)).cgPath
        shapeLayer.fillColor = UIColor.white.cgColor
        shapeLayer.shadowPath =  UIBezierPath(roundedRect: tabBar.bounds, cornerRadius: 20).cgPath
        shapeLayer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).cgColor
        shapeLayer.shadowOpacity = 0.5
        shapeLayer.shadowRadius = 5
        shapeLayer.shadowOffset = CGSize(width: 0, height: -6)

        // To improve rounded corner and shadow performance tremendously
        shapeLayer.shouldRasterize = true
        shapeLayer.rasterizationScale = UIScreen.main.scale

        if let oldShapeLayer = self.shapeLayer {
            tabBar.layer.replaceSublayer(oldShapeLayer, with: shapeLayer)
        } else {
            tabBar.layer.insertSublayer(shapeLayer, at: 0)
        }
        self.shapeLayer = shapeLayer
    }
}

