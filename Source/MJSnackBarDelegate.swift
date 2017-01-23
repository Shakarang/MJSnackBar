//
//  MJSnackBarDelegate.swift
//  MJSnackBar
//
//  Created by Maxime Junger on 22/01/2017.
//  Copyright © 2017 Shakarang. All rights reserved.
//

public protocol MJSnackBarDelegate: class {
    
    /// Action triggered when the SnackBar is shown on the view.
    ///
    /// - Parameter data: data contained in the SnackBar
    func snackBarAppeared(with data: MJSnackBarData)
    
    /// Action triggered when the SnackBar is removed from the view.
    ///
    /// - Parameters:
    ///   - data: data contained in the SnackBar
    ///   - reason: why the SnackBar disappeared
    func snackBarDisappeared(with data: MJSnackBarData, reason: MJSnackBar.EndShowingType)
    
    /// Action triggered when the user tapped on the SnackBar
    ///
    /// - Parameter data: data contained in the SnackBar
    func snackBarActionTriggered(with data: MJSnackBarData)
}
