//
//  MusicCell.swift
//  AFNSwift
//
//  Created by liurihua on 15/12/23.
//  Copyright © 2015年 刘日华. All rights reserved.
//

import UIKit

protocol MusicCellDataSource {
    var title: String? {
        get
    }
    
    var  description: String? {
        get
    }
    
    var artistName: String? {
        get
    }
    
    var posterPic: String? {
        get
    }
    var url: String? {
        get
    }
    
}


extension MusicCellDataSource {
    var title: String {
        return "aaaaa"
    }
    
    var description: String {
        return "aaaaa"
    }
    
    var artistName:String {
        return "aaaaa"
    }
    
    var posterPic:String {
        return "aaaaa"
    }
    
    var url:String {
        return "aaaaa"
    }
    
}

protocol MusicCellDelegate {
    
    var titleColor: UIColor {
        get
    }
    
    var titleFont: UIFont {
        get
    }
    
    var artisColor: UIColor {
        get
    }
    
    var artisFont: UIFont {
        get
    }
    
    func touchLabel(title: String?)
}

extension MusicCellDelegate {
    
    var titleColor: UIColor {
        return .whiteColor()
    }
    
    var titleFont: UIFont {
        return .systemFontOfSize(20)
    }
    
    var artisColor: UIColor {
        return .greenColor()
    }
    
    var artisFont: UIFont {
        return .systemFontOfSize(12)
    }
    
    func touchLable(title:String?) {
        print(title)
    }
    
}

protocol ToViewController {
    
    func returnDataToViewController(data:String?)
}


final class MusicCell: UITableViewCell {

    @IBOutlet weak var iconImgView: UIImageView!
    
    @IBOutlet weak var titleView: UILabel!
    
    @IBOutlet weak var artisView: UILabel!
    
    @IBAction func Click(sender: AnyObject) {
        self.delegate?.touchLabel(self.dataSource?.title)
        self.delegateeeee?.returnDataToViewController(self.dataSource?.title)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    private var dataSource: MusicCellDataSource?
    private var delegate: MusicCellDelegate?
    
    var delegateeeee:ToViewController?
    
    func configCell(withDatasource dataSource: MusicCellDataSource, delegate: MusicCellDelegate? ){
        
        self.dataSource     = dataSource
        self.delegate       = delegate

        let url             = dataSource.posterPic!
        iconImgView.sd_setImageWithURL(NSURL(string: url))

        titleView.text      = dataSource.title
        titleView.textColor = delegate?.titleColor
        titleView.font      = delegate?.titleFont

        artisView.text      = dataSource.artistName
        artisView.textColor = delegate?.artisColor
        artisView.font      = delegate?.artisFont
    }
    
}


