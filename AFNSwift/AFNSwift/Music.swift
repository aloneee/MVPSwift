//
//  music.swift
//  AFNSwift
//
//  Created by liurihua on 15/12/23.
//  Copyright © 2015年 刘日华. All rights reserved.
//

struct Music: MusicCellDataSource {
    
    var title: String = ""
    
    var description: String = ""
    
    var artistName:String = ""
    
    var posterPic:String = ""
    
    var url:String = ""
    
}

extension Music: MusicCellDelegate {
    
    var artisFont: UIFont {
        return .systemFontOfSize(20)
    }
    
    var titleColor: UIColor {
        return .redColor()
    }
    
    func touchLabel(title: String?) {
        print(title)
        print(title)
    }
}

extension Music {
    
    static func musicWithDict<T>(dict:[String:T]) -> Music {
        
        return Music(title: dict["title"]       as! String,
               description: dict["description"] as! String,
                artistName: dict["artistName"]  as! String,
                 posterPic: dict["posterPic"]   as! String,
                       url: dict["url"]         as! String)
    }
    
    static func musicsWithDictArray<T>(dictArray:[[String:T]]) ->[Music]? {
        
        if dictArray.count == 0 {
            return nil
        }
        var musics = [Music]()
        
        for dict:[String : T] in dictArray {
            
            if dict["url"] != nil{
                musics += [self.musicWithDict(dict)]
            }
        }
        return musics
    }
    
}



