//
//  StaticDatas.swift
//  Coder Weather
//
//  Created by akademobi5 on 15.08.2018.
//  Copyright © 2018 Coder ACJHP. All rights reserved.
//

import UIKit

class StaticDatas {
    
    static let sharedInstance = StaticDatas()
    //Standart kelvin value
    let KELVIN: Double = 273.15
    let imageList: [UIImage] = [#imageLiteral(resourceName: "blue-cloud"), #imageLiteral(resourceName: "pinky-sky"), #imageLiteral(resourceName: "sky-and-arable"), #imageLiteral(resourceName: "spring"), #imageLiteral(resourceName: "evening-sea"), #imageLiteral(resourceName: "wild-blue-sea"), #imageLiteral(resourceName: "orang-mountains"), #imageLiteral(resourceName: "pink-sky"), #imageLiteral(resourceName: "evening-mountain"), #imageLiteral(resourceName: "lunar-night-sky"), #imageLiteral(resourceName: "night-sky"), #imageLiteral(resourceName: "afternoon-sky")]
    let apiKey: String = "&APPID=ADD_YOUR_API_SECRET_KEY_HERE"
    let apiAddressForId: String = "http://api.openweathermap.org/data/2.5/weather?id="
    let apiAddressForLocation: String = "http://api.openweathermap.org/data/2.5/weather?"
    var apiAddressForIdForecast: String = "http://api.openweathermap.org/data/2.5/forecast?id="
}
