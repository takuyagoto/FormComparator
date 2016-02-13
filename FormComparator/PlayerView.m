//
//  PlayerView.m
//  FormComparator
//
//  Created by Takuya on 2014/05/18.
//  Copyright (c) 2014年 Takuya. All rights reserved.
//

#import "PlayerView.h"

@interface PlayerView()
{
    NSURL *url;
    AVPlayer *player;
    AVPlayerItem *playerItem;
    AVPlayerLayer *playerLayer;
    UIButton *forwardButton;
    NSTimer *forwardTimer;
    UIButton *rewindButton;
    NSTimer *rewindTimer;
}
@end

@implementation PlayerView

@synthesize delegate = _delegate;
@synthesize player;
@synthesize playerItem;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithURL:(NSURL *)URL
{
    self = [super init];
    if (self) {
        [self setURL:URL];
    }
    return self;
}

- (void)loadView
{
    [self setupPlayer];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self setupPlayer];
}

- (void)setURL:(NSURL *)URL
{
    url = URL;
    [self setupPlayer];
}

- (void)setupPlayer
{
    if(CGRectIsNull(self.frame) || url == nil) return;
    if (playerLayer) {
        playerItem = nil;
        player = nil;
        [playerLayer removeFromSuperlayer];
        playerLayer = nil;
    }
    playerItem = [[AVPlayerItem alloc] initWithURL:url];
    player = [[AVPlayer alloc] initWithPlayerItem:playerItem];
    playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
    [playerLayer addObserver:self forKeyPath:@"readyForDisplay" options:NSKeyValueObservingOptionNew context:nil];
    playerLayer.frame = CGRectMake(5., 15, self.frame.size.width-10, self.frame.size.height-16);
    [self.layer addSublayer:playerLayer];
    
    if (forwardButton == nil) {
        forwardButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [forwardButton setTitle:@"" forState:UIControlStateNormal];
        forwardButton.alpha = self.userInteractionEnabled;
        forwardButton.frame = CGRectMake(self.frame.size.width / 2, 0, self.frame.size.width / 2, self.frame.size.height);
        [forwardButton addTarget:self action:@selector(startForwarding) forControlEvents:UIControlEventTouchDown];
        [forwardButton addTarget:self action:@selector(stopForwarding) forControlEvents:UIControlEventTouchUpInside];
        [forwardButton addTarget:self action:@selector(stopForwarding) forControlEvents:UIControlEventTouchUpOutside];
        [self addSubview:forwardButton];
    }
    
    if (rewindButton == nil) {
        rewindButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [rewindButton setTitle:@"" forState:UIControlStateNormal];
        rewindButton.alpha = self.userInteractionEnabled;
        rewindButton.frame = CGRectMake(0, 0, self.frame.size.width / 2, self.frame.size.height);
        [rewindButton addTarget:self action:@selector(startRewinding) forControlEvents:UIControlEventTouchDown];
        [rewindButton addTarget:self action:@selector(stopRewinding) forControlEvents:UIControlEventTouchUpInside];
        [rewindButton addTarget:self action:@selector(stopRewinding) forControlEvents:UIControlEventTouchUpOutside];
        [self addSubview:rewindButton];
    }
    
    if (debugLabel  == nil) {
        debugLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 500, 20)];
        debugLabel.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.0f];
        debugLabel.textColor = [UIColor whiteColor];
        debugLabel.text = [NSString stringWithFormat:@"play now / duration"];
        debugLabel.alpha = 0.0f;
        [self addSubview:debugLabel];
    }

    [self anyUpdateLabel];
}

- (void)rotate90
{
    playerLayer.transform =  CATransform3DMakeRotation(90.0 * M_PI / 180.0, 0.0, 0.0, 1.0);
    playerLayer.frame = CGRectMake(5., 10, self.frame.size.width-10, self.frame.size.height-11);
}

- (void)setRate:(float)rate { player.rate = rate; }

- (float)rate { return player.rate; }

- (void)setUserInteractionEnabled:(BOOL)userInteractionEnabled {
    [super setUserInteractionEnabled:userInteractionEnabled];
    forwardButton.alpha = userInteractionEnabled;
    rewindButton.alpha = userInteractionEnabled;
    debugLabel.alpha = userInteractionEnabled;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"readyForDisplay"])
        if (player.status == AVPlayerItemStatusReadyToPlay)
            [playerLayer removeObserver:self forKeyPath:@"readyForDisplay"];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint location = [[touches anyObject] locationInView:self];
    location = [self convertPoint:location fromView:self];
}

- (void)startForwarding
{
    [self forward];
    forwardTimer = [NSTimer scheduledTimerWithTimeInterval:0.15f target:self selector:@selector(forward) userInfo:nil repeats:YES];
}

- (void)stopForwarding
{
    [forwardTimer invalidate];
}

- (void)forward
{
    [playerItem seekToTime:CMTimeAdd(playerItem.currentTime, CMTimeMake(1, 30)) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    
    // 時間調整
    [self forwardNotification];
    
    [self anyUpdateLabel];
}

- (void)forwardNotification
{
    NSNotification* notification;
    notification = [NSNotification notificationWithName:@"forward"
                                                 object:self userInfo:nil];
    
    // NSNotificationCenterを取得する
    NSNotificationCenter *center;
    center = [NSNotificationCenter defaultCenter];
    
    // 通知を行う
    [center postNotification:notification];
}

- (void)rewindNotification
{
    NSNotification* notification;
    notification = [NSNotification notificationWithName:@"rewind"
                                                 object:self userInfo:nil];
    
    // NSNotificationCenterを取得する
    NSNotificationCenter *center;
    center = [NSNotificationCenter defaultCenter];
    
    // 通知を行う
    [center postNotification:notification];
}

- (void)startRewinding
{
    [self rewind];
    rewindTimer = [NSTimer scheduledTimerWithTimeInterval:0.15f target:self selector:@selector(rewind) userInfo:nil repeats:YES];
}

- (void)stopRewinding
{
    [rewindTimer invalidate];
}

- (void)rewind
{
    NSLog(@"rewind");
    [playerItem seekToTime:CMTimeSubtract(playerItem.currentTime, CMTimeMake(1, 30)) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    
    [self rewindNotification];
    [self anyUpdateLabel];
}

- (void)anyUpdateLabel
{
    float duration = CMTimeGetSeconds(playerItem.asset.duration);
    NSInteger dsec = duration;
    NSInteger dmsec = duration * 1000;
    float currentTime = CMTimeGetSeconds(playerItem.currentTime);
    NSInteger csec = currentTime;
    NSInteger cmsec = currentTime * 1000;
    if (debugLabel == nil) {
        // subview
        
    } else {
        debugLabel.text = [NSString stringWithFormat:@"%d:%02d:%03d / %d:%02d:%03d", (int)csec/60, (int)csec%60, (int)cmsec%1000, (int)dsec/60, (int)dsec%60, (int)dmsec%1000];
    }
}

- (void)rewindFrame
{
    [self startRewinding];
    [self stopRewinding];
}

- (void)forwardFrame
{
    [self startForwarding];
    [self stopForwarding];
}

@end
