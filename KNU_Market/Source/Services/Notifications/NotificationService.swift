//
//  NotificationService.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2022/01/04.
//

import Foundation
import UIKit

enum NotificationService: NotificationServiceType {
    
    case getBadgeValue

    var name: Notification.Name {
        switch self {
        case .getBadgeValue:
            return Notification.Name.getBadgeValue
        }
    }
}
