//
//  ChangeWeatherIconManager.swift
//  Coder Weather
//
//  Created by Coder ACJHP on 15.08.2018.
//  Copyright © 2018 Coder ACJHP. All rights reserved.
//

import UIKit

class ChangeWeatherIconManager: NSObject {
    
    //Icon codes coming from server and here we just match codes with own icons
    func changeDayIcon(imageContainer: UIImageView, iconCode: String) {
        switch iconCode {
        case "01d":
            imageContainer.image = UIImage(named: "sun.png")
        case "01n":
            imageContainer.image = UIImage(named: "moon.png")
        case "02d":
            imageContainer.image = UIImage(named: "cloudy-sun.png")
        case "02n":
            imageContainer.image = UIImage(named: "cloudy-night.png")
        case "03d", "03n", "04d", "04n" :
            imageContainer.image = UIImage(named: "cloudy.png")
        case "09d", "09n":
            imageContainer.image = UIImage(named: "rain.png")
        case "10d", "10n":
            imageContainer.image = UIImage(named: "rain-1.png")
        case "11d", "11n":
            imageContainer.image = UIImage(named: "thunder.png")
        case "13d", "13n":
            imageContainer.image = UIImage(named: "snowflake.png")
        case "50d", "50n":
            imageContainer.image = UIImage(named: "fogg.png")
        default:
            print("404 weather icon not found!")
        }
    }
}
