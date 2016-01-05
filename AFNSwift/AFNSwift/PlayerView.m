//
//  PlayerView.m
//  AVPlayer
//
//  Created by liurihua on 15/10/28.
//  Copyright © 2015年 刘日华. All rights reserved.
//

#import "PlayerView.h"
#import <AVFoundation/AVFoundation.h>
#import "DNPlayerControl.h"


@interface PlayerView ()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) AVPlayerLayer   *playerLayer;
@property (nonatomic, strong) AVPlayer        *player;
@property (nonatomic, strong) AVPlayerItem    *item;
@property (nonatomic, weak)   DNPlayerControl *control;
@property (nonatomic, strong) id              timeObserver;
@property (nonatomic, assign) CGRect          originFrame;

@end

static const NSTimeInterval kAnimationDuration = 0.25;

@implementation PlayerView

#pragma mark --- override
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
        [self setupUI];
    }
    return self;
}

-(void)layoutSubviews{
    
    [super layoutSubviews];
    
    CGSize selfSize = self.frame.size;
    
    self.playerLayer.frame = self.bounds;

    self.control.frame = CGRectMake(0, selfSize.height * 0.8, selfSize.width, selfSize.height * 0.2);
}

-(void)dealloc
{
    [self.player removeTimeObserver:_timeObserver];
    [self.item removeObserver:self forKeyPath:@"status"];
    [_player cancelPendingPrerolls];
}

#pragma mark ---- setter

-(void)setVideoURL:(NSString *)videoURL{
    
    _videoURL = videoURL;
    
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:[NSURL URLWithString:videoURL]
                                            options:nil];
    NSArray *requestedKeys = @[@"playable"];
    
    [asset loadValuesAsynchronouslyForKeys:requestedKeys
                         completionHandler:^{
                             
                             dispatch_async(dispatch_get_main_queue(),^{
                                 for (NSString *thisKey in requestedKeys)
                                 {
                                     NSError *error = nil;
                                     AVKeyValueStatus keyStatus = [asset statusOfValueForKey:thisKey
                                                                                       error:&error];
                                     if (keyStatus == AVKeyValueStatusFailed)
                                     {
                                         [self assetFailedToPrepareForPlayback:error.localizedDescription];
                                         return;
                                     }
                                 }
                                 
                                 if (!asset.playable)
                                 {
                                     [self assetFailedToPrepareForPlayback:@"播放失败"];
                                     
                                     return;
                                 }
                                 
                                 if (self.item) {
                                     [self.item removeObserver:self forKeyPath:@"status"];
                                 }
                                 
                                 self.item = [AVPlayerItem playerItemWithAsset:asset];
                                 
                                 [self.item addObserver:self
                                             forKeyPath:@"status"
                                                options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                                                context:nil];
                                 
                                 if (self.player.currentItem != self.item) {
                                     [self.player replaceCurrentItemWithPlayerItem:self.item];
                                 }
                                 
                                 if (_timeObserver)
                                 {
                                     [self.player removeTimeObserver:_timeObserver];
                                     _timeObserver = nil;
                                 }
                                 
                                 __weak typeof (self) weakSelf = self;
                                 self.timeObserver = [_player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0)
                                                                                           queue:dispatch_get_main_queue()
                                                                                      usingBlock:^(CMTime time) {
                                                                                          
                                                                                          CGFloat currentTime = CMTimeGetSeconds(time);
                                                                                          weakSelf.control.currentTime = currentTime;
                                                                                      }];
                                 
                                 [_player play];
                                 
                             });
                         }];
    
    
}

#pragma mark --- UIGestureRecognizerDelegate

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    
    if (0 == self.control.alpha) {
        return YES;
    }else{
        CGPoint point = [touch locationInView:self];
        if (CGRectContainsPoint(self.control.frame, point)) {
            return NO;
        }else{
            return YES;
        }
    }
}

#pragma mark ---- KVO

-(void)observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(id)object
                       change:(NSDictionary<NSString *,id> *)change
                      context:(void *)context{
    
    if([keyPath isEqualToString:@"status"])
    {
        AVPlayerStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        
        switch (status) {
            case AVPlayerStatusReadyToPlay:{
                _control.playing = YES;
                
                AVPlayerItem *playerItem = (AVPlayerItem *)object;
                NSTimeInterval duration = CMTimeGetSeconds(playerItem.asset.duration);
                _control.videoDuration = duration;
            }
                break;
            case AVPlayerStatusFailed:{
                _control.playing = NO;
                
                AVPlayerItem *playerItem = (AVPlayerItem *)object;
                [self assetFailedToPrepareForPlayback:playerItem.error.localizedDescription];
            }
                break;
            case AVPlayerStatusUnknown:{
                _control.playing = NO;
            }
                break;
            default:
                break;
        }
    }
    
}

#pragma mark ---- private
-(void)setupUI{

    self.originFrame = self.frame;
    
    self.player = [[AVPlayer alloc] init];
    AVPlayerLayer *layer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.layer addSublayer:layer];
    self.playerLayer = layer;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(showOrHiddenControl)];
    [self addGestureRecognizer:tap];
    tap.delegate = self;
    
    DNPlayerControl *control = [[DNPlayerControl alloc] init];
    control.alpha = 0.0;
    [self addSubview:control];
    self.control = control;
    
    __weak typeof(self) weakSelf = self;
    [control showWithClickHandle:^(DNPlayerControl *playerControl, BOOL isPlaying) {
        //暂停/播放
        if (isPlaying) {
            [weakSelf.player pause];
        }else{
            [weakSelf.player play];
        }
    }
                fullscreenHandle:^(DNPlayerControl *playerControl, BOOL isFullScreen) {
                    if (isFullScreen) {
                        //还原
                        [UIView animateWithDuration:0.5f animations:^{
                            weakSelf.transform = CGAffineTransformIdentity;
                            weakSelf.frame = weakSelf.originFrame;
                        }completion:^(BOOL finished) {
                            weakSelf.control.fullscreen = NO;
                            //缩小后自动隐藏掉工具条
                            [weakSelf showOrHiddenControl];
                            [[NSNotificationCenter defaultCenter] postNotificationName:CHANGE_TO_VERTICAL
                                                                                object:nil];
                            
                        }];
                    }else{
                        
                        //横屏
                        CGSize screenSize = [UIScreen mainScreen].bounds.size;
                        
                        CGRect frect = CGRectZero;
                        frect.origin.x = (screenSize.width - screenSize.height) / 2.0f;
                        frect.origin.y = (screenSize.height - screenSize.width) / 2.0f;
                        frect.size.width = screenSize.height;
                        frect.size.height = screenSize.width;

                        [UIView animateWithDuration:0.0f animations:^{
                            weakSelf.frame = frect;
                        }completion:^(BOOL finished) {
                            weakSelf.transform = CGAffineTransformMakeRotation(-M_PI_2);
                            weakSelf.control.fullscreen = YES;
                            //放大后自动隐藏掉工具条
                            [weakSelf showOrHiddenControl];
                            
                            [[NSNotificationCenter defaultCenter] postNotificationName:CHANGE_TO_HORIZONTAL
                                                                                object:nil];
                        }];

                    }
        
    }
                     progressHandle:^(DNPlayerControl *playerControl,CGFloat timeInterval, BOOL isFinished) {
                            //进度控制
                            if(isFinished){
                                
                                CMTime time = CMTimeMakeWithSeconds(timeInterval, weakSelf.player.currentItem.duration.timescale);
                                [weakSelf.player seekToTime:time
                                          completionHandler:^(BOOL finished) {
                                              
                                                [weakSelf.player play];
                                                weakSelf.control.playing = YES;
                                }];
                            }else{
                                if(weakSelf.player.rate > 0)
                                {
                                    weakSelf.control.playing = NO;
                                    [weakSelf.player pause];
                                }
                            }
    }];

}

-(void)showOrHiddenControl{
    
    static BOOL isShowControl = NO;
    
    [UIView animateWithDuration:kAnimationDuration
                     animations:^{
                        if (!isShowControl) {
                            self.control.alpha = 0.9f;
                            
                        }else{
                            self.control.alpha = 0.0f;
                        }
        
    }];
    isShowControl = !isShowControl;
    
}

-(void)assetFailedToPrepareForPlayback:(NSString *)title
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:nil
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
    [alertView show];
#pragma clang diagnostic pop
}

@end
