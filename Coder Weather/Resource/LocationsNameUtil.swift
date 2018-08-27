//
//  LocationsNameUtil.swift
//  Coder Weather
//
//  Created by Coder ACJHP on 30.06.2018.
//  Copyright © 2018 Coder ACJHP. All rights reserved.
//

import Foundation

class LocationsNameUtil {
    
    var cityList = Array<Weather>()
    let fileManager = FileManager.default
    static var sharedInstance = LocationsNameUtil()
    
    
    init() {}
    
    func configure() {
        
        if let jsonFilePath = Bundle.main.path(forResource: "city.list", ofType: "json") {
            
                do {
                    
                    let jsonData = NSData(contentsOfFile: jsonFilePath)
                    let jSONResult = try JSONSerialization.jsonObject(with: jsonData! as Data, options: JSONSerialization.ReadingOptions.mutableContainers) as! [Dictionary<String, AnyObject>]
                    jSONResult.forEach { (data) in
                        let singleWeather = Weather()
                        for (key, value) in data {
                            if key == "id" {
                                singleWeather.id = value as! Int
                            }
                            else if key == "name" {
                                singleWeather.cityName = value as! String
                            }
                            else if key == "country" {
                                singleWeather.countryName = value as! String
                            }
                            
                        }
                        cityList.append(singleWeather)
                    }
                } catch {
                    print(error.localizedDescription)
                }
            
        } else {
            print("Cannot find the file in this path !")
        }
        
        
        
    }
    
    func getCitieslist() -> Array<Weather> {
        if cityList.count != 0 {
            return cityList
        }
        return Array<Weather>()
    }

}
