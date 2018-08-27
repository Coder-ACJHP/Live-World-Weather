//
//  SettingsController.swift
//  Coder Weather
//
//  Created by akademobi5 on 14.08.2018.
//  Copyright © 2018 Coder ACJHP. All rights reserved.
//

import UIKit
import StoreKit

class SettingsController: UIViewController {

    let userSettings = Setting.shared
    
    @IBOutlet weak var autoChangeBackgroundSwitch: UISwitch!
    @IBOutlet weak var pushNotificationSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        autoChangeBackgroundSwitch.isOn = userSettings.getAutoChangeWallpaperStatus()
        pushNotificationSwitch.isOn = userSettings.getNotificationStatus()

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let identifire = segue.identifier
        
        switch identifire {
        case "toTermsAndConditions":
            let destinationController = segue.destination as! WebViewController
            destinationController.viewTitle = "Terms and conditions"
            destinationController.requestedUrl = self.loadPageURL(pageName: "TermsAndConditions")
        case "toAboutApp":
            let destinationController = segue.destination as! WebViewController
            destinationController.viewTitle = "About application"
            destinationController.requestedUrl = self.loadPageURL(pageName: "AboutApp")
        case "toPrivacyPolicy":
            let destinationController = segue.destination as! WebViewController
            destinationController.viewTitle = "Privacy policy"
            destinationController.requestedUrl = self.loadPageURL(pageName: "Privacy")
        default:
            debugPrint("No another choise!")
        }
    }

    @IBAction func autoChangeBackgroundSwitch(_ sender: UISwitch) {
        if sender.isOn {
            userSettings.autoChangeWallpaper(isAllowed: true)
        } else {
            userSettings.autoChangeWallpaper(isAllowed: false)
        }
    }
    
    @IBAction func enablePushNotificationSwitch(_ sender: UISwitch) {
        if sender.isOn {
            userSettings.setNotificationStatus(isAllowed: true)
        } else {
            userSettings.setNotificationStatus(isAllowed: false)
        }
    }
    
    @IBAction func rateAppPressed(_ sender: UIButton) {
        SKStoreReviewController.requestReview()
    }
    
    //Method that getting html file name and return URL
    fileprivate func loadPageURL(pageName: String) -> URLRequest {
        let localfilePath = Bundle.main.url(forResource: pageName, withExtension: "html");
        return URLRequest(url: localfilePath!)
    }
    
}
