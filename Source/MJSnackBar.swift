//
//  MJSnackBar.swift
//  MJSnackBarExample
//
//  Created by Maxime Junger on 01/04/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit

protocol MJSnackBarDelegate {
    func snackBarAppeared(withData: MJSnackBar.SnackBarData)
    func snackBarDisappeared(withData: MJSnackBar.SnackBarData, reason: MJSnackBar.EndShowingType)
}

class MJSnackBar: UIView, MJSnackBarDelegate {
 
    struct SnackBarData {
        
        var id: Int? = nil
        var message: String
        var action: String? = nil
        
        static func ==(left: SnackBarData, right: SnackBarData) -> Bool {
            if left.id == right.id
                && left.message == right.message
                && left.action == right.action {
                return true
            }
            return false
        }
    }
    
    var dataToDisplay = [SnackBarData]()
    
    /// Enum to know why SnackBar disappeared : due to Timer or User action
    ///
    /// - timer: The timer ended, normal behaviour
    /// - user: The user pressed the undo button. You have to handle it
    public enum EndShowingType {
        case timer, over, user
    }
    
    /// Animation duration
    public var animationDuration: Double = 0.4
    
    /// How long the SnackBar will be shown
    public var timeSnackBarShown: Double = 2.0
    
    /// SnackBar height
    public var snackBarHeight: CGFloat = 48.0
    
    /// SnackBar margins

    /// Current view the bar is shown on
    private var showingOnView: UIView? = nil
    
    /// SnackBar bottom constraint
    private var bottomConstraint: NSLayoutConstraint!
    
    /// Constraint identifier. Used to track it
    private var constraintIdentifier = "snackBarConstraintBottom"
    
    /// Used to know if there is a SnackBar displaying
    private var isCurrentlyShown = false
    
    /// Used to know the number of SnackBar displayed.
    /// Also used for removing the view.
    private var snackBarID = 0
    
    private var currentlyDisplayedData: SnackBarData? = nil
    
    public init(onView: UIView) {
        
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        
        self.backgroundColor = UIColor(red:0.11, green:0.11, blue:0.11, alpha:1.0)
        self.showingOnView = onView
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public func show(data: SnackBarData, onView view: UIView) {
        
        if self.isCurrentlyShown {
            self.animate(show: false, reasonToHide: .over) {
                
                self.currentlyDisplayedData = data
                self.snackBarID += 1
                self.createSnackBar()
                self.animate(show: true) { }
            }
        } else {
            self.currentlyDisplayedData = data
            self.snackBarID += 1
            self.createSnackBar()
            self.animate(show: true) { }
        }
    }
    
    private func createSnackBar() {
        
        
        guard let view = self.showingOnView else {
            return
        }
        
        self.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(self)
        
        let leftConstraint = NSLayoutConstraint(item: self,
                                                attribute: NSLayoutAttribute.leading,
                                                relatedBy: NSLayoutRelation.equal,
                                                toItem: view,
                                                attribute: NSLayoutAttribute.leading,
                                                multiplier: 1, constant: 0)
        
        let rightConstraint = NSLayoutConstraint(item: self,
                                                 attribute: NSLayoutAttribute.trailing,
                                                 relatedBy: NSLayoutRelation.equal,
                                                 toItem: view,
                                                 attribute: NSLayoutAttribute.trailing,
                                                 multiplier: 1, constant: 0)
        
        self.bottomConstraint = NSLayoutConstraint(item: self,
                                                   attribute: NSLayoutAttribute.bottom,
                                                   relatedBy: NSLayoutRelation.equal,
                                                   toItem: view,
                                                   attribute: NSLayoutAttribute.bottom,
                                                   multiplier: 1, constant: self.snackBarHeight)
        self.bottomConstraint.identifier = self.constraintIdentifier
        
        
        let heightConstraint = NSLayoutConstraint(item: self,
                                                  attribute: NSLayoutAttribute.height,
                                                  relatedBy: NSLayoutRelation.equal,
                                                  toItem: nil,
                                                  attribute: NSLayoutAttribute.notAnAttribute,
                                                  multiplier: 1, constant: self.snackBarHeight)

        NSLayoutConstraint.activate([leftConstraint, rightConstraint, bottomConstraint, heightConstraint])
    }
    
    func animate(show: Bool, reasonToHide: EndShowingType = .timer, completion: @escaping () -> Void) {
        
        guard let view = self.showingOnView else {
            return
        }
        
        DispatchQueue.main.async {
            
            view.layoutIfNeeded()
            
            // Should show the snack bar
            if show {
                view.layoutIfNeeded()
                self.bottomConstraint?.constant = 0
                UIView.animate(withDuration: self.animationDuration, animations: {
                    view.layoutIfNeeded()
                }, completion: { _ in
                    
                    print("View \(self.snackBarID) shown.")
                    
                    self.isCurrentlyShown = true
                    self.hide(afterDelay: true, reason: .timer)
                        completion()
                })
            } else {
                    self.bottomConstraint?.constant = self.snackBarHeight
                    UIView.animate(withDuration: self.animationDuration, animations: {
                        view.layoutIfNeeded()
                    }, completion: { _ in
                        self.isCurrentlyShown = false
                        // Need to remove constraint after hiding
                        for constraint in view.constraints {
                            if constraint.identifier == self.constraintIdentifier {
                                view.removeConstraint(constraint)
                            }
                        }
                        
                        self.snackBarDisappeared(withData: self.currentlyDisplayedData!, reason: reasonToHide)
                        
                        completion()
                    })
            }
        }
        
    }
    
    func hide(afterDelay: Bool, reason: EndShowingType) {
        
        DispatchQueue.global().async {
            
            let tmp = self.currentlyDisplayedData!
            let tmpID = self.snackBarID
    
            if afterDelay {
                Thread.sleep(forTimeInterval: self.timeSnackBarShown)
            }
            
            if tmpID == self.snackBarID && tmp == self.currentlyDisplayedData! {
                self.animate(show: false, reasonToHide: reason) {
                    print("Hidden \(tmp) - \(reason)")
                }
            }
        }
    }
    
    func snackBarDisappeared(withData: MJSnackBar.SnackBarData, reason: EndShowingType) {
        print("Snack disappeared ouloulou \(withData.message) - \(reason)")
    }
    
    func snackBarAppeared(withData: MJSnackBar.SnackBarData) {
        print("Snackbar appeared \(withData.message)")
    }
    
//    func checkIfQueueIsEmpty() {
//        if let otherBar = self.dataToDisplay.first {
//            self.createSnackBar()
//            self.animate(show: true)
//        }
//    }
    
}

//open class MJSnackBar {
//
//	/**
//	All views used to build the SnackBar
//	*/
//	 var snackBarView: UIView!
//	 var snackBarActionText: UILabel?
//	 var snackBarLeftActionText: UILabel!
//
//	/**
//	Properties to build the main view frame
//	*/
//	 var spaceOnSide: Double = 5.0
//	 var spaceOnBottom: Double = 5.0
//	 var snackViewHeight: Double = 50.0
//	 var backgroundColor: Int = 0x1D1D1D
//	 var backgroundAlpha: CGFloat = 0.8
//	 var corners: CGFloat = 3.0
//	 var androidValues: Bool = false
//	 var minimumHeight: Double = -1
//
//	/**
//	Set all times used for SnackBar
//	*/
//	 var appearanceDuration: Double = 4.0
//	 var animationTime: Double = 0.3
//
//	/**
//	Properties to build the LeftAction label
//	*/
//	 var leftActionText: String!
//	 var leftActionTextSize: CGFloat = 14.0
//	 var leftActionTextColor: Int = 0xFFFFFF
//
//	/**
//	Properties to build the ActionButton button
//	*/
//	 var actionButtonTextSize: CGFloat = 14.0
//	 var actionButtonText: NSString = NSLocalizedString("Undo", comment: "") as NSString
//	 var actionButtonTextColorNormal: Int = 0xFFFFFF
//	 var actionButtonTextColorSelected: Int = 0xDDDDDD
//	 var snackBarItemsSideSize: CGFloat = 10.0
//
//	/**
//	Property to get the size of the current screen
//	*/
//	 var screenSize: CGRect!
//
//	/**
//	Property to get if the view is shown or is showing
//	*/
//	 var shown: Bool!
//	 var animating: Bool!
//
//	/**
//	Enum to know why SnackBar disappeared : due to Timer or User action
//	*/
//	public enum EndShowingType {
//		case timer, user
//	}
//
//	public enum SnackType {
//		case `default`, android
//	}
//
//	var completionMethod: ((EndShowingType)->())? = nil
//	var snackID = 0
//
//	public init() {
//		screenSize = UIScreen.main.bounds
//		shown = false
//		animating = false
//		createView()
//		NotificationCenter.default.addObserver(self, selector: #selector(MJSnackBar.rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
//	}
//
////	/**
////	Init with custom data
////	*/
////	public init(custom: Dictionary<String, Any>) {
////
////		if let spaceOnSide = custom["spaceOnSide"] { spaceOnSide = spaceOnSide as! Double }
////		if let spaceOnBottom = custom["spaceOnBottom"] { spaceOnBottom = spaceOnBottom as! Double }
////		if let snackViewHeight = custom["snackViewHeight"] { snackViewHeight = snackViewHeight as! Double }
////		if let backgroundColor = custom["backgroundColor"] { backgroundColor = backgroundColor as! Int }
////		if let backgroundAlpha = custom["backgroundAlpha"] { backgroundAlpha = backgroundAlpha as! CGFloat }
////		if let appearanceDuration = custom["appearanceDuration"] { appearanceDuration = appearanceDuration as! Double }
////		if let animationTime = custom["animationTime"] { animationTime = animationTime as! Double }
////		if let leftActionTextColor = custom["leftActionTextColor"] { leftActionTextColor = leftActionTextColor as! Int }
////		if let actionButtonText = custom["actionButtonText"] {	actionButtonText = actionButtonText as! String as NSString }
////		if let actionButtonTextColorNormal = custom["actionButtonTextColorNormal"] { actionButtonTextColorNormal = actionButtonTextColorNormal as! Int }
////		if let actionButtonTextColorSelected = custom["actionButtonTextColorSelected"] { actionButtonTextColorSelected = actionButtonTextColorSelected as! Int }
////
////		screenSize = UIScreen.main.bounds
////		shown = false
////		animating = false
////		createView()
////		NotificationCenter.default.addObserver(self, selector: #selector(MJSnackBar.rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
////
////	}
//
//	public init(type: SnackType) {
//
//		switch type {
//		case .android:
//			androidValues = true
//			officialSnack()
//			break
//		default:
//			break
//		}
//
//		screenSize = UIScreen.main.bounds
//		shown = false
//		animating = false
//		createView()
//		NotificationCenter.default.addObserver(self, selector: #selector(MJSnackBar.rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
//	}
//
//
////	open func addCustomStyle( custom: Dictionary<String, Any>) {
////		if let spaceOnSide = custom["spaceOnSide"] { spaceOnSide = spaceOnSide as! Double }
////		if let spaceOnBottom = custom["spaceOnBottom"] { spaceOnBottom = spaceOnBottom as! Double }
////		if let snackViewHeight = custom["snackViewHeight"] { snackViewHeight = snackViewHeight as! Double }
////		if let backgroundColor = custom["backgroundColor"] { backgroundColor = backgroundColor as! Int }
////		if let backgroundAlpha = custom["backgroundAlpha"] { backgroundAlpha = backgroundAlpha as! CGFloat }
////		if let appearanceDuration = custom["appearanceDuration"] { appearanceDuration = appearanceDuration as! Double }
////		if let animationTime = custom["animationTime"] { animationTime = animationTime as! Double }
////		if let leftActionTextColor = custom["leftActionTextColor"] { leftActionTextColor = leftActionTextColor as! Int }
////		if let actionButtonText = custom["actionButtonText"] {	actionButtonText = actionButtonText as! String as NSString }
////		if let actionButtonTextColorNormal = custom["actionButtonTextColorNormal"] { actionButtonTextColorNormal = actionButtonTextColorNormal as! Int }
////		if let actionButtonTextColorSelected = custom["actionButtonTextColorSelected"] { actionButtonTextColorSelected = actionButtonTextColorSelected as! Int }
////	}
//
//	/*!
//	Creates a SnackBar with the same style as Google one
//	*/
//	 func officialSnack() {
//		spaceOnSide = 0.0
//		spaceOnBottom = 0.0
//		corners = 0
//		minimumHeight = 48
//		backgroundColor = 0x323232
//		backgroundAlpha = 1
//		actionButtonTextColorNormal = 0xFF0000
//		actionButtonTextColorSelected = 0x00FF00
//
//		self.changePropertiesIfIPad()
//	}
//
//	 func changePropertiesIfIPad() {
//
//		let orientation = UIApplication.shared.statusBarOrientation
//
//		if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
//			let screenWidth: CGFloat = UIScreen.main.bounds.width
//
//			if orientation.isLandscape {
//				let restSpace = screenWidth - 568
//				spaceOnSide = Double(restSpace) / 2
//			}
//
//
//		}
//
//	}
//
//	/**
//	Creates the SnackBar main view with all properties
//	*/
//	 func createView() {
//
//		self.screenSize = UIScreen.main.bounds
//
//		snackBarView = UIView(frame: CGRect(x: spaceOnSide,
//			y: Double(screenSize.height) + 1,
//			width: Double(screenSize.width) - (spaceOnSide * 2),
//			height: snackViewHeight))
//
//		snackBarView.backgroundColor = UIColor.init(netHex: backgroundColor)
//		snackBarView.backgroundColor = snackBarView.backgroundColor?.withAlphaComponent(backgroundAlpha)
//
//		snackBarView.layer.cornerRadius = corners
//		snackBarView.layer.masksToBounds = true
//	}
//
//
//	 func addActionButton() {
//
//		let textSize = actionButtonText.size(attributes: [NSFontAttributeName: UIFont.boldSystemFont(ofSize: actionButtonTextSize)])
//
//		snackBarActionText = UILabel(frame: CGRect(x: (snackBarView.frame.width - textSize.width) - snackBarItemsSideSize,
//			y: (snackBarView.frame.height / 2) - (textSize.height / 2),
//			width: textSize.width + 3,
//			height: textSize.height))
//
//		snackBarActionText?.text = actionButtonText as String
//		snackBarActionText?.textColor = UIColor.init(netHex:actionButtonTextColorNormal)
//
//		snackBarActionText?.font = UIFont.boldSystemFont(ofSize: actionButtonTextSize)
//
//		snackBarActionText?.textAlignment = .right
//
//		snackBarView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapOnViewHandler)))
//
//		snackBarView.addSubview(snackBarActionText!)
//	}
//
//	/**
//	Create and add the left action text
//	*/
//	 func addActionText( message: String) {
//
//		let textSize = (message as NSString).size(attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: leftActionTextSize)])
//
//		var textWidth: CGFloat = textSize.width + 3
//
//		if (screenSize.width - textWidth - CGFloat(snackBarItemsSideSize * 2) - (snackBarActionText?.frame.width)! < 0) {
//			textWidth = screenSize.width - (snackBarActionText?.frame.width)! - CGFloat(snackBarItemsSideSize * 2) - 10
//		}
//
//		snackBarLeftActionText = UILabel(frame: CGRect(x: snackBarItemsSideSize,
//			y: (snackBarView.frame.height / 2) - (textSize.height / 2),
//			width: textWidth,
//			height: textSize.height))
//
//		let hght = snackBarActionText?.frame.size
//
//		snackBarLeftActionText.lineBreakMode = .byWordWrapping
//		snackBarLeftActionText.numberOfLines = 0
//		snackBarLeftActionText.text = message
//		snackBarLeftActionText.textColor = UIColor.init(netHex: leftActionTextColor)
//		snackBarLeftActionText.font = UIFont.systemFont(ofSize: leftActionTextSize)
//
//		snackBarLeftActionText?.frame = CGRect(x: (snackBarLeftActionText?.frame.origin.x)!, y: (snackBarLeftActionText?.frame.origin.y)!, width: (snackBarLeftActionText?.frame.size.width)!, height: (snackBarLeftActionText?.requiredHeight())!)
//
//
//		let neededLinesForLabel = snackBarLeftActionText.frame.height / textSize.height
//
//		let nf = snackBarLeftActionText?.frame.size
//		let h = snackBarLeftActionText?.requiredHeight()
//
//		var snHeight: CGFloat
//
//		if (androidValues == true) {
//
//			if (neededLinesForLabel < 2) {
//				snHeight = 28 + snackBarLeftActionText.frame.size.height
//			} else {
//				snHeight = 48 + snackBarLeftActionText.frame.size.height
//			}
//		} else {
//			snHeight = snackBarItemsSideSize + snackBarLeftActionText.frame.size.height
//		}
//
//		if (self.minimumHeight > -1 && Double(snHeight) < self.minimumHeight) {
//			snHeight = CGFloat(self.minimumHeight)
//		}
//
//		let positionY = CGFloat(screenSize.height) - CGFloat(snHeight)
//
//		snackBarView?.frame = CGRect(x: (snackBarView?.frame.origin.x)!, y: CGFloat(screenSize.height) + 1, width: (snackBarView?.frame.size.width)!,
//		                                  height: snHeight)
//
//		snackViewHeight = Double(snHeight)
//		snackBarView.addSubview(snackBarLeftActionText!)
//	}
//
//	 func adjustViews() {
//
//		let snackMiddle = snackBarView.frame.height / 2
//
//		//		snackBarView = UIView(frame: CGRect(x: Double(snackBarView.frame.origin.x),
//		//			y: Double(snackBarView.frame.origin.y),
//		//			width: Double(screenSize.width) - (spaceOnSide * 2),
//		//			height: snackViewHeight))
//
//
//		snackBarActionText?.frame = CGRect(x: (snackBarActionText?.frame.origin.x)!, y: (snackMiddle - CGFloat((snackBarActionText?.frame.height)!) / 2), width: (snackBarActionText?.frame.size.width)!, height: (snackBarActionText?.frame.height)!)
//
//		snackBarLeftActionText?.frame = CGRect(x: (snackBarLeftActionText?.frame.origin.x)!, y: (snackMiddle - CGFloat((snackBarLeftActionText?.frame.height)!) / 2), width: (snackBarLeftActionText?.frame.size.width)!, height: (snackBarLeftActionText?.frame.height)!)
//
//	}
//
//	/**
//	Show the SnackBar on view passed on parameter
//	*/
//	open func show(onView: UIView, message: String, completion: @escaping (MJSnackBar.EndShowingType)->()) {
//
//		if (animating == true) {
//			return
//		}
//
//		snackID += 1
//		completionMethod = completion
//		if (shown == true) {
//			hideSnackView() {
//				self.showSnackView(onView: onView, message: message) {
//					completion(EndShowingType.user)
//				}
//			}
//		} else {
//			self.showSnackView(onView: onView, message: message) {
//				completion(EndShowingType.timer)
//			}
//		}
//
//	}
//
//	 func showSnackView(onView: UIView, message: String, completion: @escaping ()->()) {
//		animating = true
//
//		createView()
//		addActionButton()
//		addActionText(message: message)
//		adjustViews()
//
//		onView.addSubview(snackBarView)
//
//		UIView.animate(withDuration: animationTime, animations: { _  in
//
//			self.snackBarView.frame = CGRect(x: self.spaceOnSide,
//				y: Double(self.screenSize.height) - (self.spaceOnBottom + self.snackViewHeight),
//				width: Double(self.screenSize.width) - (self.spaceOnSide * 2),
//				height: self.snackViewHeight)
//
//			}, completion: { _  in
//				self.animating = false
//				self.shown = true
//				DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {
//					let tmp = self.snackID
//					Thread.sleep(forTimeInterval: TimeInterval(self.appearanceDuration))
//					if (tmp != self.snackID) { return }
//					DispatchQueue.main.async(execute: {
//						if (self.shown == true) {
//							self.hideSnackView() {
//								completion()
//							}
//						}
//					})
//				})
//		})
//
//	}
//
//	/*!
//	Dismiss the SnackbarView
//	*/
//	open func dismiss() {
//
//		hideSnackView() {
//			if (self.completionMethod != nil) {
//				self.completionMethod!(EndShowingType.user)
//			}
//		}
//	}
//
//	 func hideSnackView( completion: @escaping () -> ()) {
//		if (shown == false || animating == true) {
//			return
//		}
//		animating = true
//		UIView.animate(withDuration: animationTime, animations: { _ in
//
//			self.snackBarView.frame = CGRect(x: Double(self.snackBarView.frame.origin.x),
//				y: Double(self.screenSize.height) + 1,
//				width: Double(self.snackBarView.frame.width),
//				height: self.snackViewHeight)
//
//			}, completion: { _ in
//
//				self.snackBarLeftActionText.removeFromSuperview()
//				self.snackBarView.removeFromSuperview()
//				//if (self.snackBarActionText != nil) {
//				self.snackBarActionText?.removeFromSuperview()
//				//}
//				self.animating = false
//				self.shown = false
//				completion()
//		})
//	}
//
//	/*!
//	Triggered when the user tap on the view
//	- parameter sender:	view
//	*/
//	@objc func tapOnViewHandler( sender: AnyObject) {
//		dismiss()
//	}
//
//	@objc func rotated() {
//
//		self.hideSnackView {
//			if (self.completionMethod != nil) {
//				self.completionMethod!(EndShowingType.timer)
//			}
//		}
//		self.screenSize = UIScreen.main.bounds
//	}
//
//}
//
//extension UILabel {
//
//	func requiredHeight() -> CGFloat {
//
//		let label: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: CGFloat.greatestFiniteMagnitude))
//		label.numberOfLines = 0
//		label.lineBreakMode = NSLineBreakMode.byWordWrapping
//		label.font = self.font
//		label.text = self.text
//		
//		label.sizeToFit()
//		
//		return label.frame.height
//	}
//}
