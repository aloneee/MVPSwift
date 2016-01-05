//
//  ViewController.swift
//  AFNSwift
//
//  Created by liurihua on 15/12/22.
//  Copyright © 2015年 刘日华. All rights reserved.
//

import UIKit

final class ViewController: UIViewController{
    
    var table: UITableView?
    var musics = [Music]()
    var offset: Int = 0
    
    struct Identifier {
        static let musicCell = "musicCell"
    }
    
    private struct URL {
        static var musicsURL = "http://mapi.yinyuetai.com/video/list.json?D-A=0&deviceinfo=%7B%22aid%22%3A%2210201024%22%2C%22os%22%3A%22Android%22%2C%22ov%22%3A%224.2.2%22%2C%22rn%22%3A%22480*800%22%2C%22dn%22%3A%22H30-T00%22%2C%22cr%22%3A%2246002%22%2C%22as%22%3A%22WIFI%22%2C%22uid%22%3A%22c5aa133090bd0d5d9ecd4163bb27f3cb%22%2C%22clid%22%3A110013000%7D"
    }

//MARK: ----
//MARK: ---ViewController life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.greenColor()
        self.title = "Itachi San"
        
        table = UITableView(frame: UIScreen.mainScreen().bounds, style: UITableViewStyle.Plain)
        table?.delegate = self
        table?.dataSource = self
        
        table!.registerNib(UINib(nibName: "MusicCell",bundle: nil), forCellReuseIdentifier: Identifier.musicCell)
        
        //fetch musics Block
        let fetchMusics = {() -> Void in
            
            RequestAPI.GET.fetch(URL.musicsURL, body: ["offset" : 0], succeed: { [unowned self] (task: NSURLSessionDataTask?, responseObject: AnyObject?) -> Void in
                
                    if let response = responseObject as? [String: AnyObject] {
                        if let musicsArray = response["videos"] as? [[String : AnyObject]]{
                            self.musics.removeAll()
                            if let tempMusics = Music.musicsWithDictArray(musicsArray) {
                                self.musics += tempMusics
                            }
                            self.table?.reloadData()
                            self.table?.mj_header.endRefreshing()
                        }
                    }
                }) { (task: NSURLSessionDataTask?, error: NSError) -> Void in
                    
                    print("oh shit 失败了 + \(error)")
            }
        }
        
        table!.mj_header = MJRefreshHeader(refreshingBlock: fetchMusics)
        
        self.view.addSubview(table!)
       
        fetchMusics()
    }
}

//MARK: ----
//MARK: ----UITableViewDataSource
extension ViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return musics.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(Identifier.musicCell, forIndexPath: indexPath) as! MusicCell
        cell.configCell(withDatasource: musics[indexPath.row], delegate: musics[indexPath.row])
        cell.delegateeeee = self
        return cell
    }
    
}

//MARK: ----
//MARK: ----UITableViewDelegate
extension ViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let playerViewController = PlayerViewController()
        playerViewController.music = musics[indexPath.row]
        self.navigationController?.pushViewController(playerViewController, animated: true)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 200.0
    }
}


//MARK: ----
//MARK: ----MusicCellDelegate

extension ViewController: ToViewController {
    func returnDataToViewController(data: String?) {
        
        let alert = UIAlertController(title: data, message: data, preferredStyle: .Alert)
        
        alert.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: { (action) -> Void in
//            alert.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
}



