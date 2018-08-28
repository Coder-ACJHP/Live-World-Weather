//
//  FavoritesController.swift
//  Coder Weather
//
//  Created by Coder ACJHP on 27.08.2018.
//  Copyright © 2018 Coder ACJHP. All rights reserved.
//

import UIKit
import MBProgressHUD

class FavoritesController: UIViewController {

    var apiKey: String!
    var apiAddressForId: String!
    
    var selectedCityId: Int!
    var halfSizeOfScreen: CGFloat!
    var screenHeight: CGFloat!
    var navigationBarHeight: CGFloat!
    // Define spinner
    var spinnerActivity: MBProgressHUD?
    var transferableWallpaper: UIImage!
    var getResultsIfContains = true
    var filteredList = [Weather]()
    var favoriteListAsId = [Int]()
    var favoriteList = [Weather]()
    var citiesList = Array<Weather>()
    let userDefaults = Setting.shared
    let staticDatas = StaticDatas.sharedInstance
    let changeWeatherIcon = ChangeWeatherIconManager()
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
            #selector(handleRefresh(_:)), for: UIControlEvents.valueChanged)
        refreshControl.tintColor = UIColor.white
        return refreshControl
    }()
    
    // Outlets
    @IBOutlet weak var backgroundImageHolder: UIImageView!
    @IBOutlet weak var favoriteTable: UITableView!
    @IBOutlet weak var addButtonContainer: UIView!
    // Popover elements
    @IBOutlet var popoverView: UIView!
    @IBOutlet weak var searchbar: UISearchBar!
    @IBOutlet weak var dataTable: UITableView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var innerContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        basicSetup()

        adjustMeasurement()
        
        makeAddButtonMovable()
        
        setupPopoverView()
        
        loadDataWithProgressBar()
    }
    
    private func basicSetup() {
        
        // Setup wallpaper that transfered from main view
        backgroundImageHolder.image = transferableWallpaper
        
        // Prepopulate picker array
        citiesList = LocationsNameUtil.sharedInstance.getCitieslist()
        
        // add refresh controller
        favoriteTable.addSubview(refreshControl)
    }
    
    private func loadDataWithProgressBar() {
        // Initialize spinner (MBHUD)
        self.spinnerActivity = MBProgressHUD.showAdded(to: self.view, animated: true);
        // Change some properties of spinner
        self.spinnerActivity?.label.text = "Loading..."
        self.spinnerActivity?.isUserInteractionEnabled = true
        self.spinnerActivity?.show(animated: true)
        
        self.populateLists()
        
        self.spinnerActivity?.hide(animated: true)
    }
    
    private func populateLists() {
        // Initialize app secret key and links
        arrangeKeys()
        
        // Prepopulate favorite list
        if let list = userDefaults.getFavoriteList(), list.count > 0 {
            favoriteListAsId = list
            favoriteList.removeAll(keepingCapacity: false)
            favoriteListAsId.forEach { (cityId) in
                let newQuery: String = apiAddressForId + String(cityId) + apiKey
                self.fetchData(queryAddress: newQuery)
            }
        } else {
            showCustomErrorMsgWithAlert("Suggestion", errorMessage: "Favorite list is empty!\nAdd your favorite cities to the list.")
        }
    }
    
    fileprivate func arrangeKeys() {
        self.apiKey = StaticDatas.sharedInstance.apiKey
        self.apiAddressForId = StaticDatas.sharedInstance.apiAddressForId
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
                
                                let cityWeather = Weather()
                                
                                let main = jsonResult["main"]
                                if let temprature: Double = main!["temp"] as? Double {
                                    let convertKelvinToCelcius: Double = temprature - self.staticDatas.KELVIN
                                    cityWeather.temperature = String(convertKelvinToCelcius).components(separatedBy: ".").first! + "˚"
                                }
    
                                let weather = jsonResult["weather"] as! Array<AnyObject>
                                let firstElement = weather[0]
                                
                                let iconCode = firstElement["icon"] as! String
                                cityWeather.iconCode = iconCode
                                
                                if let name = jsonResult["name"] as? String {
                                    cityWeather.cityName = name
                                }
                                
                                if let id = jsonResult["id"] as? Int {
                                    cityWeather.id = id
                                }
                                
                                let sys = jsonResult["sys"]
                                if let country = sys!["country"] as? String {
                                    cityWeather.countryName = country
                                }

                                self.favoriteList.append(cityWeather)
                                self.favoriteTable.reloadData()
                            }
                        }
                    } catch { self.showErrorWithAlert(errorObj: error) }
                } else if httpResponse.statusCode == 401 {
                    /*
                     * This is specific error code throwing when the api key is invalid or
                     * requesting query with unregistered key (from 9 October 2015 by Open Map Weather)
                     */
                    self.showCustomErrorMsgWithAlert("Error!", errorMessage: "Invalid api key!\nPlease add your own key or register.")
                }else {
                    self.showCustomErrorMsgWithAlert("Unknown error!", errorMessage: "Server returned " + String(httpResponse.statusCode))
                }
            }
        }
        task.resume()
    }
    
    private func adjustMeasurement() {
        screenHeight = self.view.bounds.height - 37
        navigationBarHeight = self.navigationController?.navigationBar.frame.height
        halfSizeOfScreen = UIScreen.main.bounds.width / 2
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
    
    private func makeAddButtonMovable() {
        view.bringSubview(toFront: addButtonContainer)
        addButtonContainer.isUserInteractionEnabled = true
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleMoving(gestureRecognizer:)))
        addButtonContainer.addGestureRecognizer(panGestureRecognizer)
    }

    @objc fileprivate func handleMoving(gestureRecognizer: UIPanGestureRecognizer) {
        let draggedPoint = gestureRecognizer.location(in: self.view)
        addButtonContainer.center = draggedPoint
        
        if gestureRecognizer.state == .ended {
            let pointX = draggedPoint.x
            let pointY = draggedPoint.y
            
            if pointX > halfSizeOfScreen {
                addButtonContainer.frame.origin.x = (halfSizeOfScreen * 2) - (addButtonContainer.frame.width + 10)
                
            } else {
                addButtonContainer.frame.origin.x = 15
            }
            
            if pointY > screenHeight || pointY < navigationBarHeight {
                addButtonContainer.frame.origin.y = screenHeight - (addButtonContainer.frame.height)
            }
            
            UIView.animate(withDuration: 0.4) {
                self.view.layoutIfNeeded()
            }
        }
        
    }
    
    @objc private func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.favoriteTable.reloadData()
        refreshControl.endRefreshing()
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
    }
    
    private func showCustomErrorMsgWithAlert(_ headerTitle: String = "Warning", errorMessage: String) {
        let alert = UIAlertController(title: headerTitle, message: errorMessage, preferredStyle: UIAlertControllerStyle.alert)
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
    
    @IBAction func addButtonPressed(_ sender: UIButton) {
        showPopover()
    }
    
    // Popover cancel button action
    @IBAction func cancelButtonPressed(_ sender: Any) {
        hidePopover()
    }
}

extension FavoritesController: UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == favoriteTable {
            return favoriteList.count
        } else {
            if filteredList.count > 0 {
                return filteredList.count
            } else {
                return citiesList.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == favoriteTable {
            var cell = FavoriteCell()
            cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteCell", for: indexPath) as! FavoriteCell
            cell.cityNameLabel.text = favoriteList[indexPath.row].cityName
            cell.countryNameLabel.text = favoriteList[indexPath.row].countryName
            cell.termperatureLabel.text = favoriteList[indexPath.row].temperature
            changeWeatherIcon.changeDayIcon(imageContainer: cell.iconHolder, iconCode: favoriteList[indexPath.row].iconCode)
            return cell
            
        } else {
            var cityCell = CitiesCell()
            cityCell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CitiesCell
            
            if filteredList.count > 0 {
                cityCell.leftLabel.text = filteredList[indexPath.row].cityName
                cityCell.rightLabel.text = filteredList[indexPath.row].countryName
            } else {
                cityCell.leftLabel.text = citiesList[indexPath.row].cityName
                cityCell.rightLabel.text = citiesList[indexPath.row].countryName
            }
            
            return cityCell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView == dataTable {
            
            let choosenCell = tableView.cellForRow(at: indexPath) as! CitiesCell
            let choosenCityName = choosenCell.leftLabel.text
            
            if filteredList.count > 0 {
                filteredList.forEach { (weather) in
                    if weather.cityName == choosenCityName {
                        selectedCityId = weather.id
                    }
                }
            } else {
                citiesList.forEach { (weather) in
                    if weather.cityName == choosenCityName {
                        selectedCityId = weather.id
                    }
                }
            }
            
            favoriteListAsId.append(selectedCityId)
            favoriteListAsId.removeDuplicates()
            userDefaults.setFavoriteList(favoriteList: favoriteListAsId)
            // Erase search text from searchbar
            self.searchbar.text = ""
            filteredList.removeAll(keepingCapacity: false)
            dataTable.reloadData()
            // Hide keyboard
            self.searchbar.endEditing(true)
            // Hide popover
            self.hidePopover()
            
            loadDataWithProgressBar()
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let choosenCell = tableView.cellForRow(at: indexPath) as! FavoriteCell
            favoriteListAsId.removeAll(keepingCapacity: false)
            favoriteList.enumerated().forEach { (index, element) in
                
                if element.cityName == choosenCell.cityNameLabel.text {
                    favoriteList.remove(at: index)
                } else {
                    favoriteListAsId.append(element.id)
                }
            }
            userDefaults.setFavoriteList(favoriteList: favoriteListAsId)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
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
            self.spinnerActivity?.show(animated: true)
            
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
