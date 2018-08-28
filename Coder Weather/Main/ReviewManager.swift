//
//  ReviewManager.swift
//  Coder Weather
//
//  Created by Coder ACJHP on 14.08.2018.
//  Copyright © 2018 Coder ACJHP. All rights reserved.
//

import Foundation
import StoreKit

class ReviewManager {
    
    static let shared = ReviewManager()
    
    let userDefaults = UserDefaults()
    let runIncrementerSetting = "numberOfRuns"
    let minimumRunCount = 5
    
    func incrementAppRuns() { 
        
        let runs = getRunCounts() + 1
        userDefaults.setValuesForKeys([runIncrementerSetting: runs])
        userDefaults.synchronize()
        
    }
    
    func getRunCounts () -> Int {
        
        let savedRuns = userDefaults.value(forKey: runIncrementerSetting)
        var runs = 0
        if (savedRuns != nil) {
            runs = savedRuns as! Int
        }
        return runs
    }
    
    func showReview() {
        let runs = getRunCounts()
        if (runs > minimumRunCount) {
            SKStoreReviewController.requestReview()
        }
    }
}
