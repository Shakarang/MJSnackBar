//
//  MJSnackBarDelegate.swift
//  MJSnackBar
//
//  Created by Maxime Junger on 22/01/2017.
//  Copyright © 2017 Shakarang. All rights reserved.
//

protocol MJSnackBarDelegate {
    func snackBarAppeared(with data: MJSnackBarData)
    func snackBarDisappeared(with data: MJSnackBarData, reason: MJSnackBar.EndShowingType)
    func snackBarActionTriggered(with data: MJSnackBarData)
}
