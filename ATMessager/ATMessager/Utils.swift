//
//  Utils.swift
//  ATMessager
//
//  Created by MOBILE MAC1 on 7/21/17.
//  Copyright © 2017 MOBILE MAC1. All rights reserved.
//

import UIKit

public class Utils: NSObject {

    //1] Activity Indicator.
    class func showActivty(vwController:UIViewController){
        
        
        let indicator = InstagramActivityIndicator()
        indicator.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
        indicator.center = vwController.view.center
        indicator.animationDuration = 0.5
        indicator.rotationDuration = 2
        indicator.numSegments = 20
        indicator.strokeColor = UIColor.white
        indicator.lineWidth = 3
        vwController.view.addSubview(indicator)
        indicator.startAnimating()
    }
    
    class func hideActivty(vwController:UIViewController){
    
        let indicator = InstagramActivityIndicator()
        indicator.stopAnimating()
    }
}


