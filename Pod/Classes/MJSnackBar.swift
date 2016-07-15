//
//  MJSnackBar.swift
//  MJSnackBarExample
//
//  Created by Maxime Junger on 01/04/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit

public class MJSnackBar: NSObject {
	
	/**
	All views used to build the SnackBar
	*/
	private var _snackBarView: UIView!
	private var _snackBarActionText: UILabel?
	private var _snackBarLeftActionText: UILabel!
	
	/**
	Properties to build the main view frame
	*/
	private var _spaceOnSide: Double = 5.0
	private var _spaceOnBottom: Double = 5.0
	private var _snackViewHeight: Double = 50.0
	private var _backgroundColor: Int = 0x1D1D1D
	private var _backgroundAlpha: CGFloat = 0.8
	private var _corners: CGFloat = 3.0
	private var _androidValues: Bool = false
	private var _minimumHeight: Double = -1
	
	/**
	Set all times used for SnackBar
	*/
	private var _appearanceDuration: Double = 4.0
	private var _animationTime: Double = 0.3
	
	/**
	Properties to build the LeftAction label
	*/
	private var _leftActionText: String!
	private var _leftActionTextSize: CGFloat = 14.0
	private var _leftActionTextColor: Int = 0xFFFFFF
	
	/**
	Properties to build the ActionButton button
	*/
	private var _actionButtonTextSize: CGFloat = 14.0
	private var _actionButtonText: NSString = NSLocalizedString("Undo", comment: "")
	private var _actionButtonTextColorNormal: Int = 0xFFFFFF
	private var _actionButtonTextColorSelected: Int = 0xDDDDDD
	private var _snackBarItemsSideSize: CGFloat = 10.0
	
	/**
	Property to get the size of the current screen
	*/
	private var _screenSize: CGRect!
	
	/**
	Property to get if the view is shown or is showing
	*/
	private var _shown: Bool!
	private var _animating: Bool!
	
	/**
	Enum to know why SnackBar disappeared : due to Timer or User action
	*/
	public enum EndShowingType {
		case TIMER, USER
	}
	
	public enum SnackType {
		case DEFAULT, ANDROID
	}
	
	var completionMethod: ((EndShowingType)->())? = nil
	var _snackID = 0
	
	public override init() {
		
		super.init()
		_screenSize = UIScreen.mainScreen().bounds
		_shown = false
		_animating = false
		createView()
	}
	
	/**
	Init with custom data
	*/
	public init(custom: Dictionary<String, Any>) {
		
		super.init()
		
		if let spaceOnSide = custom["spaceOnSide"] { _spaceOnSide = spaceOnSide as! Double }
		if let spaceOnBottom = custom["spaceOnBottom"] { _spaceOnBottom = spaceOnBottom as! Double }
		if let snackViewHeight = custom["snackViewHeight"] { _snackViewHeight = snackViewHeight as! Double }
		if let backgroundColor = custom["backgroundColor"] { _backgroundColor = backgroundColor as! Int }
		if let backgroundAlpha = custom["backgroundAlpha"] { _backgroundAlpha = backgroundAlpha as! CGFloat }
		if let appearanceDuration = custom["appearanceDuration"] { _appearanceDuration = appearanceDuration as! Double }
		if let animationTime = custom["animationTime"] { _animationTime = animationTime as! Double }
		if let leftActionTextColor = custom["leftActionTextColor"] { _leftActionTextColor = leftActionTextColor as! Int }
		if let actionButtonText = custom["actionButtonText"] {	_actionButtonText = actionButtonText as! String }
		if let actionButtonTextColorNormal = custom["actionButtonTextColorNormal"] { _actionButtonTextColorNormal = actionButtonTextColorNormal as! Int }
		if let actionButtonTextColorSelected = custom["actionButtonTextColorSelected"] { _actionButtonTextColorSelected = actionButtonTextColorSelected as! Int }
		
		_screenSize = UIScreen.mainScreen().bounds
		_shown = false
		_animating = false
		createView()
	}
	
	public init(type: SnackType) {
		
		super.init()
		
		switch type {
		case .ANDROID:
			_androidValues = true
			officialSnack()
			break
		default:
			break
		}
		
		_screenSize = UIScreen.mainScreen().bounds
		_shown = false
		_animating = false
		createView()
	}
	
	
	public func addCustomStyle(custom: Dictionary<String, Any>) {
		
		if let spaceOnSide = custom["spaceOnSide"] { _spaceOnSide = spaceOnSide as! Double }
		if let spaceOnBottom = custom["spaceOnBottom"] { _spaceOnBottom = spaceOnBottom as! Double }
		if let snackViewHeight = custom["snackViewHeight"] { _snackViewHeight = snackViewHeight as! Double }
		if let backgroundColor = custom["backgroundColor"] { _backgroundColor = backgroundColor as! Int }
		if let backgroundAlpha = custom["backgroundAlpha"] { _backgroundAlpha = backgroundAlpha as! CGFloat }
		if let appearanceDuration = custom["appearanceDuration"] { _appearanceDuration = appearanceDuration as! Double }
		if let animationTime = custom["animationTime"] { _animationTime = animationTime as! Double }
		if let leftActionTextColor = custom["leftActionTextColor"] { _leftActionTextColor = leftActionTextColor as! Int }
		if let actionButtonText = custom["actionButtonText"] {	_actionButtonText = actionButtonText as! String }
		if let actionButtonTextColorNormal = custom["actionButtonTextColorNormal"] { _actionButtonTextColorNormal = actionButtonTextColorNormal as! Int }
		if let actionButtonTextColorSelected = custom["actionButtonTextColorSelected"] { _actionButtonTextColorSelected = actionButtonTextColorSelected as! Int }
	}
	
	/*!
	Creates a SnackBar with the same style as Google one
	*/
	private func officialSnack() {
		_spaceOnSide = 0.0
		_spaceOnBottom = 0.0
		_corners = 0
		_minimumHeight = 48
		_actionButtonTextColorNormal = 0xFF0000
		_actionButtonTextColorSelected = 0x00FF00
	}
	
	/**
	Creates the SnackBar main view with all properties
	*/
	private func createView() {
		
		_snackBarView = UIView(frame: CGRect(x: _spaceOnSide,
			y: Double(_screenSize.height) + 1,
			width: Double(_screenSize.width) - (_spaceOnSide * 2),
			height: _snackViewHeight))
		_snackBarView.backgroundColor = UIColor.init(netHex: _backgroundColor)
		_snackBarView.backgroundColor = _snackBarView.backgroundColor?.colorWithAlphaComponent(_backgroundAlpha)
		
		_snackBarView.layer.cornerRadius = _corners
		_snackBarView.layer.masksToBounds = true
		addActionButton()
	}
	
	
	private func addActionButton() {
		
		let textSize = _actionButtonText.sizeWithAttributes([NSFontAttributeName: UIFont.boldSystemFontOfSize(_actionButtonTextSize)])
		
		_snackBarActionText = UILabel(frame: CGRect(x: (_snackBarView.frame.width - textSize.width) - _snackBarItemsSideSize,
			y: (_snackBarView.frame.height / 2) - (textSize.height / 2),
			width: textSize.width + 3,
			height: textSize.height))
		
		_snackBarActionText?.text = _actionButtonText as String
		_snackBarActionText?.textColor = UIColor.init(netHex:_actionButtonTextColorNormal)
		
		_snackBarActionText?.font = UIFont.boldSystemFontOfSize(_actionButtonTextSize)
		
		_snackBarActionText?.textAlignment = .Right
		
		_snackBarView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapOnViewHandler)))
		
		_snackBarView.addSubview(_snackBarActionText!)
	}
	
	/**
	Create and add the left action text
	*/
	private func addActionText(message: String) {
		
		let textSize = (message as NSString).sizeWithAttributes([NSFontAttributeName: UIFont.systemFontOfSize(_leftActionTextSize)])
		
		var textWidth: CGFloat = textSize.width + 3
		
		if (_screenSize.width - textWidth - CGFloat(_snackBarItemsSideSize * 2) - (_snackBarActionText?.frame.width)! < 0) {
			textWidth = _screenSize.width - (_snackBarActionText?.frame.width)! - CGFloat(_snackBarItemsSideSize * 2) - 10
		}
		
		_snackBarLeftActionText = UILabel(frame: CGRect(x: _snackBarItemsSideSize,
			y: (_snackBarView.frame.height / 2) - (textSize.height / 2),
			width: textWidth,
			height: textSize.height))
		
		let hght = _snackBarActionText?.frame.size
		
		_snackBarLeftActionText.lineBreakMode = .ByWordWrapping
		_snackBarLeftActionText.numberOfLines = 0
		_snackBarLeftActionText.text = message
		_snackBarLeftActionText.textColor = UIColor.init(netHex: _leftActionTextColor)
		_snackBarLeftActionText.font = UIFont.systemFontOfSize(_leftActionTextSize)
		
		_snackBarLeftActionText?.frame = CGRectMake((_snackBarLeftActionText?.frame.origin.x)!, (_snackBarLeftActionText?.frame.origin.y)!, (_snackBarLeftActionText?.frame.size.width)!, (_snackBarLeftActionText?.requiredHeight())!)
		
		
		let neededLinesForLabel = _snackBarLeftActionText.frame.height / textSize.height
		
		let nf = _snackBarLeftActionText?.frame.size
		let h = _snackBarLeftActionText?.requiredHeight()
		
		var snHeight: CGFloat
		
		if (_androidValues == true) {
			
			if (neededLinesForLabel < 2) {
				snHeight = 28 + _snackBarLeftActionText.frame.size.height
			} else {
				snHeight = 48 + _snackBarLeftActionText.frame.size.height
			}
		} else {
			snHeight = _snackBarItemsSideSize + _snackBarLeftActionText.frame.size.height
		}
		
		if (self._minimumHeight > -1 && Double(snHeight) < self._minimumHeight) {
			snHeight = CGFloat(self._minimumHeight)
		}
		
		let positionY = CGFloat(_screenSize.height) - CGFloat(snHeight)
		
		_snackBarView?.frame = CGRectMake((_snackBarView?.frame.origin.x)!, CGFloat(_screenSize.height) + 1, (_snackBarView?.frame.size.width)!,
		                                  snHeight)
		
		_snackViewHeight = Double(snHeight)
		_snackBarView.addSubview(_snackBarLeftActionText!)
	}
	
	private func adjustViews() {
		
		let snackMiddle = _snackBarView.frame.height / 2
		
		_snackBarActionText?.frame = CGRectMake((_snackBarActionText?.frame.origin.x)!, (snackMiddle - CGFloat((_snackBarActionText?.frame.height)!) / 2), (_snackBarActionText?.frame.size.width)!, (_snackBarActionText?.frame.height)!)
		
		_snackBarLeftActionText?.frame = CGRectMake((_snackBarLeftActionText?.frame.origin.x)!, (snackMiddle - CGFloat((_snackBarLeftActionText?.frame.height)!) / 2), (_snackBarLeftActionText?.frame.size.width)!, (_snackBarLeftActionText?.frame.height)!)
		
	}
	
	/**
	Show the SnackBar on view passed on parameter
	*/
	public func show(onView: UIView, message: String, completion: (MJSnackBar.EndShowingType)->()) {
		
		if (_animating == true) {
			return
		}
		_snackID += 1
		completionMethod = completion
		if (_shown == true) {
			hideSnackView() {
				self.showSnackView(onView, message: message) {
					completion(EndShowingType.USER)
				}
			}
		} else {
			self.showSnackView(onView, message: message) {
				completion(EndShowingType.TIMER)
			}
		}
		
	}
	
	private func showSnackView(onView: UIView, message: String, completion: ()->()) {
		_animating = true
		addActionText(message)
		adjustViews()
		onView.addSubview(_snackBarView)
		
		UIView.animateWithDuration(_animationTime, animations: { _ in
			self._snackBarView.frame = CGRect(x: self._spaceOnSide,
				y: Double(self._screenSize.height) - (self._spaceOnBottom + self._snackViewHeight),
				width: Double(self._screenSize.width) - (self._spaceOnSide * 2),
				height: self._snackViewHeight)
			
			}, completion: { _ in
				self._animating = false
				self._shown = true
				dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
					let tmp = self._snackID
					NSThread.sleepForTimeInterval(NSTimeInterval(self._appearanceDuration))
					if (tmp != self._snackID) { return }
					dispatch_async(dispatch_get_main_queue(), {
						if (self._shown == true) {
							self.hideSnackView() {
								completion()
							}
						}
					})
				})
		})
		
	}
	
	/*!
	Dismiss the SnackbarView
	*/
	public func dismiss() {
		
		hideSnackView() {
			if (self.completionMethod != nil) {
				self.completionMethod!(EndShowingType.USER)
			}
		}
	}
	
	private func hideSnackView(completion: () -> ()) {
		if (_shown == false || _animating == true) {
			return
		}
		_animating = true
		UIView.animateWithDuration(_animationTime, animations: { _ in
			self._snackBarView.frame = CGRect(x: Double(self._snackBarView.frame.origin.x),
				y: Double(self._screenSize.height) + 1,
				width: Double(self._snackBarView.frame.width),
				height: self._snackViewHeight)
			
			}, completion: {_ in
				self._snackBarLeftActionText.removeFromSuperview()
				self._snackBarView.removeFromSuperview()
				self._animating = false
				self._shown = false
				completion()
		})
	}
	
	/*!
	Triggered when the user tap on the view
	- parameter sender:	view
	*/
	func tapOnViewHandler(sender: AnyObject) {
		dismiss()
	}
	
}

extension UILabel {
	
	func requiredHeight() -> CGFloat {
		
		let label: UILabel = UILabel(frame: CGRectMake(0, 0, self.frame.width, CGFloat.max))
		label.numberOfLines = 0
		label.lineBreakMode = NSLineBreakMode.ByWordWrapping
		label.font = self.font
		label.text = self.text
		
		label.sizeToFit()
		
		return label.frame.height
	}
}
