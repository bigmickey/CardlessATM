//
//  Session.swift
//  CardlessATM
//
//  Created by Michael on 20/11/2015.
//  Copyright © 2015 Michael. All rights reserved.
//

import Foundation

private let _sharedSessionInstance = SessionObject()

class SessionObject {
    
    // global values
    var loginUser:String? = nil
    
    private init() {
    }
    
    class var sharedInstance: SessionObject {
        return _sharedSessionInstance
    }
}