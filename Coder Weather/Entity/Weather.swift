//
//  Weather.swift
//  Coder Weather
//
//  Created by Coder ACJHP on 30.06.2018.
//  Copyright © 2018 Coder ACJHP. All rights reserved.
//

import Foundation

class Weather {
    
    var id: Int = 0
    var cityName: String = ""
    var countryName: String = ""
    var temperature: String = ""
    var maxTemperature: String = ""
    var minTemperature: String = ""
    var wind: String = ""
    var humidity: String = ""
    var cloud: String = ""
    var rain: String = ""
    var snow: String = ""
    var sunrise: String = ""
    var sunset: String = ""
    var iconCode: String = ""
    
    init() {}
    
    init(id: Int, cityname: String, countryname: String, temperature: String, maxtemperature: String, mintemperature:String, wind: String, humidity: String,cloud: String, rain: String, snow: String, sunrise: String, sunset: String, iconCode: String) {
        self.id = id
        self.cityName = cityname
        self.countryName = countryname
        self.temperature = temperature
        self.maxTemperature = maxtemperature
        self.minTemperature = mintemperature
        self.wind = wind
        self.humidity = humidity
        self.cloud = cloud
        self.rain = rain
        self.snow = snow
        self.sunrise = sunrise
        self.sunset = sunset
        self.iconCode = iconCode
        
    }
    
    func toString() {
        print("Id: \(id), City name: \(cityName), Country name: \(countryName), Temperature: \(temperature), Max Temperature: \(maxTemperature), Min Temperature: \(minTemperature), Wind: \(wind), Humidity: \(humidity), Cloud: \(cloud), Rain: \(rain), Snow: \(snow), Sunrise: \(sunrise), Sunset: \(sunset), Icon code: \(iconCode)")
    }
}
