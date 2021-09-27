//
//  CityViewController.swift
//  WeatherApp
//
//  Created by Maga Rajic on 25.09.2021..
//

import UIKit
import CoreLocation

class CityViewController: UITableViewController, CLLocationManagerDelegate {
    
    @IBOutlet var myLocation: UIButton!
    
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    
    var allCityForForecast = [CityForForecast]()
    //var coordinatesForForecast: LocationForForecast!
    func createNewCity(index: Int) {
        let newCity = CityForForecast(index: index)
        allCityForForecast.append(newCity)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createNewCity(index: 0)
        createNewCity(index: 1)
        createNewCity(index: 2)
        createNewCity(index: 3)
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 65
        
        setupLocation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupLocation()
    }
    
    func setupLocation() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if !locations.isEmpty, currentLocation == nil {
            currentLocation = locations.first
            locationManager.stopUpdatingLocation()
        }
    }
    
           
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allCityForForecast.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CityTableCell", for: indexPath)
        let city = allCityForForecast[indexPath.row]
        cell.textLabel?.text = city.cityName
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            
        switch segue.identifier {
        case "forecastByCity":
            let segueIdentifier = SegueIdentifier(segueType: "forecastByCity")
            if let row = tableView.indexPathForSelectedRow?.row {
                let city = allCityForForecast[row]
                let forecastViewController = segue.destination as! ForecastViewController
                forecastViewController.cityForForecast = city
                forecastViewController.segueIdentifier = segueIdentifier
            }
        case "forecastByLocation":
            guard let currentLocation = currentLocation else {
                print("No Location")
                return
            }
            let segueIdentifier = SegueIdentifier(segueType: "forecastByLocation")
            let forecastViewController = segue.destination as! ForecastViewController
            let coordinatesForForecast = LocationForForecast(lon: currentLocation.coordinate.longitude, lat: currentLocation.coordinate.latitude)
            forecastViewController.locationForForecast = coordinatesForForecast
            forecastViewController.segueIdentifier = segueIdentifier
        default:
            preconditionFailure("Unexpected segue identifier")
        }
        
    }
    
    
    
}

class CityForForecast {
    var cityName: String
    
    init(name: String) {
        self.cityName = name
    }
    
    convenience init(index: Int){
        let cityList = ["Rijeka", "London", "Beograd", "Madrid"]
        let cityName = cityList[index]
        self.init(name: cityName)
    }
}

class LocationForForecast {
    
    var coordinatesLon: Double
    var coordinatesLat: Double
    
    init(lon: Double, lat: Double) {
        self.coordinatesLon = lon
        self.coordinatesLat = lat
    }
    
}

class SegueIdentifier {
    
    var segueIdentifier: String
    
    init(segueType: String) {
        segueIdentifier = segueType
    }
    
}

