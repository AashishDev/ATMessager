//
//  User.swift
//  ATMessager
//
//  Created by MOBILE MAC1 on 7/20/17.
//  Copyright © 2017 MOBILE MAC1. All rights reserved.
//

import UIKit

class User: NSObject {

    var id = ""
    var name = ""
    var mobile = ""
    var email = ""
    var location = ""
    var userphoto = ""
    var online = ""


    override init () {
        // uncomment this line if your class has been inherited from any other class
        //super.init()
    }
    
    convenience init(dictionary: Dictionary<String, AnyObject>) {
        self.init()
        
        id = dictionary["id"] as! String
        email = dictionary["email"] as! String
        name = dictionary["name"] as! String
        mobile = dictionary["mobile"] as! String
        location = dictionary["location"] as! String
        if let val = dictionary["userPhoto"] {
            self.userphoto = val as! String
        }
        if let val = dictionary["online"] {
            self.online = val as! String
        }
    }
}
