//
//  HistoryDetails.swift
//  WeatherApp
//
//  Created by Maga Rajic on 26.09.2021..
//

import UIKit
import CoreData

class HistoryDetailsViewController: UIViewController {
        
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var forecastInfo: ForecastData!
    
    let numberFormatter: NumberFormatter = {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        nf.maximumFractionDigits = 2
        return nf
    }()
    
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var latLable: UILabel!
    @IBOutlet var lonLabel: UILabel!
    @IBOutlet var tempLable: UILabel!
    @IBOutlet var pressureLable: UILabel!
    @IBOutlet var humidityLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    
    @IBAction func changeUnits(_ sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 0:
            tempLable.text = numberFormatter.string(from: NSNumber(value: forecastInfo.forecastTemperature))
        case 1:
            tempLable.text = numberFormatter.string(from: NSNumber(value: forecastInfo.forecastTemperature*9/5 + 32))
        default:
            tempLable.text = numberFormatter.string(from: NSNumber(value: forecastInfo.forecastTemperature))
        }
        
    }
    
    @IBAction func deleteItem(_ sender: UIButton) {
        let itemToRemove = self.forecastInfo
        self.context.delete(itemToRemove!)
        do {
            try self.context.save()
        }
        catch {
            print("Error saving data.")
        }
        _ = navigationController?.popViewController(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        locationLabel.text = forecastInfo.forecastLocation
        latLable.text = String(forecastInfo.forecastLatitude)
        lonLabel.text = String(forecastInfo.forecastLongitude)
        tempLable.text =  numberFormatter.string(from: NSNumber(value: forecastInfo.forecastTemperature))
        pressureLable.text = String(forecastInfo.forecastPressure)
        humidityLabel.text = String(forecastInfo.forecastHumidity)
        let dateString = DateFormatter.localizedString(from: forecastInfo.forecastDate!, dateStyle: .medium, timeStyle: .short)
        dateLabel.text = dateString
        
        
    }
    
}

