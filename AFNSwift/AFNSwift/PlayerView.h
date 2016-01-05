//
//  PlayerView.h
//  AVPlayer
//
//  Created by liurihua on 15/10/28.
//  Copyright © 2015年 刘日华. All rights reserved.
//

#import <UIKit/UIKit.h>

#define CHANGE_TO_HORIZONTAL  @"change_To_Horizontal"
#define CHANGE_TO_VERTICAL    @"change_To_Vertical"

@interface PlayerView : UIView

@property (nonatomic,copy) NSString *videoURL;

@end
