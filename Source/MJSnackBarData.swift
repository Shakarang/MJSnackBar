//
//  MJSnackBarData.swift
//  MJSnackBar
//
//  Created by Maxime Junger on 22/01/2017.
//  Copyright © 2017 Shakarang. All rights reserved.
//

/// Data to fill the MJSnackBar
public struct MJSnackBarData {
    
    /// Message you want to display to the user
    public var message: String
    
    /// Action message shown next to the message
    public var action: String? = nil
    
    /// Field to help you identify what data it is
    public var id: Int? = nil
    
    /// Object linked to the data displayed. Only there to help you retrieving it easily.
    public var originalObject: Any? = nil
    
    public init(withIdentifier id: Int? = nil,
         message: String,
         andActionMessage action: String? = nil,
         objectSaved originalObject: Any? = nil) {
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
    public static func == (left: MJSnackBarData, right: MJSnackBarData) -> Bool {
        if left.id == right.id
            && left.message == right.message
            && left.action == right.action {
            return true
        }
        return false
    }
}
