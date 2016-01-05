
//
//  RequestAPI.swift
//  AFNSwift
//
//  Created by liurihua on 15/12/22.
//  Copyright © 2015年 刘日华. All rights reserved.
//

typealias Succeed = (NSURLSessionDataTask?,AnyObject?)->Void
typealias Failure = (NSURLSessionDataTask?,NSError)->Void

protocol FetchDataProtocol {
    
    func fetch(url:String!,body:AnyObject?,succeed:Succeed,failed:Failure)
}

protocol RequestParameters {
    
    var token: String {
        get
    }
    
    var size: Int {
        get
    }
    
}

extension RequestParameters {
    
    var token: String {
        return "ItachiSan"
    }
    
    var size: Int {
        return 100
    }
}


enum RequestAPI: FetchDataProtocol, RequestParameters {
    
    case GET, POST
    
    //普通get网络请求
    func fetch(url:String!,body:AnyObject?,succeed:Succeed,failed:Failure) {

        var paras = body as! [String:AnyObject]
        paras["token"] = self.token
        paras["size"] = self.size
        
        switch self {
        case .GET: {
                RequestClient.sharedInstance.GET(url, parameters:paras, progress: { (progress: NSProgress?) -> Void in
                    }, success: { (task:NSURLSessionDataTask?, responseObject: AnyObject?) -> Void in
                        succeed(task,responseObject)
                    }) { (task: NSURLSessionDataTask?, error: NSError) -> Void in
                        failed(task, error)
                }
            }()
        case .POST: {
                RequestClient.sharedInstance.POST(url, parameters: body, progress: { (progress: NSProgress?) -> Void in
                    }, success: { (task:NSURLSessionDataTask?, responseObject: AnyObject?) -> Void in
                        succeed(task,responseObject)
                    }) { (task: NSURLSessionDataTask?, error: NSError) -> Void in
                        failed(task, error)
                }
            }()
        }
    }
}   