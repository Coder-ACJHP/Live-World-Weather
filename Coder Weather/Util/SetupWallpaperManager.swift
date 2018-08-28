//
//  SetupWallpaperManager.swift
//  Coder Weather
//
//  Created by Coder ACJHP on 28.08.2018.
//  Copyright © 2018 Coder ACJHP. All rights reserved.
//

import UIKit

class SetupWallpaperManager: NSObject {
    
    var imgView: UIImageView!
    private var timer: Timer!
    public var wallpaper: UIImage!
    private let userSettings = Setting.shared
    public static let shared = SetupWallpaperManager()
    private let staticDatas = StaticDatas.sharedInstance

    public func setImageView(imgeView: UIImageView) {
        self.imgView = imgeView
    }
    
    public func setupWallpaper() {
        if !userSettings.getAutoChangeWallpaperStatus() {
            let image: UIImage? = userSettings.getWallpaper()
            if image != nil {
                wallpaper = image
            } else {
                // Set default image
                wallpaper = #imageLiteral(resourceName: "blue-cloud")
            }
            imgView.image = wallpaper
            
        } else {
            // Change wallpaper every 30 minutes
            let oneHourInterval = TimeInterval(30 * 60)
            self.timer = Timer.scheduledTimer(timeInterval: oneHourInterval, target: self, selector: #selector(autoChangeWallpaper), userInfo: nil, repeats: true)
            timer.fire()
        }
    }
    
    @objc public func autoChangeWallpaper() {
        UIView.animate(withDuration: 0.4) {
            self.imgView.image = self.staticDatas.imageList.random()
        }
    }
}
