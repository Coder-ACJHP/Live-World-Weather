//
//  DetailController.swift
//  Coder Weather
//
//  Created by Coder ACJHP on 3.07.2018.
//  Copyright © 2018 Coder ACJHP. All rights reserved.
//

import UIKit

class DetailController: UIViewController {

    var counter: Int = -1
    var countList = [Int]()
    var currentRow: Dictionary<String, AnyObject> = [:]
    var query = 745044
    //Standart kelvin value
    let KELVIN: Double = 273.15
    var apiKey: String!
    var apiAddressForId: String!
    //Transferable object
    var cityWeather: Weather = Weather()
    var transferableWallpaper: UIImage!
    let changeWeatherIcon = ChangeWeatherIconManager()
    
    @IBOutlet weak var cityName: UILabel!
    @IBOutlet weak var minTemplabel: UILabel!
    @IBOutlet weak var maxTempLabel: UILabel!
    @IBOutlet weak var firstDateLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var firstDateTempLabel: UILabel!
    @IBOutlet weak var firstDateImageContainer: UIImageView!
    @IBOutlet weak var secondDateLabel: UILabel!
    @IBOutlet weak var secondDateTempLabel: UILabel!
    @IBOutlet weak var secondDateImageContainer: UIImageView!
    @IBOutlet weak var thirdDateLabel: UILabel!
    @IBOutlet weak var thirdDateTempLabel: UILabel!
    @IBOutlet weak var thirdDateImageContainer: UIImageView!
    @IBOutlet weak var fourthDateLabel: UILabel!
    @IBOutlet weak var fourthDateTempLabel: UILabel!
    @IBOutlet weak var fourthDateImageContainer: UIImageView!
    @IBOutlet weak var fifthDateLabel: UILabel!
    @IBOutlet weak var fifthDateTempLabel: UILabel!
    @IBOutlet weak var fifthDateImageContainer: UIImageView!
    @IBOutlet weak var backgroundWallpaperContainer: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Setup wallpaper that transfered from main view
        backgroundWallpaperContainer.image = transferableWallpaper
        
        if !cityWeather.cityName.isEmpty {
            cityName.text = cityWeather.cityName
            minTemplabel.text = cityWeather.minTemperature
            maxTempLabel.text = cityWeather.maxTemperature
            query = cityWeather.id
        }
        
        arrangeKeys()
        
        //Initialize default query link for startup weather
        let defaultQuery: String = apiAddressForId + String(query) + apiKey
        fetchData(queryAddress: defaultQuery)
        
        disableScrollOnBigScreens()

    }
    
    fileprivate func arrangeKeys() {
        self.apiKey = StaticDatas.sharedInstance.apiKey
        self.apiAddressForId = StaticDatas.sharedInstance.apiAddressForIdForecast
    }
    
    func fetchData(queryAddress: String) {
        
        let url = URL(string: queryAddress)
        let session = URLSession.shared
        let task = session.dataTask(with: url!) { (data, response, error) in
            
            if error != nil {
                self.showErrorWithAlert(errorObj: error!)
                
            } else {
                //Check the response code before working with it!
                let httpResponse = response as! HTTPURLResponse
                if httpResponse.statusCode == 200 {
                    do {
                        let jsonResult = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as! Dictionary<String, AnyObject>
                        
                        DispatchQueue.main.async {
                            
                            if jsonResult.count != 0 {
                                
                                let list = jsonResult["list"]
                                for resultRow in list as! Array<Dictionary<String, AnyObject>> {
                                    self.counter += 1
                                    resultRow.forEach({ (key, value) in
                                        if key == "dt_txt" {
                                            let valueAsString = value as! String
                                            
                                            if valueAsString.contains("12:00:00") {
                                                self.countList.append(self.counter)
                                            }
                                        }
                                    })
                                    
                                }
                                self.counter = 0
                                let exlist = jsonResult["list"] as! [Dictionary<String, AnyObject>]
                                for index in 0...(self.countList.count - 1) {
                                    let currentRowNumber = self.countList[index]
                                    let currentRow = exlist[currentRowNumber]
                                    self.populateDays(index: index, resultRow: currentRow)
                                }
                            }
                        }
                        
                    } catch {
                        self.showErrorWithAlert(errorObj: error)
                    }
                } else if httpResponse.statusCode == 401 {
                    /*
                     * This is specific error code throwing when the api key is invalid or
                     * requesting query with unregistered key (from 9 October 2015 by Open Map Weather)
                     */
                    self.showCustomErrorMsgWithAlert(errorMessage: "Invalid api key!\nPlease add your own key or register.")
                }else {
                    self.showCustomErrorMsgWithAlert(errorMessage: "Server returned " + String(httpResponse.statusCode))
                }
            }
            
        }
        task.resume()
        
    }
    
    func populateDays(index: Int, resultRow: Dictionary<String, AnyObject>) {
        //Populate tempreture
        let main = resultRow["main"] as! Dictionary<String, AnyObject>
        let temp = main["temp"] as! Double
        let tempAsInt = Int(temp - KELVIN)
        
        //Populate date
        let date = resultRow["dt_txt"] as! String
        
        //Populate image
        let weather = resultRow["weather"] as! Array<AnyObject>
        let firstElement = weather[0]
        let iconCode = firstElement["icon"] as! String
        
        switch index {
        case 0:
            firstDateTempLabel.text = String(tempAsInt)
            firstDateLabel.text = date.components(separatedBy: " ").first
            self.changeWeatherIcon.changeDayIcon(imageContainer: firstDateImageContainer, iconCode: iconCode)
        case 1:
            secondDateTempLabel.text = String(tempAsInt)
            secondDateLabel.text = date.components(separatedBy: " ").first
            self.changeWeatherIcon.changeDayIcon(imageContainer: secondDateImageContainer, iconCode: iconCode)
        case 2:
            thirdDateTempLabel.text = String(tempAsInt)
            thirdDateLabel.text = date.components(separatedBy: " ").first
            self.changeWeatherIcon.changeDayIcon(imageContainer: thirdDateImageContainer, iconCode: iconCode)
        case 3:
            fourthDateTempLabel.text = String(tempAsInt)
            fourthDateLabel.text = date.components(separatedBy: " ").first
            self.changeWeatherIcon.changeDayIcon(imageContainer: fourthDateImageContainer, iconCode: iconCode)
        case 4:
            fifthDateTempLabel.text = String(tempAsInt)
            fifthDateLabel.text = date.components(separatedBy: " ").first
            self.changeWeatherIcon.changeDayIcon(imageContainer: fifthDateImageContainer, iconCode: iconCode)
        default:
            print("404 not found!")
        }
    }
    
    private func disableScrollOnBigScreens() {
        let screenHeight = UIScreen.main.bounds.height
        if screenHeight >= 812 {
            scrollView.isScrollEnabled = false
        }
    }
    
    func showCustomErrorMsgWithAlert(errorMessage: String) {
        let alert = UIAlertController(title: "Warning", message: errorMessage, preferredStyle: UIAlertControllerStyle.alert)
        let cancelButton = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.cancel, handler: nil)
        alert.addAction(cancelButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    func showErrorWithAlert(errorObj: Error) {
        let alert = UIAlertController(title: "Warning", message: errorObj.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
        let cancelButton = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.cancel, handler: nil)
        alert.addAction(cancelButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func returnBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
}
