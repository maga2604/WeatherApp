//
//  CityViewController.swift
//  WeatherApp
//
//  Created by Maga Rajic on 25.09.2021..
//

import UIKit

class CityViewController: UITableViewController {
    
    var allCityForForecast = [CityForForecast]()
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


