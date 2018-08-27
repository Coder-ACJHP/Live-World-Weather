//
//  ViewController.swift
//  Coder Weather
//
//  Created by Coder ACJHP on 30.06.2018.
//  Copyright © 2018 Coder ACJHP. All rights reserved.
//

import UIKit
import CoreLocation
import MBProgressHUD

class MainController: UIViewController {

    var timer: Timer!
    var query: Int!
    var wallpaper: UIImage!
    //These will use when getting location coordinates
    var currentLatitude: Int = 0
    var currentLongitude: Int = 0
    
    var getResultsIfContains = true
    let staticDatas = StaticDatas.sharedInstance
    
    // Define spinner
    var spinnerActivity: MBProgressHUD?
    
    //Transferable cityWeather
    var transferableWeather = Weather()
    
    var locationManager = CLLocationManager()
    var apiKey: String!
    var apiAddressForId: String!
    var apiAddressForLocation: String!
    var filteredList = [Weather]()
    var citiesList = Array<Weather>()
    let userSettings = Setting.shared
    let changeWeatherIcon = ChangeWeatherIconManager()
    
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var hourLabel: UILabel!
    @IBOutlet weak var weatherlabel: UILabel!
    @IBOutlet weak var weatherImageContainer: UIImageView!
    @IBOutlet weak var windLabel: UILabel!
    @IBOutlet weak var cloudLabel: UILabel!
    @IBOutlet weak var pressureLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var sunriseLabel: UILabel!
    @IBOutlet weak var sunsetLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var cityCountLabel: UILabel!
    @IBOutlet weak var showCityList: UIButton!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var backgroundWallpaperContainer: UIImageView!
    
    // MARK :- External popover view
    @IBOutlet var popoverView: UIView!
    @IBOutlet weak var background: UIVisualEffectView!
    @IBOutlet weak var innerContainer: UIView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var searchbar: UISearchBar!
    @IBOutlet weak var dataTable: UITableView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var findMe: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Setup UI components
        arrangeUI()
        // Setup api keys etc.
        arrangeKeys()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.setupWallpaper()
        self.scrollToTop()
    }
    
    fileprivate func scrollToTop() {
        self.scrollView.setContentOffset(.zero, animated: true)
    }
    
    fileprivate func arrangeKeys() {
        self.apiKey = StaticDatas.sharedInstance.apiKey
        self.apiAddressForId = StaticDatas.sharedInstance.apiAddressForId
        self.apiAddressForLocation = StaticDatas.sharedInstance.apiAddressForLocation
    }
    
    private func arrangeUI() {
        
        self.setupDateLabelText()
        //Prepopulate picker array
        citiesList = LocationsNameUtil.sharedInstance.getCitieslist()
        // Add text to city count label
        cityCountLabel.text = "Access " + changeNumberToCurrencyFormat(number: citiesList.count) + " cities around world !"
        
        // Location services
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
        
        // MARK :- External popover delegates
        self.setupDelegatesAndDataSources()
        self.setupPopoverView()
        self.addLogoToNavbar()
    }
    
    private func addLogoToNavbar() {
        let imageView = UIImageView(image: UIImage(named: "Logo"))
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect(x: 0, y: 0, width: 130, height: 45)
        self.navigationItem.titleView = imageView
    }
    
    private func setupWallpaper() {
        if !userSettings.getAutoChangeWallpaperStatus() {
            let image: UIImage? = userSettings.getWallpaper()
            if image != nil {
                wallpaper = image
            } else {
                // Set default image
                wallpaper = #imageLiteral(resourceName: "blue-cloud")
            }
            self.backgroundWallpaperContainer.image = wallpaper
            
        } else {
            // Change wallpaper every 30 minutes
            let oneHourInterval = TimeInterval(30 * 60)
            self.timer = Timer.scheduledTimer(timeInterval: oneHourInterval, target: self, selector: #selector(autoChangeWallpaper), userInfo: nil, repeats: true)
            timer.fire()
        }
    }
    
    @objc private func autoChangeWallpaper() {
        UIView.animate(withDuration: 0.4) {
            self.backgroundWallpaperContainer.image = self.staticDatas.imageList.random()
        }
    }
    
    private func setupDateLabelText() {
        //Add date and time to labels
        let currentDateTime = Date()
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .long
        showCityList.layer.cornerRadius = 5.0
        let formattedDateTime = formatter.string(from: currentDateTime)
        dateLabel.text = formattedDateTime.components(separatedBy: "at").first
        hourLabel.text = formattedDateTime.components(separatedBy: "at ").last
    }
    
    private func changeNumberToCurrencyFormat(number: Int) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.usesGroupingSeparator = true
        numberFormatter.numberStyle = .decimal
        return numberFormatter.string(from: NSNumber(value: number))!
    }
    
    private func setupDelegatesAndDataSources() {
        dataTable.delegate = self
        dataTable.dataSource = self
        searchbar.delegate = self
    }
    
    private func setupPopoverView() {
        // set corner radius for popover elements
        innerContainer.layer.cornerRadius = 5.0
        cancelButton.layer.cornerRadius = 5.0
        
        self.view.addSubview(popoverView)
        popoverView.frame = self.view.frame
        popoverView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        popoverView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        popoverView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        popoverView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        
        popoverView.isHidden = true
    }
    
    private func fetchDataByLocation() {
        if currentLongitude != 0 && currentLatitude != 0 {
            let coordinates: String = "lat=" + String(currentLatitude) + "&lon=" + String(currentLongitude)
            let namedQuery: String = apiAddressForLocation + coordinates + apiKey
            self.fetchData(queryAddress: namedQuery)
        }
    }
    
    private func fetchData(queryAddress: String) {
        
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

                                let main = jsonResult["main"]
                                if let temprature: Double = main!["temp"] as? Double {
                                    let convertKelvinToCelcius: Double = temprature - self.staticDatas.KELVIN
                                    self.weatherlabel.text = String(convertKelvinToCelcius).components(separatedBy: ".").first
                                }
                                if let pressure = main!["pressure"] as? Int {
                                    self.pressureLabel.text = String(pressure)
                                }
                                if let humidity = main!["humidity"] as? Int {
                                    self.humidityLabel.text = String(humidity) + "%"
                                }
                                if let minTemp = main!["temp_min"] as? Double {
                                    self.transferableWeather.minTemperature = String(Int(self.convertKelvinToCelcius(celciusVal: minTemp)))
                                }
                                if let maxTemp = main!["temp_max"] as? Double {
                                    self.transferableWeather.maxTemperature = String(Int(self.convertKelvinToCelcius(celciusVal: maxTemp)))
                                }
                                let weather = jsonResult["weather"] as! Array<AnyObject>
                                let firstElement = weather[0]
                                let description = firstElement["description"] as! String
                                let descriptionMain = firstElement["main"] as! String
                                self.statusLabel.text = descriptionMain + " / " + description
                                
                                let iconCode = firstElement["icon"] as! String
                                self.changeWeatherIcon.changeDayIcon(imageContainer: self.weatherImageContainer, iconCode: iconCode)
                                
                                if let name = jsonResult["name"] as? String {
                                    self.cityNameLabel.text = name
                                    self.transferableWeather.cityName = name
                                }
                                
                                if let id = jsonResult["id"] as? Int {
                                    self.transferableWeather.id = id
                                }
                                
                                let clouds = jsonResult["clouds"]
                                if let all = clouds!["all"] as? Int {
                                    self.cloudLabel.text = String(all) + "%"
                                }
                                let sys = jsonResult["sys"]
                                if let country = sys!["country"] as? String {
                                    self.cityNameLabel.text = self.cityNameLabel.text! + " " + country
                                    self.transferableWeather.cityName = self.transferableWeather.cityName + " " + country
                                }
                                if let sunrise = sys!["sunrise"] as? Double {
                                    self.sunriseLabel.text = self.unixEpochTimeConverter(unixEpochTime: sunrise)
                                }
                                if let sunset = sys!["sunset"] as? Double {
                                    self.sunsetLabel.text = self.unixEpochTimeConverter(unixEpochTime: sunset)
                                }
                                let wind = jsonResult["wind"]
                                if let speed = wind!["speed"] as? Double {
                                    self.windLabel.text = String(speed) + "MS"
                                }
                            }
                        }
                    } catch { self.showErrorWithAlert(errorObj: error) }
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
    
    private func unixEpochTimeConverter(unixEpochTime: Double) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(unixEpochTime))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm a"
        let strDate = dateFormatter.string(from: date)
        return strDate
    }
    
    private func convertKelvinToCelcius(celciusVal: Double) -> Double {
        let convertKelvinToCelcius: Double = celciusVal - self.staticDatas.KELVIN
        return convertKelvinToCelcius
    }
    
   
    
    private func showCustomErrorMsgWithAlert(errorMessage: String) {
        let alert = UIAlertController(title: "Warning", message: errorMessage, preferredStyle: UIAlertControllerStyle.alert)
        let cancelButton = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.cancel, handler: nil)
        alert.addAction(cancelButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    private func showErrorWithAlert(errorObj: Error) {
        let alert = UIAlertController(title: "Warning", message: errorObj.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
        let cancelButton = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.cancel, handler: nil)
        alert.addAction(cancelButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    //Transfer data before segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "transferWeatherDetail" {
            let destinationController = segue.destination as! DetailController
            // Transfer current waether datas
            destinationController.cityWeather = transferableWeather
            // Transfer current wallpaper image
            destinationController.transferableWallpaper = self.wallpaper
        }
    }
    
    //Actions
    @IBAction func segmentIsChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            getResultsIfContains = true
        } else {
            getResultsIfContains = false
        }
    }
    
    @IBAction func findMeButton(_ sender: UIButton) {
        fetchDataByLocation()
    }
    
    @IBAction func changeCityBtnPressed(_ sender: Any) {
        showPopover()
    }
    
    // Popover cancel button action
    @IBAction func cancelButtonPressed(_ sender: Any) {
        hidePopover()
    }
    
    // Popover show and hide with animation
    private func showPopover() {
        popoverView.isHidden = false
        popoverView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        popoverView.alpha = 0
        
        UIView.animate(withDuration: 0.4) {
            self.popoverView.alpha = 1
            self.popoverView.transform = CGAffineTransform.identity
        }
    }
    
    private func hidePopover() {
        UIView.animate(withDuration: 0.4, animations: {
            self.popoverView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.popoverView.alpha = 0
        }) { (success: Bool) in
             self.popoverView.isHidden = true
        }
        // Scroll to top if contents position down
        self.scrollToTop()
    }
}

extension MainController: UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, CLLocationManagerDelegate {
    
    // MARK :- Table protocol methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if filteredList.count > 0 {
            return filteredList.count
        } else {
            return citiesList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cityCell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CitiesCell
        
        if filteredList.count > 0 {
            cityCell.leftLabel.text = filteredList[indexPath.row].cityName
            cityCell.rightLabel.text = filteredList[indexPath.row].countryName
        } else {
            cityCell.leftLabel.text = citiesList[indexPath.row].cityName
            cityCell.rightLabel.text = citiesList[indexPath.row].countryName
        }
        
        return cityCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let choosenCell = tableView.cellForRow(at: indexPath) as! CitiesCell
        let choosenCityName = choosenCell.leftLabel.text
        
        if filteredList.count > 0 {
            filteredList.forEach { (weather) in
                if weather.cityName == choosenCityName {
                    query = weather.id
                }
            }
        } else {
            citiesList.forEach { (weather) in
                if weather.cityName == choosenCityName {
                    query = weather.id
                }
            }
        }
        
        self.transferableWeather.id = query
        let newQuery: String = apiAddressForId + String(query) + apiKey
        fetchData(queryAddress: newQuery)
        // Erase search text from searchbar
        self.searchbar.text = ""
        filteredList.removeAll(keepingCapacity: false)
        dataTable.reloadData()
        // Hide keyboard
        self.searchbar.endEditing(true)
        // Hide popover
        self.hidePopover()
    }
    
    // MARK :- Searchbar protocol methods
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText == "" || searchText.count == 0 {
            filteredList.removeAll(keepingCapacity: false)
            dataTable.reloadData()
        } else {
            // Clear old results from the list
            filteredList.removeAll(keepingCapacity: false)
            
            // Initialize spinner (MBHUD)
            self.spinnerActivity = MBProgressHUD.showAdded(to: self.view, animated: true);
            // Change some properties of spinner
            self.spinnerActivity?.label.text = "Loading..."
            self.spinnerActivity?.isUserInteractionEnabled = true
            citiesList.forEach { (weather) in
                
                if getResultsIfContains {
                    
                    if weather.cityName.hasPrefix(searchText) {
                        filteredList.append(weather)
                    }
                } else {
                    if weather.cityName == searchText {
                        filteredList.append(weather)
                    }
                }
                
            }
            dataTable.reloadData()
            self.spinnerActivity?.hide(animated: true, afterDelay: 1.0)
        }
    }
    
    //Location manager
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locationCoordinate: CLLocationCoordinate2D = (manager.location?.coordinate)!
        currentLatitude = Int(locationCoordinate.latitude)
        currentLongitude = Int(locationCoordinate.longitude)
        
        self.fetchDataByLocation()
    }
    
    // MARK :- Hide keyboard methods
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.searchbar.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchbar.endEditing(true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchbar.endEditing(true)
        self.view.endEditing(true)
    }
}


