//
//  NetworkConfig.swift
//  ATMessager
//
//  Created by MOBILE MAC1 on 8/3/17.
//  Copyright © 2017 MOBILE MAC1. All rights reserved.
//

import UIKit

//1] Request Url Constant
let baseWebServiceUrl = "https://newsapi.org/v1/"
let newsApi = "articles?source=bbc-news&sortBy=top&apiKey=f57b72cb33e8488183df9f5e9662c287"

class NetworkConfig: NSObject {

    struct Baseurl {
        
        var baseServerUrl:String = baseWebServiceUrl
    }
    
    struct newsApiUrl {
        
    }
}
