//
//  DNPlayerControl.m
//  AVPlayer
//
//  Created by liurihua on 15/10/28.
//  Copyright © 2015年 刘日华. All rights reserved.
//

#import "DNPlayerControl.h"

@interface DNPlayerControl ()

@property(nonatomic, weak) UIButton                           *playBtn;
@property(nonatomic, weak) UIButton                           *fullscreenBtn;
@property(nonatomic, weak) UISlider                           *progress;
@property(nonatomic, weak) UILabel                            *currentTimeLabel;
@property(nonatomic, weak) UILabel                            *totalTimeLabel;

@property(nonatomic, copy) DNPlayerControlPlayBtnHandle       playBtnHandle;
@property(nonatomic, copy) DNPlayerControlFullscreenBtnHandle fullscreenHandle;
@property(nonatomic, copy) DNPlayerControlProgerssHandle      progressHandle;

@end

@implementation DNPlayerControl

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
    
    CGFloat selfWidth = self.frame.size.width;
    CGFloat selfHeight = self.frame.size.height;
    
    self.progress.frame = CGRectMake(selfWidth * 0.5 - selfWidth * 0.2 * 0.5, 0, selfWidth * 0.2, selfHeight);
    
    self.currentTimeLabel.frame = CGRectMake(CGRectGetMinX(self.progress.frame) -  selfWidth * 0.2, selfHeight * 0.5 - 10, selfWidth * 0.2, 20);
    
    self.totalTimeLabel.frame = CGRectMake(CGRectGetMaxX(self.progress.frame), selfHeight * 0.5 - 10, selfWidth * 0.2, 20);
    
    self.playBtn.frame = CGRectMake(0, 0, selfWidth * 0.2, selfHeight);
    
    self.fullscreenBtn.frame = CGRectMake(selfWidth * 0.8, 0, selfWidth * 0.2, selfHeight);
}


#pragma mark ---- setter
-(void)setVideoDuration:(NSTimeInterval)videoDuration{
    _videoDuration = videoDuration;
    self.totalTimeLabel.text = [self getTimeStr:videoDuration];
}

-(void)setPlaying:(BOOL)playing{
    _playing = playing;
    if(playing)
    {
        [_playBtn setTitle:@"暂停"
                  forState:UIControlStateNormal];
    }else
    {
        [_playBtn setTitle:@"播放"
                  forState:UIControlStateNormal];
    }
}

-(void)setFullscreen:(BOOL)fullscreen{
    _fullscreen = fullscreen;
    if(fullscreen)
    {
        [_fullscreenBtn setTitle:@"缩小"
                        forState:UIControlStateNormal];
    }else
    {
        [_fullscreenBtn setTitle:@"放大"
                        forState:UIControlStateNormal];
    }
}

-(void)setCurrentTime:(NSTimeInterval)currentTime{
    _currentTime = currentTime;
    
    self.currentTimeLabel.text = [self getTimeStr:currentTime];
    [self.progress setValue:currentTime / _videoDuration
                   animated:YES];
}

#pragma mark ---- public

-(void)showWithClickHandle:(DNPlayerControlPlayBtnHandle)playBtnHandle
          fullscreenHandle:(DNPlayerControlFullscreenBtnHandle)fullscreenHandle
               progressHandle:(DNPlayerControlProgerssHandle)progressHandle{
    
    self.playBtnHandle = playBtnHandle;
    self.fullscreenHandle = fullscreenHandle;
    self.progressHandle = progressHandle;
}

#pragma mark ---- private

-(void)setupUI{
    
    UIButton *playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [playBtn setTitle:@"暂停"
             forState:UIControlStateNormal];
    
    [playBtn setTitleColor:[UIColor blackColor]
                  forState:UIControlStateNormal];
    
    [playBtn addTarget:self
                action:@selector(playBtnClick:)
      forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:playBtn];
    self.playBtn = playBtn;
    
    UIButton *fullscreenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [fullscreenBtn setTitle:@"放大"
                   forState:UIControlStateNormal];
    
    [fullscreenBtn setTitleColor:[UIColor blackColor]
                        forState:UIControlStateNormal];

    [fullscreenBtn addTarget:self
                      action:@selector(fullscreenBtnClick:)
            forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:fullscreenBtn];
    self.fullscreenBtn = fullscreenBtn;
    
    UISlider *progress = [[UISlider alloc] init];
    progress.value = 0;
    progress.tintColor = [UIColor orangeColor];
    progress.enabled = YES;
    
    [progress addTarget:self
                 action:@selector(slideAction:)
       forControlEvents:UIControlEventValueChanged];
    
    [progress addTarget:self
                 action:@selector(moveEndAction:)
       forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:progress];
    self.progress = progress;
    
    UILabel *currentTimeLabel = [[UILabel alloc] init];
    currentTimeLabel.textColor = [UIColor blackColor];
    currentTimeLabel.textAlignment = NSTextAlignmentRight;
    currentTimeLabel.text = @"--:--";
    [self addSubview:currentTimeLabel];
    self.currentTimeLabel = currentTimeLabel;
    
    UILabel *totalTimeLabel = [[UILabel alloc] init];
    totalTimeLabel.textColor = [UIColor blackColor];
    totalTimeLabel.textAlignment = NSTextAlignmentLeft;
    totalTimeLabel.text = @"--:--";
    [self addSubview:totalTimeLabel];
    self.totalTimeLabel = totalTimeLabel;
    
    self.backgroundColor = [UIColor colorWithWhite:213/256.0
                                             alpha:0.5];
}

-(void)playBtnClick:(UIButton *)sender{
    
    if (_playBtnHandle) {
        _playBtnHandle(self,self.isPlaying);
    }
    self.playing = !self.isPlaying;
    
}

-(void)fullscreenBtnClick:(UIButton *)sender{
    
    if (_progressHandle) {
        _fullscreenHandle(self,self.isFullscreen);
    }
    self.fullscreen = !self.isFullscreen;
    
}

-(void)slideAction:(UISlider *)slider
{
    CGFloat progress = slider.value;
    
    CGFloat interval = progress * _videoDuration;
    self.currentTime = interval;
    
    if(_progressHandle)
    {
        _progressHandle(self,_currentTime,NO);
    }
}

-(void)moveEndAction:(UISlider *)slider
{
    CGFloat progress = slider.value;
    
    CGFloat interval = progress * _videoDuration;
    self.currentTime = interval;
    
    if(_progressHandle)
    {
        _progressHandle(self,_currentTime,YES);
    }
}

-(NSString *)getTimeStr:(CGFloat)timeInterval{
    
    NSInteger hour = timeInterval / 3600.f;
    NSInteger minute = (timeInterval - hour * 3600.f) / 60.f;
    NSInteger second = timeInterval - hour * 3600.f - minute * 60.f;
    
    if(hour > 0)
    {
        return [NSString stringWithFormat:@"%ld:%02ld:%02ld",(long)hour,(long)minute,(long)second];
    }
    else
    {
        return [NSString stringWithFormat:@"%02ld:%02ld",(long)minute,(long)second];
    }
}



@end
