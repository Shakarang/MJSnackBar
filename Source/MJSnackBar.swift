//
//  MJSnackBar.swift
//  MJSnackBarExample
//
//  Created by Maxime Junger on 01/04/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit


protocol MJSnackBarDelegate {
    func snackBarAppeared(with data: MJSnackBarData)
    func snackBarDisappeared(with data: MJSnackBarData, reason: MJSnackBar.EndShowingType)
    func snackBarActionTriggered(with data: MJSnackBarData)
}

struct MJSnackBarData {
    
    var id: Int? = nil
    var message: String
    var action: String? = nil
    var originalObject: Any? = nil
    
    init(id: Int? = nil,
         message: String,
         action: String? = nil,
         originalObject: Any? = nil) {
        self.id = id
        self.message = message
        self.action = action
        self.originalObject = originalObject
    }
    
    static func ==(left: MJSnackBarData, right: MJSnackBarData) -> Bool {
        if left.id == right.id
            && left.message == right.message
            && left.action == right.action {
            return true
        }
        return false
    }
}

class MJSnackBar: UIView {
    
    
    
    var dataToDisplay = [MJSnackBarData]()
    
    /// Enum to know why SnackBar disappeared : due to Timer or User action
    ///
    /// - timer: The timer ended, normal behaviour
    /// - user: The user pressed the undo button. You have to handle it
    public enum EndShowingType {
        case timer, over, user
    }
    
    /// Delegate to let user create its own actions
    public var delegate: MJSnackBarDelegate? = nil
    
    /// Animation duration
    public var animationDuration: Double = 0.4
    
    /// How long the SnackBar will be shown
    public var timeSnackBarShown: Double = 2.0
    
    /// SnackBar height
    public var snackBarDefaultHeight: CGFloat = 48.0
    
    /// Allow the SnackBar height to automatically adjust
    /// its height based on the content
    public var allowHeightChange: Bool = true
    
    /// SnackBar margins
    public var spaceBetweenElements: CGFloat = 24.0
    
    /// SnackBar side margins to view
    public var sideMargins: CGFloat = 0.0
    
    /// SnackBar bottom margin to view
    public var bottomMargin: CGFloat = 0.0
    
    /// SnackBar internal content margin
    public var elementsTopBottomMargins: CGFloat = 14.0
    
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
    
    private var currentlyDisplayedData: MJSnackBarData? = nil
    
    
    /// Font of displayed message
    public var messageFont: UIFont? = nil
    
    /// Font of action button
    public var actionFont: UIFont? = UIFont.boldSystemFont(ofSize: UIFont.labelFontSize)
    
    /// Message text color
    public var messageColor: UIColor = .white
    
    /// Action text color
    public var actionColorColor: UIColor = .red
    
    
    public init(onView: UIView) {
        
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        
        self.backgroundColor = UIColor(red:0.11, green:0.11, blue:0.11, alpha:0.8)
        self.showingOnView = onView
        
        self.isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.snackBarTouched))
        tapGesture.numberOfTapsRequired = 1
        
        self.addGestureRecognizer(tapGesture)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /// Show snackbar on specific view with the given data.
    ///
    /// - Parameters:
    ///   - data: data to show
    ///   - view: where to show the snackbar
    public func show(data: MJSnackBarData, onView view: UIView) {
        
        print("---------------------Show called-----------------------")
        
        if self.isCurrentlyShown {
            print("Une vue existe \(data.message)")
            //self.hide(afterDelay: false, reason: .over) {
                self.animate(show: false, reasonToHide: .over) {
                 
                self.currentlyDisplayedData = data
                DispatchQueue.main.async {
                    
                    self.snackBarID += 1
                    self.createSnackBar()
                    
                    self.animate(show: true) { }
                }
            }
        } else {
            print("Il ny en a pas \(data.message)")
            self.currentlyDisplayedData = data
            self.snackBarID += 1
            DispatchQueue.main.async {
                
                self.createSnackBar()
                
                self.animate(show: true) { }
            }
        }
    }
    
    /// Create SnackBar with all data needed and add it to the view.
    private func createSnackBar() {
        
        guard let view = self.showingOnView else {
            return
        }
        
        for view in view.subviews {
            if view is MJSnackBar {
                self.addInformationToSnackBar()
                return
            }
        }
        
        self.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(self)
        
        self.addInformationToSnackBar()
        
        let leftConstraint = NSLayoutConstraint(item: self,
                                                attribute: NSLayoutAttribute.leading,
                                                relatedBy: NSLayoutRelation.equal,
                                                toItem: view,
                                                attribute: NSLayoutAttribute.leading,
                                                multiplier: 1, constant: self.sideMargins)
        
        let rightConstraint = NSLayoutConstraint(item: self,
                                                 attribute: NSLayoutAttribute.trailing,
                                                 relatedBy: NSLayoutRelation.equal,
                                                 toItem: view,
                                                 attribute: NSLayoutAttribute.trailing,
                                                 multiplier: 1, constant: -self.sideMargins)
        
        
        let heightConstraint = NSLayoutConstraint(item: self,
                                                  attribute: NSLayoutAttribute.height,
                                                  relatedBy: self.allowHeightChange ? .greaterThanOrEqual : .equal,
                                                  toItem: nil,
                                                  attribute: NSLayoutAttribute.notAnAttribute,
                                                  multiplier: 1, constant: self.snackBarDefaultHeight)
        
        NSLayoutConstraint.activate([leftConstraint, rightConstraint, heightConstraint])
        
        view.layoutIfNeeded()
        
        self.bottomConstraint = NSLayoutConstraint(item: self,
                                                   attribute: NSLayoutAttribute.bottom,
                                                   relatedBy: NSLayoutRelation.equal,
                                                   toItem: view,
                                                   attribute: NSLayoutAttribute.bottom,
                                                   multiplier: 1, constant: self.frame.height)
        self.bottomConstraint.identifier = self.constraintIdentifier
        NSLayoutConstraint.activate([self.bottomConstraint])
        
    }
    
    
    /// Animate the SnackBar.
    ///
    /// - Parameters:
    ///   - show: should show or hide the bar
    ///   - reasonToHide: why the bar will be hidden? timer, over, user..
    ///   - completion: Function completion to tell when the animation finished
    private func animate(show: Bool, reasonToHide: EndShowingType = .timer, completion: @escaping () -> Void) {
        
        guard let view = self.showingOnView else {
            return
        }
        
        DispatchQueue.main.async {
            
            view.layoutIfNeeded()
            
            self.layoutIfNeeded()
            // Should show the snack bar
            if show {
                
                
                self.bottomConstraint?.constant = 0 - self.bottomMargin
                print("----- show ------\(self.bottomConstraint?.constant)")
                UIView.animate(withDuration: self.animationDuration, animations: {
                    view.layoutIfNeeded()
                }, completion: { _ in
                    self.isCurrentlyShown = true
                    if let data = self.currentlyDisplayedData {
                        self.delegate?.snackBarAppeared(with: data)
                    } else {
                        print("❌ WTF there is no data \(self.snackBarID)")
                    }
                    self.hide(afterDelay: true, reason: .timer) { }
                    completion()
                })
            } else {
                
                
                self.bottomConstraint?.constant = self.frame.height
                print("----- hide ------\(self.bottomConstraint?.constant)")
                UIView.animate(withDuration: self.animationDuration, animations: {
                    view.layoutIfNeeded()
                }, completion: { ok in
                    
                    
                    //self.cleanSnackBar()
                    
                    // Need to remove constraint after hiding
                    //                        for constraint in view.constraints {
                    //                            if constraint.identifier == self.constraintIdentifier {
                    //                                view.removeConstraint(constraint)
                    //                            }
                    //                        }
                    
                    

                    if let data = self.currentlyDisplayedData, self.isCurrentlyShown == true {
                        self.delegate?.snackBarDisappeared(with: data, reason: reasonToHide)
                        print("Removving data : \(self.currentlyDisplayedData)")
                        self.currentlyDisplayedData = nil
                    }
                    
                    self.isCurrentlyShown = false
                    completion()
                })
            }
        }
        
    }
    
    
    /// Hide the snack bar and check if it is the correct view displayed.
    ///
    /// - Parameters:
    ///   - afterDelay: Delay to wait before hiding
    ///   - reason: Why hiding
    private func hide(afterDelay: Bool, reason: EndShowingType, completion: @escaping () -> Void) {
        
        let tmpID = self.snackBarID
        let tmp = self.currentlyDisplayedData

        DispatchQueue.global().async {
            
            if afterDelay {
                Thread.sleep(forTimeInterval: self.timeSnackBarShown)
            }
        
            if tmpID == self.snackBarID && self.currentlyDisplayedData != nil && tmp != nil && tmp! == self.currentlyDisplayedData! {
                print("Je suis passé")
                self.animate(show: false, reasonToHide: reason) {
                    print("Je vais complete")
                    completion()
                }
                
            } else {
                print("Pas passé")
                completion()
            }
        }
        
        
    }
    
    func addInformationToSnackBar() {
        let actionLabel = addActionLabelToSnackBar()
        addMessageLabelToSnackBar(actionLabel: actionLabel)
    }
    
    func addMessageLabelToSnackBar(actionLabel: UILabel? = nil) {
        
        for view in self.subviews {
            if view.accessibilityIdentifier == "messageLabelSnackBar" {
                if let messageLabel = view as? UILabel {
                    messageLabel.textColor = self.messageColor
                    messageLabel.text = self.currentlyDisplayedData?.message
                    messageLabel.font = self.messageFont ?? messageLabel.font
                    self.layoutIfNeeded()
                    return
                }
            }
        }
        
        let messageLabel = UILabel()
        
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.accessibilityIdentifier = "messageLabelSnackBar"
        messageLabel.numberOfLines = 0
        messageLabel.textColor = self.messageColor
        messageLabel.text = self.currentlyDisplayedData?.message
        messageLabel.font = self.messageFont ?? messageLabel.font
        
        self.layoutIfNeeded()
        
        self.addSubview(messageLabel)
        
        // Add constraints
        let leftConstraint = NSLayoutConstraint(item: messageLabel,
                                                attribute: NSLayoutAttribute.leading,
                                                relatedBy: NSLayoutRelation.equal,
                                                toItem: self,
                                                attribute: NSLayoutAttribute.leading,
                                                multiplier: 1,
                                                constant: self.spaceBetweenElements)
        
        let rightConstraint = NSLayoutConstraint(item: messageLabel,
                                                 attribute: NSLayoutAttribute.trailing,
                                                 relatedBy: NSLayoutRelation.equal,
                                                 toItem: actionLabel ?? self,
                                                 attribute: actionLabel != nil ? .leading : .trailing,
                                                 multiplier: 1,
                                                 constant: -self.spaceBetweenElements)
        
        let topConstraint = NSLayoutConstraint(item: messageLabel,
                                               attribute: NSLayoutAttribute.top,
                                               relatedBy: NSLayoutRelation.equal,
                                               toItem: self,
                                               attribute: NSLayoutAttribute.top,
                                               multiplier: 1,
                                               constant: self.elementsTopBottomMargins)
        
        let bottomConstraint = NSLayoutConstraint(item: messageLabel,
                                                  attribute: NSLayoutAttribute.bottom,
                                                  relatedBy: NSLayoutRelation.equal,
                                                  toItem: self,
                                                  attribute: NSLayoutAttribute.bottom,
                                                  multiplier: 1,
                                                  constant: -self.elementsTopBottomMargins)
        
        NSLayoutConstraint.activate([leftConstraint, rightConstraint, bottomConstraint, topConstraint])
    }
    
    func addActionLabelToSnackBar() -> UILabel? {
        
        guard let actionString = self.currentlyDisplayedData?.action else {
            return nil
        }
        
        
        for view in self.subviews {
            if view.accessibilityIdentifier == "actionLabelSnackBar" {
                if let actionLabel = view as? UILabel {
                    actionLabel.textColor = self.actionColorColor
                    actionLabel.text = actionString
                    actionLabel.font = self.actionFont ?? actionLabel.font
                }
            }
        }
        
        let actionLabel = UILabel()
        
        actionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        actionLabel.accessibilityIdentifier = "actionLabelSnackBar"
        actionLabel.numberOfLines = 0
        actionLabel.textColor = self.actionColorColor
        actionLabel.text = actionString
        actionLabel.font = self.actionFont ?? actionLabel.font
        
        self.addSubview(actionLabel)
        
        // Add constraints
        let rightConstraint = NSLayoutConstraint(item: actionLabel,
                                                 attribute: NSLayoutAttribute.trailing,
                                                 relatedBy: NSLayoutRelation.equal,
                                                 toItem: self,
                                                 attribute: NSLayoutAttribute.trailing,
                                                 multiplier: 1, constant: -self.spaceBetweenElements)
        
        let topConstraint = NSLayoutConstraint(item: actionLabel,
                                               attribute: NSLayoutAttribute.top,
                                               relatedBy: NSLayoutRelation.equal,
                                               toItem: self,
                                               attribute: NSLayoutAttribute.top,
                                               multiplier: 1, constant: self.elementsTopBottomMargins)
        
        let bottomConstraint = NSLayoutConstraint(item: actionLabel,
                                                  attribute: NSLayoutAttribute.bottom,
                                                  relatedBy: NSLayoutRelation.equal,
                                                  toItem: self,
                                                  attribute: NSLayoutAttribute.bottom,
                                                  multiplier: 1, constant: -self.elementsTopBottomMargins)
        
        NSLayoutConstraint.activate([rightConstraint, bottomConstraint, topConstraint])
        
        return actionLabel
    }
    
    func cleanSnackBar() {
        
        //        for view in self.subviews {
        //            view.removeFromSuperview()
        //        }
        //        self.removeFromSuperview()
        print("J'ai tout clean voilàààà")
    }
    
    func snackBarTouched() {
        
        self.hide(afterDelay: false, reason: .user) { }
        
        if let data = self.currentlyDisplayedData {
            self.delegate?.snackBarActionTriggered(with: data)
        }
    }
    
}

//Il ny en a pas Deleted : 1
//----- show ------
//Snackbar appeared Deleted : 1
//C'est cet IDDDD 1 avec 1
//----- hide ------
