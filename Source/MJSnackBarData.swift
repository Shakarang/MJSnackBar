//
//  MJSnackBarData.swift
//  MJSnackBar
//
//  Created by Maxime Junger on 22/01/2017.
//  Copyright © 2017 Shakarang. All rights reserved.
//

/// Data to fill the MJSnackBar
struct MJSnackBarData {
    
    /// Message you want to display to the user
    var message: String
    
    /// Action message shown next to the message
    var action: String? = nil
    
    /// Field to help you identify what data it is
    var id: Int? = nil
    
    /// Object linked to the data displayed. Only there to help you retrieving it easily.
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
    
    /// Checking if two data are the same
    ///
    /// - Parameters:
    ///   - left: left object
    ///   - right: right object
    /// - Returns: true if they have the same content
    static func == (left: MJSnackBarData, right: MJSnackBarData) -> Bool {
        if left.id == right.id
            && left.message == right.message
            && left.action == right.action {
            return true
        }
        return false
    }
}
