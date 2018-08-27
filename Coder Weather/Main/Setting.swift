//
//  File.swift
//  Coder Weather
//
//  Created by Coder ACJHP on 11.08.2018.
//  Copyright © 2018 Coder ACJHP. All rights reserved.
//

import UIKit

enum SettingKeys: String {
    case AllowNotification = "NotificationIsEnabled"
    case AutoChangeWallpaper = "AutoChangeWallpaper"
    case CurrentWallpaper = "CurrentWallpaper"
    case FavoriteList = "Favoritelist"
    
    var description: String {
        return self.rawValue
    }
}

class Setting {
    
    static let shared = Setting()
    
    public func getFavoriteList() -> [Int]? {
        return UserDefaults.standard.array(forKey: SettingKeys.FavoriteList.description) as? [Int]
    }
    
    public func setFavoriteList(favoriteList: [Int]) {
        UserDefaults.standard.set(favoriteList, forKey: SettingKeys.FavoriteList.description)
        UserDefaults.standard.synchronize()
    }
    
    public func setWallpaper(image: UIImage) {
        let imageData = UIImageJPEGRepresentation(image, 1.0)
        UserDefaults.standard.set(imageData, forKey: SettingKeys.CurrentWallpaper.description)
        UserDefaults.standard.synchronize()
    }
    
    public func getWallpaper() -> UIImage? {
        let imageData = UserDefaults.standard.object(forKey: SettingKeys.CurrentWallpaper.description)
        if imageData != nil {
            return UIImage(data: imageData as! Data)
        }
        return #imageLiteral(resourceName: "blue-cloud")
    }
    
    public func setNotificationStatus(isAllowed: Bool) {
         UserDefaults.standard.set(isAllowed, forKey: SettingKeys.AllowNotification.description)
        UserDefaults.standard.synchronize()
    }
    
    public func getNotificationStatus() -> Bool {
        return UserDefaults.standard.bool(forKey: SettingKeys.AllowNotification.description)
    }
    
    public func autoChangeWallpaper(isAllowed: Bool) {
        UserDefaults.standard.set(isAllowed, forKey: SettingKeys.AutoChangeWallpaper.description)
        UserDefaults.standard.synchronize()
    }
    
    public func getAutoChangeWallpaperStatus() -> Bool {
        return UserDefaults.standard.bool(forKey: SettingKeys.AutoChangeWallpaper.description)
    }
}
