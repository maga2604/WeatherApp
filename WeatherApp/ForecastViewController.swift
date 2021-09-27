//
//  ForecastViewController.swift
//  WeatherApp
//
//  Created by Maga Rajic on 25.09.2021..
//

import UIKit
import CoreData

class ForecastViewController: UIViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var cityForForecast: CityForForecast!
    var locationForForecast: LocationForForecast!
    var segueIdentifier: SegueIdentifier!
    var forecastInfo = ForecastInfo()
    
    @IBOutlet var cityName: UILabel!
    @IBOutlet var forecastTemp: UILabel!
    @IBOutlet var forecastLat: UILabel!
    @IBOutlet var forecastLon: UILabel!
    @IBOutlet var forecastPre: UILabel!
    @IBOutlet var forecastDate: UILabel!
    @IBOutlet var forecastHum: UILabel!
    
    let numberFormatter: NumberFormatter = {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        nf.maximumFractionDigits = 2
        return nf
    }()
    
    @IBAction func saveForecast(_ sender: UIButton) {
        
        let newForecastInfo = ForecastData(context: self.context)
        newForecastInfo.forecastLocation = self.forecastInfo.infoCity
        newForecastInfo.forecastLongitude = self.forecastInfo.infoLon
        newForecastInfo.forecastLatitude = self.forecastInfo.infoLat
        newForecastInfo.forecastTemperature = self.forecastInfo.infoTemp
        newForecastInfo.forecastPressure = self.forecastInfo.infoPresurre
        newForecastInfo.forecastHumidity = self.forecastInfo.infoHumidity
        newForecastInfo.forecastDate = Date()
            do {
                try self.context.save()
            }
            catch {
                print("Error saving forecast: \(error)")
            }
    }
    
    @IBAction func changeUnits(_ sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 0:
            if forecastTemp.text == "No weather data" {
                forecastTemp.text = "No weather data"
            } else {
                forecastTemp.text = numberFormatter.string(from: NSNumber(value: self.forecastInfo.infoTemp))
            }
        case 1:
            if forecastTemp.text == "No weather data" {
                forecastTemp.text = "No weather data"
            } else {
                forecastTemp.text = numberFormatter.string(from: NSNumber(value: self.forecastInfo.infoTemp*9/5 + 32))
            }
        default:
            forecastTemp.text = numberFormatter.string(from: NSNumber(value: self.forecastInfo.infoTemp))
        }
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let segueIdentifier = segueIdentifier else {
            forecastInfo.infoCity = "No location data"
            cityName.text = "No location data"
            forecastLon.text = "No location data"
            forecastLat.text = "No location data"
            forecastTemp.text = "No weather data"
            forecastPre.text = "No weather data"
            forecastHum.text = "No weather data"
            return
            
        }
        switch segueIdentifier.segueIdentifier {
        case "forecastByCity":
            cityName.text = cityForForecast.cityName
            self.forecastInfo.infoCity = cityForForecast!.cityName
            requestForecastForCity()
        case "forecastByLocation":
            cityName.text = "My Location"
            forecastLon.text = String(locationForForecast!.coordinatesLon)
            forecastLat.text = String(locationForForecast!.coordinatesLat)
            requestForecastForLocation()
        default:
            preconditionFailure("Unexpected segue identifier")
        }
        
    }
    
    func requestForecastForCity() {
        let baseURLString = "https://api.openweathermap.org/data/2.5/weather?"
        let apiKey = "9df16a8c7148c6aeee1e2c4eec19fedd"

        var components = URLComponents(string: baseURLString)!
        var queryItems = [URLQueryItem]()
            
        var baseParam: [String: String] = ["appid":apiKey]
        baseParam["q"] = cityForForecast.cityName
        baseParam["units"] = "metric"
        
        for (key, value) in baseParam {
            let item = URLQueryItem(name: key, value: value)
            queryItems.append(item)
        }
        
        components.queryItems = queryItems
        
        let session: URLSession = {
            let config = URLSessionConfiguration.default
            return URLSession(configuration: config)
        }()
        
        let request = URLRequest(url: components.url!)
        let task = session.dataTask(with: request) { [self]
            (data, response, error) in
            
            guard let jsonData = data, error == nil else {
                print("Unexpected error with the request")
                return
            }
        
            var json: Forecast?
            do {
                json = try JSONDecoder().decode(Forecast.self, from: jsonData)
            }
            catch {
                print("error: \(error)")
            }
        
            guard let result = json else {
                return
            }
            
            self.forecastInfo.infoLon = result.coord.lon
            self.forecastInfo.infoLat = result.coord.lat
            self.forecastInfo.infoTemp = result.main.temp
            self.forecastInfo.infoPresurre = Int32(result.main.pressure)
            self.forecastInfo.infoHumidity = Int32(result.main.humidity)
        
            
            DispatchQueue.main.async {
                self.forecastLon.text = String(result.coord.lon)
                self.forecastLat.text = String(result.coord.lat)
                self.forecastTemp.text = numberFormatter.string(from: NSNumber(value: result.main.temp))
                self.forecastPre.text = String(result.main.pressure)
                self.forecastHum.text = String(result.main.humidity)
                let dateString = DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .short)
                self.forecastDate.text = dateString
                    
            }
            
        }
        task.resume()
            
    }
    
    func requestForecastForLocation() {
        let baseURLString = "https://api.openweathermap.org/data/2.5/weather?"
        let apiKey = "9df16a8c7148c6aeee1e2c4eec19fedd"

        var components = URLComponents(string: baseURLString)!
        var queryItems = [URLQueryItem]()
            
        var baseParam: [String: String] = ["appid":apiKey]
        baseParam["lat"] = String(locationForForecast!.coordinatesLat)
        baseParam["lon"] = String(locationForForecast!.coordinatesLon)
        baseParam["units"] = "metric"
        
        self.forecastInfo.infoCity = "My Location"
        self.forecastInfo.infoLon = locationForForecast!.coordinatesLon
        self.forecastInfo.infoLat = locationForForecast!.coordinatesLat
        
        
        for (key, value) in baseParam {
            let item = URLQueryItem(name: key, value: value)
            queryItems.append(item)
        }
        
        components.queryItems = queryItems
        
        let session: URLSession = {
            let config = URLSessionConfiguration.default
            return URLSession(configuration: config)
        }()
        
        let request = URLRequest(url: components.url!)
        let task = session.dataTask(with: request) {
            (data, response, error) in
            
            guard let jsonData = data, error == nil else {
                print("Unexpected error with the request")
                return
            }
        
            var json: Forecast?
            do {
                json = try JSONDecoder().decode(Forecast.self, from: jsonData)
            }
            catch {
                print("error: \(error)")
            }
        
            guard let result = json else {
                return
            }
            
            
            self.forecastInfo.infoTemp = result.main.temp
            self.forecastInfo.infoPresurre = Int32(result.main.pressure)
            self.forecastInfo.infoHumidity = Int32(result.main.humidity)
            
            
            DispatchQueue.main.async {
                self.forecastTemp.text = self.numberFormatter.string(from: NSNumber(value: result.main.temp))
                self.forecastPre.text = String(result.main.pressure)
                self.forecastHum.text = String(result.main.humidity)
                let dateString = DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .short)
                self.forecastDate.text = dateString
            }
            
        }
        task.resume()
            
    }
}

class ForecastInfo {
    
    var infoCity: String = ""
    var infoLat: Double = 0
    var infoLon: Double = 0
    var infoTemp: Double = 0
    var infoPresurre: Int32 = 0
    var infoHumidity: Int32 = 0
    
    init() {
        
    }
    
}


// MARK: - Forecast
struct Forecast: Codable {
    let coord: Coord
    let weather: [Weather]
    let base: String
    let main: Main
    let visibility: Int
    let wind: Wind
    let clouds: Clouds
    let dt: Int
    let sys: Sys
    let timezone, id: Int
    let name: String
    let cod: Int
}

// MARK: - Clouds
struct Clouds: Codable {
    let all: Int!
}

// MARK: - Coord
struct Coord: Codable {
    let lon, lat: Double
}

// MARK: - Main
struct Main: Codable {
    let temp, feelsLike, tempMin, tempMax: Double!
    let pressure, humidity: Int!

    enum CodingKeys: String, CodingKey {
        case temp
        case feelsLike = "feels_like"
        case tempMin = "temp_min"
        case tempMax = "temp_max"
        case pressure, humidity
    }
}

// MARK: - Sys
struct Sys: Codable {
    let type, id: Int!
    let country: String!
    let sunrise, sunset: Int!
}

// MARK: - Weather
struct Weather: Codable {
    let id: Int!
    let main, weatherDescription, icon: String!

    enum CodingKeys: String, CodingKey {
        case id, main
        case weatherDescription = "description"
        case icon
    }
}

// MARK: - Wind
struct Wind: Codable {
    let speed: Double!
    let deg: Int!
    let gust: Double!
}
