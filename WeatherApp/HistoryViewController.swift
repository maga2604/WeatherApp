//
//  HistoryViewController.swift
//  WeatherApp
//
//  Created by Maga Rajic on 26.09.2021..
//

import UIKit
import CoreData

class HistoryViewController: UITableViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var items:[ForecastData]?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadData()
    }
    
    func loadData() {
        
        do {
            self.items = try context.fetch(ForecastData.fetchRequest())
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        catch {
            print("Error loading data.")
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items!.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Get a new or recycled cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as! ItemCell
                
        // Set the text on the cell with the description of the item
        // that is at the nth index of items, where n = row this cell
        // will appear in on the table view
        let item = items![indexPath.row]
        
        cell.cityLabel?.text = item.forecastLocation!
        let dateString = DateFormatter.localizedString(from: item.forecastDate!, dateStyle: .short, timeStyle: .none)
        cell.dateLabel?.text = dateString
        cell.tempLabel?.text = String(item.forecastTemperature)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let action = UIContextualAction(style: .destructive, title: "Delete") {
            (action, view, completionHandler) in
            
            let itemToRemove = self.items![indexPath.row]
            
            self.context.delete(itemToRemove)
            
            do {
                try self.context.save()
            }
            catch {
                print("Error saving data.")
            }
            
            self.loadData()
            
        }
        
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 65
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showItem":
            if let row = tableView.indexPathForSelectedRow?.row {
                let forecast = items![row]
                let historyViewController = segue.destination as! HistoryDetailsViewController
                historyViewController.forecastInfo = forecast
                }
        default:
            preconditionFailure("Unexpected segue identifier")
        }
        
    }
    
    
}
