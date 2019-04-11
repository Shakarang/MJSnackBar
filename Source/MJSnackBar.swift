//
//  MJSnackBar.swift
//  MJSnackBarExample
//
//  Created by Maxime Junger on 01/04/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import UIKit

open class MJSnackBar: UIView {
    
    /// Enum to know why SnackBar disappeared : due to Timer or User action
    ///
    /// - timer: The timer ended, normal behaviour
    /// - user: The user pressed the undo button. You have to handle it
    public enum EndShowingType {
        case timer, overridden, user
    }
    
    /// Delegate to let user create its own actions
    public weak var delegate: MJSnackBarDelegate? = nil
    
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
    
    /// Font of displayed message
    public var messageFont: UIFont? = nil
    
    /// Font of action button
    public var actionFont: UIFont? = UIFont.boldSystemFont(ofSize: UIFont.labelFontSize)
    
    /// Message text color
    public var messageColor: UIColor = .white
    
    /// Action text color
    public var actionColorColor: UIColor = .red
    
    /// Current view the bar is shown on
    fileprivate var showingOnView: UIView? = nil
    
    /// SnackBar bottom constraint
    fileprivate var bottomConstraint: NSLayoutConstraint!
    
    /// Constraint identifier. Used to track it
    fileprivate var constraintIdentifier = "snackBarConstraintBottom"
    
    /// Used to know if there is a SnackBar displaying
    fileprivate var isCurrentlyShown = false
    
    /// Used to know the number of SnackBar displayed.
    /// Also used for removing the view.
    fileprivate var snackBarID = 0
    
    /// Data displayed
    fileprivate var currentlyDisplayedData: MJSnackBarData? = nil

    public init(onView: UIView) {
        
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))

        self.backgroundColor = UIColor(red:0.11, green:0.11, blue:0.11, alpha:0.95)
        self.showingOnView = onView
        
        // Allow user to interract with the bar
        self.isUserInteractionEnabled = true
        
        // Add gesture for action
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.snackBarTouched))
        tapGesture.numberOfTapsRequired = 1
        self.addGestureRecognizer(tapGesture)
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
        // Removing all views from the stack
        for view in self.subviews {
            view.removeFromSuperview()
        }
        self.removeFromSuperview()
    }
    
    /// Show snackbar on specific view with the given data.
    ///
    /// - Parameters:
    ///   - data: data to show
    ///   - view: where to show the snackbar
    public func show(data: MJSnackBarData, onView view: UIView) {
        if self.isCurrentlyShown {
                self.animate(show: false, reasonToHide: .overridden) {
                self.currentlyDisplayedData = data
                DispatchQueue.main.async {
                    self.snackBarID += 1
                    self.createSnackBar()
                    self.animate(show: true) { }
                }
            }
        } else {
            self.currentlyDisplayedData = data
            self.snackBarID += 1
            DispatchQueue.main.async {
                self.createSnackBar()
                self.animate(show: true) { }
            }
        }
    }
    
    /// Triggered when the user touches the SnackBar
    /// Calls snackBarActionTriggered of the delegate if there is one
    @objc fileprivate func snackBarTouched() {
        
        if let data = self.currentlyDisplayedData {
            if data.action != nil && data.action!.count > 0 {
                self.hide(afterDelay: false, reason: .user) { }
                self.delegate?.snackBarActionTriggered(with: data)
            }
        }

    }
}

// MARK: - SnackBar information management
extension MJSnackBar {
    
    /// Create SnackBar with all data needed and add it to the view.
    fileprivate func createSnackBar() {
        
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
                                                attribute: NSLayoutConstraint.Attribute.leading,
                                                relatedBy: NSLayoutConstraint.Relation.equal,
                                                toItem: view, attribute: NSLayoutConstraint.Attribute.leading,
                                                multiplier: 1, constant: self.sideMargins)
        
        let rightConstraint = NSLayoutConstraint(item: self,
                                                 attribute: NSLayoutConstraint.Attribute.trailing,
                                                 relatedBy: NSLayoutConstraint.Relation.equal,
                                                 toItem: view, attribute: NSLayoutConstraint.Attribute.trailing,
                                                 multiplier: 1, constant: -self.sideMargins)
        
        let heightConstraint = NSLayoutConstraint(item: self,
                                                  attribute: NSLayoutConstraint.Attribute.height,
                                                  relatedBy: self.allowHeightChange ? .greaterThanOrEqual : .equal,
                                                  toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute,
                                                  multiplier: 1, constant: self.snackBarDefaultHeight)
        
        NSLayoutConstraint.activate([leftConstraint, rightConstraint, heightConstraint])
        
        view.layoutIfNeeded()
        
        self.bottomConstraint = NSLayoutConstraint(item: self,
                                                   attribute: NSLayoutConstraint.Attribute.bottom,
                                                   relatedBy: NSLayoutConstraint.Relation.equal,
                                                   toItem: view, attribute: NSLayoutConstraint.Attribute.bottom,
                                                   multiplier: 1, constant: self.frame.height)
        self.bottomConstraint.identifier = self.constraintIdentifier
        NSLayoutConstraint.activate([self.bottomConstraint])

    }
    
    /// Add all information to the SnackBar
    fileprivate func addInformationToSnackBar() {
        
        let actionLabel = addActionLabelToSnackBar()
        
        addMessageLabelToSnackBar(actionLabel: actionLabel)
        
    }
    
    /// Add the action message on the left of the view
    /// If an actionLabel is passed, creates constraint between the two.
    /// Otherwise, creates constraint to trailing view
    /// - Parameter actionLabel: Action message to create a constraint with
    fileprivate func addMessageLabelToSnackBar(actionLabel: UILabel? = nil) {
        
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
                                                attribute: NSLayoutConstraint.Attribute.leading,
                                                relatedBy: NSLayoutConstraint.Relation.equal,
                                                toItem: self, attribute: NSLayoutConstraint.Attribute.leading,
                                                multiplier: 1, constant: self.spaceBetweenElements)
        
        let rightConstraint = NSLayoutConstraint(item: messageLabel,
                                                 attribute: NSLayoutConstraint.Attribute.trailing,
                                                 relatedBy: NSLayoutConstraint.Relation.equal, toItem: actionLabel ?? self,
                                                 attribute: actionLabel != nil ? .leading : .trailing,
                                                 multiplier: 1, constant: -self.spaceBetweenElements)
        
        let topConstraint = NSLayoutConstraint(item: messageLabel,
                                               attribute: NSLayoutConstraint.Attribute.top,
                                               relatedBy: NSLayoutConstraint.Relation.equal, toItem: self,
                                               attribute: NSLayoutConstraint.Attribute.top,
                                               multiplier: 1, constant: self.elementsTopBottomMargins)
        
        let bottomConstraint = NSLayoutConstraint(item: messageLabel,
                                                  attribute: NSLayoutConstraint.Attribute.bottom,
                                                  relatedBy: NSLayoutConstraint.Relation.equal, toItem: self,
                                                  attribute: NSLayoutConstraint.Attribute.bottom,
                                                  multiplier: 1, constant: -self.elementsTopBottomMargins)
        
        NSLayoutConstraint.activate([leftConstraint, rightConstraint, bottomConstraint, topConstraint])
    }
    
    /// Add the action message on the right of the view
    ///
    /// - Returns: action label if created. Used to create constraints between action and message
    fileprivate func addActionLabelToSnackBar() -> UILabel? {
        
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
                                                 attribute: NSLayoutConstraint.Attribute.trailing,
                                                 relatedBy: NSLayoutConstraint.Relation.equal,
                                                 toItem: self,
                                                 attribute: NSLayoutConstraint.Attribute.trailing,
                                                 multiplier: 1, constant: -self.spaceBetweenElements)
        
        let topConstraint = NSLayoutConstraint(item: actionLabel,
                                               attribute: NSLayoutConstraint.Attribute.top,
                                               relatedBy: NSLayoutConstraint.Relation.equal,
                                               toItem: self,
                                               attribute: NSLayoutConstraint.Attribute.top,
                                               multiplier: 1, constant: self.elementsTopBottomMargins)
        
        let bottomConstraint = NSLayoutConstraint(item: actionLabel,
                                                  attribute: NSLayoutConstraint.Attribute.bottom,
                                                  relatedBy: NSLayoutConstraint.Relation.equal,
                                                  toItem: self,
                                                  attribute: NSLayoutConstraint.Attribute.bottom,
                                                  multiplier: 1, constant: -self.elementsTopBottomMargins)
        
        NSLayoutConstraint.activate([rightConstraint, bottomConstraint, topConstraint])
        
        return actionLabel
    }
}

// MARK: - SnackBar animations
extension MJSnackBar {
    
    /// Animate the SnackBar.
    ///
    /// - Parameters:
    ///   - show: should show or hide the bar
    ///   - reasonToHide: why the bar will be hidden? timer, over, user..
    ///   - completion: Function completion to tell when the animation finished
    fileprivate func animate(show: Bool, reasonToHide: EndShowingType = .timer, completion: @escaping () -> Void) {
        
        guard let view = self.showingOnView else {
            return
        }
        
        DispatchQueue.main.async {
            view.layoutIfNeeded()
            self.layoutIfNeeded()
            // Should show the snack bar
            if show {
                self.bottomConstraint?.constant = 0 - self.bottomMargin
                UIView.animate(withDuration: self.animationDuration, animations: {
                    view.layoutIfNeeded()
                }, completion: { _ in
                    self.isCurrentlyShown = true
                    if let data = self.currentlyDisplayedData {
                        self.delegate?.snackBarAppeared(with: data)
                    }
                    self.hide(afterDelay: true, reason: .timer) { }
                    completion()
                })
            } else {
                self.bottomConstraint?.constant = self.frame.height
                UIView.animate(withDuration: self.animationDuration, animations: {
                    view.layoutIfNeeded()
                }, completion: { _ in
                    if let data = self.currentlyDisplayedData, self.isCurrentlyShown == true {
                        self.delegate?.snackBarDisappeared(with: data, reason: reasonToHide)
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
    fileprivate func hide(afterDelay: Bool, reason: EndShowingType, completion: @escaping () -> Void) {
        
        let tmpID = self.snackBarID
        let tmp = self.currentlyDisplayedData
        
        DispatchQueue.global().async {
            if afterDelay {
                Thread.sleep(forTimeInterval: self.timeSnackBarShown)
            }
            if tmpID == self.snackBarID && self.currentlyDisplayedData != nil && tmp != nil && tmp! == self.currentlyDisplayedData! {
                self.animate(show: false, reasonToHide: reason) {
                    completion()
                }
            } else {
                completion()
            }
        }
    }
}
