//
//  PlayerViewController.swift
//  AFNSwift
//
//  Created by liurihua on 15/12/24.
//  Copyright © 2015年 刘日华. All rights reserved.
//

import UIKit

final class PlayerViewController: UIViewController {

    var music: Music?
    //MARK: -- ViewController life  cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.purpleColor()
        self.title = self.music?.title
       
        NSNotificationCenter.defaultCenter().rac_addObserverForName(CHANGE_TO_HORIZONTAL, object: nil).subscribeNext {[weak self] (_:AnyObject?) -> Void in
            if let sssself = self {
                sssself.navigationController?.navigationBarHidden = true
            }
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName(CHANGE_TO_VERTICAL, object: nil, queue: NSOperationQueue.mainQueue()) {[weak self](note: NSNotification) -> Void in
            if let selfffff = self {
                selfffff.navigationController?.navigationBarHidden = false
            }
        }
        
        let player = PlayerView(frame: CGRect(x: 10, y: 200, width: UIScreen.mainScreen().bounds.width - 20, height: 200))
        player.videoURL = self.music?.url
        self.view.addSubview(player)
    }
 
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}


