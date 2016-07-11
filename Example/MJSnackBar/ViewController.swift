//
//  ViewController.swift
//  MJSnackBar
//
//  Created by Maxime Junger on 04/02/2016.
//  Copyright (c) 2016 Maxime Junger. All rights reserved.
//

import UIKit
import MJSnackBar

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

	var snackbar: MJSnackBar! = MJSnackBar()

	var dataArray = [
		"Walking the dog",
		"Take a shower",
		"Clean house"
	]

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.

		self.edgesForExtendedLayout = .None

		var customSnackBar = Dictionary<String, Any>()
		customSnackBar["spaceOnSide"] = 5.0
		customSnackBar["spaceOnBottom"] = 5.0
		customSnackBar["snackViewHeight"] = 50.0
		customSnackBar["backgroundColor"] = 0x1D1D1D
		customSnackBar["backgroundAlpha"] = CGFloat(0.8)
		customSnackBar["appearanceDuration"] = 4.0
		customSnackBar["animationTime"] = 0.3
		customSnackBar["leftActionTextColor"] = 0xFFFFFF
		customSnackBar["actionButtonText"] = "Undo"
		customSnackBar["actionButtonTextColorNormal"] = 0xFFFFFF
		customSnackBar["actionButtonTextColorSelected"] = 0xFF0000

		// snackbar = MJSnackBar(custom: customSnackBar)
		snackbar = MJSnackBar(type: MJSnackBar.SnackType.ANDROID)
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}

	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return dataArray.count
	}

	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = UITableViewCell()

		cell.textLabel?.text = dataArray[indexPath.row]

		return cell
	}

	func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		return true
	}

	func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
		if editingStyle == UITableViewCellEditingStyle.Delete {
			let savedString = dataArray[indexPath.row]
			let savedPos = indexPath
			dataArray.removeAtIndex(indexPath.row)
			tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
			snackbar.show(self.view, message: "Deleted slslslslsllslslslslslslslslslslslslslslslslsllslslslsl: " + savedString, completion: {reason in
				// Handle the way the view disappeared nicely
				if reason == MJSnackBar.EndShowingType.USER {
					self.dataArray.insert(savedString, atIndex: savedPos.row)
					tableView.insertRowsAtIndexPaths([savedPos], withRowAnimation: UITableViewRowAnimation.Automatic)
				}
			})
		}
	}

	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
	}
}
