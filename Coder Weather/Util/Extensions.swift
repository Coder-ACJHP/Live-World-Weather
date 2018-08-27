//
//  Extensions.swift
//  Coder Weather
//
//  Created by akademobi5 on 9.08.2018.
//  Copyright © 2018 Coder ACJHP. All rights reserved.
//

import UIKit
// Remove duplicated elements from array
extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        var addedDict = [Element: Bool]()
        
        return filter {
            addedDict.updateValue(true, forKey: $0) == nil
        }
    }
    
    mutating func removeDuplicates() {
        self = self.removingDuplicates()
    }
}
// Add new notification name
extension Notification.Name {
    static let changeBackGround = Notification.Name.init("ChangeWallpaper")
    static let autoChangeBackGround = Notification.Name.init("AutoChangeWallpaper")
    static let sendPushNotification = Notification.Name.init("CanSendPushNotification")
}
// Select random element from array
extension Array {
    func random() -> Element {
        return self[Int(arc4random_uniform(UInt32(self.count)))]
    }
}
// Get centered cell
extension UICollectionView {
    var centerPoint : CGPoint {
        get {
            return CGPoint(x: self.center.x + self.contentOffset.x, y: self.center.y + self.contentOffset.y);
        }
    }
    var centerCellIndexPath: IndexPath? {
        if let centerIndexPath = self.indexPathForItem(at: self.centerPoint) {
            return centerIndexPath
        }
        return nil
    }
}
