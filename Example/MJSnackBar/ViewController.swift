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
	
	var snackbar: MJSnackBar!
	
	var dataArray = [
		"Walking the dog",
		"Take a shower",
		"Clean house"
	]
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		
		self.edgesForExtendedLayout = UIRectEdge()
		
		// snackbar = MJSnackBar(custom: customSnackBar)
		//snackbar = MJSnackBar(type: MJSnackBar.SnackType.android)
        
        snackbar = MJSnackBar(onView: self.view)
        
		//snackbar.addCustomStyle(customSnackBar)
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
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
			let savedString = dataArray[indexPath.row]
			let savedPos = indexPath
			dataArray.remove(at: indexPath.row)
			tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
			
			var msg = savedString
            
            let data = MJSnackBar.SnackBarData(id: indexPath.row, message: msg, action: nil)
            
            snackbar.show(data: data, onView: self.view)
            

//			snackbar.show(onView: self.view, message: msg + savedString, completion: {reason in
//				// Handle the way the view disappeared nicely
//				if reason == MJSnackBar.EndShowingType.user {
//					self.dataArray.insert(savedString, at: savedPos.row)
//					tableView.insertRows(at: [savedPos], with: UITableViewRowAnimation.automatic)
//				}
//			})
		}
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
	}
}
