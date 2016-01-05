//
//  RequestClient.swift
//  AFNSwift
//
//  Created by liurihua on 15/12/22.
//  Copyright © 2015年 刘日华. All rights reserved.
//


final class RequestClient: AFHTTPSessionManager {
    
    class var sharedInstance :RequestClient {
        struct Static {
            static var onceToken:dispatch_once_t = 0
            static var instance:RequestClient? = nil
        }
        
        dispatch_once(&Static.onceToken, { () -> Void in
            //string填写相应的baseUrl即可
            let url:NSURL = NSURL(string: "")!
            Static.instance = RequestClient(baseURL: url)
        })

        //返回本类的一个实例
        return Static.instance!
        
    }
}

