//
//  ViewController.swift
//  MJSnackBar
//
//  Created by Maxime Junger on 04/02/2016.
//  Copyright (c) 2016 Maxime Junger. All rights reserved.
//

import UIKit
//import MJSnackBar

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
	
    @IBOutlet weak var examplTableView: UITableView!

	var snackbar: MJSnackBar!
	
    var dataArray: [String]!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		
		self.edgesForExtendedLayout = UIRectEdge()
		
		// snackbar = MJSnackBar(custom: customSnackBar)
		//snackbar = MJSnackBar(type: MJSnackBar.SnackType.android)
        
        
//        self.dataArray = [
//            "Walking the dog",
//            "Take a shower",
//            "Clean house",
//        ]
        self.dataArray = [
            "1","2","3","4","5","6","7","8","9","10","11","12",
        ]
        
        
        
        snackbar = MJSnackBar(onView: self.view)
        snackbar.delegate = self
        snackbar.layer.masksToBounds = true
        snackbar.layer.cornerRadius = 3.0
        snackbar.sideMargins = 5.0
        snackbar.bottomMargin = 5.0
        snackbar.backgroundColor = UIColor.blue.withAlphaComponent(0.7)
        
		//snackbar.addCustomStyle(customSnackBar)
	}
	
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
	
	func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		
        if editingStyle == UITableViewCellEditingStyle.delete {

			let msg = "Deleted : \(dataArray[indexPath.row])"
            
            
            
            let data = MJSnackBarData(id: indexPath.row, message: msg, originalObject: dataArray[indexPath.row])
            
            snackbar.show(data: data, onView: self.view)
            
            dataArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
		}
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
	}
}

extension ViewController: MJSnackBarDelegate {
    
    func snackBarDisappeared(with data: MJSnackBarData, reason: MJSnackBar.EndShowingType) {
        print("👻 Snack disappeared \(data.message) - \(reason)")
    }
    
    func snackBarAppeared(with data: MJSnackBarData) {
        print("👍 Snackbar appeared \(data.message)")
    }
    
    func snackBarActionTriggered(with data: MJSnackBarData) {
        
        print("User pressed !!!")
        
        if let id = data.id {
            
            let indexPath = IndexPath(row: id, section: 0)
            
            if let originalData = data.originalObject as? String {
                self.dataArray.insert(originalData, at: id)
            }
            
            self.examplTableView.insertRows(at: [indexPath], with: .automatic)
        }
    }
}
