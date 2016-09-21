//
//  HttpRequsetHelper.swift
//  DouBanFM
//
//  Created by JiaYuanFa on 16/8/5.
//  Copyright © 2016年 Jafar MacPro. All rights reserved.
//

import UIKit

protocol HttpProtocol {
    func didReceiveResults(results:NSDictionary)
}

class HttpRequsetHelper: NSObject {

    var delegate:HttpProtocol?
    
    func onResearch(url:String){
            let nsUrl:NSURL = NSURL(string: url)!
            let urlRequest:NSURLRequest = NSURLRequest(URL: nsUrl)
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithRequest(urlRequest) { (data, urlResponse, error) in
                print("data is \(data)")
                dispatch_async(dispatch_get_main_queue(), {
                do{
                    if (data != nil){
                        let resultDict = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                        self.delegate?.didReceiveResults(resultDict)
                    }
                }
                catch let error as NSError{
                    print("error is \(error)")
                }
                })
            }
        
            task.resume()
    }
    
}
