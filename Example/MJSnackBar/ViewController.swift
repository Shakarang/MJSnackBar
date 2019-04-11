//
//  ViewController.swift
//  MJSnackBar
//
//  Created by Maxime Junger on 04/02/2016.
//  Copyright (c) 2016 Maxime Junger. All rights reserved.
//

import UIKit
//import MJSnackBar

class ViewController: UIViewController {
    
    @IBOutlet weak var examplTableView: UITableView!
    
    var snackbar: MJSnackBar!
    
    var dataArray: [String]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.edgesForExtendedLayout = UIRectEdge()
        
        self.dataArray = [
            "Walk the dog",
            "Take a shower",
            "Clean house",
            "Shopping"
        ]
        
        snackbar = MJSnackBar(onView: self.view)
        snackbar.delegate = self
    }
}

extension ViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        cell.textLabel?.text = dataArray[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == UITableViewCell.EditingStyle.delete {
            
            let msg = "Deleted : \(dataArray[indexPath.row])"
            
            let data = MJSnackBarData(withIdentifier: indexPath.row, message: msg, andActionMessage: "UNDO", objectSaved: dataArray[indexPath.row])
            
            snackbar.show(data: data, onView: self.view)
            
            dataArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
        }
    }
    
}

extension ViewController: UITableViewDelegate {
    
   func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension ViewController: MJSnackBarDelegate {
    
    func snackBarDisappeared(with data: MJSnackBarData, reason: MJSnackBar.EndShowingType) {
        print("👻 SnackBar disappeared \(data.message) - Reason : \(reason)")
    }
    
    func snackBarAppeared(with data: MJSnackBarData) {
        print("⭐ SnackBar appeared \(data.message)")
    }
    
    func snackBarActionTriggered(with data: MJSnackBarData) {
        
        print("👆 SnackBar touched \(data.message)")
        
        if let id = data.id {
            
            let indexPath = IndexPath(row: id, section: 0)
            
            if let originalData = data.originalObject as? String {
                self.dataArray.insert(originalData, at: id)
            }
            
            self.examplTableView.insertRows(at: [indexPath], with: .automatic)
        }
    }
}
