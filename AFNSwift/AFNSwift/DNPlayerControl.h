//
//  DNPlayerControl.h
//  AVPlayer
//
//  Created by liurihua on 15/10/28.
//  Copyright © 2015年 刘日华. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DNPlayerControl;

typedef void (^DNPlayerControlPlayBtnHandle)       (DNPlayerControl *playerControl, BOOL isPlaying);
typedef void (^DNPlayerControlFullscreenBtnHandle) (DNPlayerControl *playerControl, BOOL isFullScreen);
typedef void (^DNPlayerControlProgerssHandle)      (DNPlayerControl *playerControl, CGFloat timeInterval, BOOL isFinished);


@interface DNPlayerControl : UIView

@property (nonatomic, assign, getter = isPlaying)        BOOL             playing;
@property (nonatomic, assign, getter = isFullscreen)     BOOL             fullscreen;
@property (nonatomic, assign)                            NSTimeInterval   currentTime;
@property (nonatomic, assign)                            NSTimeInterval   videoDuration;


-(void)showWithClickHandle:(DNPlayerControlPlayBtnHandle)playBtnHandle
          fullscreenHandle:(DNPlayerControlFullscreenBtnHandle)fullscreenHandle
               progressHandle:(DNPlayerControlProgerssHandle)progressHandle;
@end
