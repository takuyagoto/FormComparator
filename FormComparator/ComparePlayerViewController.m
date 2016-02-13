//
//  ComparePlayerViewController.m
//  FormComparator
//
//  Created by Takuya on 2014/05/18.
//  Copyright (c) 2014年 Takuya. All rights reserved.
//

#import "ComparePlayerViewController.h"

@interface ComparePlayerViewController ()
{
    BOOL playing;
    PlayerView *playerView1;
    PlayerView *playerView2;
    UIBarButtonItem *playButtonItem;
    UIBarButtonItem *stopButtonItem;
    UIBarButtonItem *rewindButtonItem;
    UIBarButtonItem *forwardButtonItem;
    UIBarButtonItem *configButtonItem;
    UIBarButtonItem *adjustButtonItem;
    UIBarButtonItem *controllerButtonItem;
    UIBarButtonItem *space;
    UILabel *currentTimeLabel;
    UISlider *slider;
    UILabel *durationLabel;
    
    UIActivityIndicatorView *indicatorView;
    double marginTime;
    
    UIToolbar *toolbar;
    float playSpeed;
    int shorterPlayer;
    float startTime1;
    float startTime2;
    
    SelectPlaySpeedViewController *selectPlaySpeedViewController;
    UIViewController *rootViewController;    
}
@end

@implementation ComparePlayerViewController

@synthesize selectedUrl1;
@synthesize selectedUrl2;
@synthesize flagTime1;
@synthesize flagTime2;
@synthesize configFlag;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    configFlag = NO;
    
    playing = NO;
    playerView1 = [[PlayerView alloc] initWithFrame:CGRectMake(0., 65, self.view.frame.size.width, (self.view.frame.size.height - 153)/2)];
    playerView1.backgroundColor = [UIColor blackColor];
    playerView1.delegate = self;
    playerView1.userInteractionEnabled = YES;
    [self.view addSubview:playerView1];
    playerView2 = [[PlayerView alloc] initWithFrame:CGRectMake(0., 65 + ((self.view.frame.size.height - 153)/2), self.view.frame.size.width, (self.view.frame.size.height - 153)/2)];
    playerView2.backgroundColor = [UIColor darkGrayColor];
    playerView2.delegate = self;
    playerView2.userInteractionEnabled = YES;
    [self.view addSubview:playerView2];
    
    [self setupToolBar];
    [self.view addSubview:toolbar];
    //[self setupView];
}

- (void) prepareView
{
    playing = NO;
    playerView1 = [[PlayerView alloc] initWithFrame:CGRectMake(0., 65, self.view.frame.size.width, (self.view.frame.size.height - 153)/2)];
    playerView1.backgroundColor = [UIColor blackColor];
    playerView1.delegate = self;
    playerView1.userInteractionEnabled = YES;
    [self.view addSubview:playerView1];
    playerView2 = [[PlayerView alloc] initWithFrame:CGRectMake(0., 65 + ((self.view.frame.size.height - 153)/2), self.view.frame.size.width, (self.view.frame.size.height - 153)/2)];
    playerView2.backgroundColor = [UIColor darkGrayColor];
    playerView2.delegate = self;
    playerView2.userInteractionEnabled = YES;
    [self.view addSubview:playerView2];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!configFlag) {
      [self setupView];
    }
    //[self setupView];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //playerView1 = nil;
    //playerView2 = nil;
    [self stop:playButtonItem];
    selectPlaySpeedViewController = nil;
}

- (void)setupView
{
    self.navigationController.navigationBarHidden = NO;
    self.view.backgroundColor = [UIColor grayColor];
    self.view.userInteractionEnabled = YES;
    playSpeed = 1.0;
    
    if (!flagTime1) flagTime1 = 0.0;
    if (!flagTime2) flagTime2 = 0.0;
    
    if (playerView1 == nil) {
        playerView1 = [[PlayerView alloc] initWithFrame:CGRectMake(0., 65, self.view.frame.size.width, (self.view.frame.size.height - 153)/2)];
        playerView1.backgroundColor = [UIColor blackColor];
        playerView1.delegate = self;
        playerView1.userInteractionEnabled = YES;
        [self.view addSubview:playerView1];
    }
    
    if (playerView2 == nil) {
        playerView2 = [[PlayerView alloc] initWithFrame:CGRectMake(0., 65 + ((self.view.frame.size.height - 153)/2), self.view.frame.size.width, (self.view.frame.size.height - 153)/2)];
        playerView2.backgroundColor = [UIColor darkGrayColor];
        playerView2.delegate = self;
        playerView2.userInteractionEnabled = YES;
        [self.view addSubview:playerView2];
    }
    
    if(selectedUrl1 && selectedUrl2) {
        marginTime = 0.0f;
        [playerView1 setURL:selectedUrl1];
        BOOL isPortrait = YES;
        AVURLAsset *asset1 = [[AVURLAsset alloc] initWithURL:selectedUrl1 options:nil];
        NSArray *tracks1 = [asset1 tracksWithMediaType:AVMediaTypeVideo];
        if([tracks1  count] != 0) {
            AVAssetTrack *videoTrack1 = [tracks1 objectAtIndex:0];
            CGAffineTransform t1 = videoTrack1.preferredTransform;
            if(t1.a == 0 && t1.b == 1.0 && t1.c == -1.0 && t1.d == 0)  {
                isPortrait = NO;
            }
            if(t1.a == 0 && t1.b == -1.0 && t1.c == 1.0 && t1.d == 0)  {
                isPortrait = NO;
            }
        }
        if (!isPortrait) {
            [playerView1 rotate90];
            isPortrait = YES;
        }
        [playerView2 setURL:selectedUrl2];
        AVURLAsset *asset2 = [[AVURLAsset alloc] initWithURL:selectedUrl2 options:nil];
        NSArray *tracks2 = [asset2 tracksWithMediaType:AVMediaTypeVideo];
        if([tracks2  count] != 0) {
            AVAssetTrack *videoTrack2 = [tracks2 objectAtIndex:0];
            CGAffineTransform t2 = videoTrack2.preferredTransform;
            if(t2.a == 0 && t2.b == 1.0 && t2.c == -1.0 && t2.d == 0)  {
                isPortrait = NO;
            }
            if(t2.a == 0 && t2.b == -1.0 && t2.c == 1.0 && t2.d == 0)  {
                isPortrait = NO;
            }
        }
        if (!isPortrait) {
            [playerView2 rotate90];
            isPortrait = YES;
        }
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerDidPlayToEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:playerView1.player.currentItem];
        
        // 再生時間をずらした際のイベント取得
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeMarginTime:) name:@"forward" object:playerView1];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeMarginTime:) name:@"rewind" object:playerView1];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeMarginTime:) name:@"forward" object:playerView2];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeMarginTime:) name:@"rewind" object:playerView2];
        // 再生時間合わせイベント取得
        /*
         Float64 duration1 = CMTimeGetSeconds(playerView1.playerItem.asset.duration);
         Float64 duration2 = CMTimeGetSeconds(playerView2.playerItem.asset.duration);
         shorterPlayer = duration1 > duration2 ? 2 : 1;
         slider.maximumValue = (shorterPlayer == 1 ? (duration1 - startTime1) : (duration2 - startTime2));
         durationLabel.text = [self timeToString:slider.maximumValue];
         const CMTime time = CMTimeMake(1, 10);
         __block ComparePlayerViewController *blockself = self;
         if (shorterPlayer == 1){
         [playerView1.player addPeriodicTimeObserverForInterval:time queue:NULL usingBlock:^(CMTime time){ [blockself syncSlider]; }];
         } else {
         [playerView2.player addPeriodicTimeObserverForInterval:time queue:NULL usingBlock:^(CMTime time){ [blockself syncSlider]; }];
         }
         */
        
    }else {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    [self setupSeekBar];
    [self.view addSubview:slider];
    [self updateToolBar];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma # SeekBar Methods
- (void)setupSeekBar
{
    CGRect frame = CGRectMake(10., self.view.bounds.size.height-44, self.view.frame.size.width - 10, 44.);
    
    if (!currentTimeLabel) {
        currentTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, 40., frame.size.height)];
        currentTimeLabel.backgroundColor = [UIColor clearColor];
        [self.view addSubview:currentTimeLabel];
    }
    
    if (!slider) {
        slider = [[UISlider alloc] initWithFrame:CGRectMake(frame.origin.x+40, frame.origin.y, frame.size.width-110, frame.size.height)];
        slider.backgroundColor = [UIColor clearColor];
        //slider.maximumValue = 0.0;
        slider.minimumValue = 0.0;
        slider.value = 0;
        [slider addTarget:self action:@selector(sliderValueChanged) forControlEvents:UIControlEventValueChanged];
    }
    if (!durationLabel) {
        durationLabel = [[UILabel alloc] initWithFrame:CGRectMake(frame.origin.x+frame.size.width-70, frame.origin.y, 40., frame.size.height)];
        durationLabel.backgroundColor = [UIColor clearColor];
        durationLabel.textAlignment = NSTextAlignmentRight;
        [self.view addSubview:durationLabel];
    }
    
    
    currentTimeLabel.text = [self timeToString:slider.value];
    durationLabel.text = [self timeToString:slider.maximumValue];
    Float64 duration1 = CMTimeGetSeconds(playerView1.playerItem.asset.duration);
    Float64 duration2 = CMTimeGetSeconds(playerView2.playerItem.asset.duration);
    shorterPlayer = duration1 > duration2 ? 2 : 1;
    slider.maximumValue = (shorterPlayer == 1 ? (duration1 - startTime1) : (duration2 - startTime2));
    durationLabel.text = [self timeToString:slider.maximumValue];
    const CMTime time = CMTimeMake(1, 10);
    __block ComparePlayerViewController *blockself = self;
    if (shorterPlayer == 1){
        [playerView1.player addPeriodicTimeObserverForInterval:time queue:NULL usingBlock:^(CMTime time){ [blockself syncSlider]; }];
    } else {
        [playerView2.player addPeriodicTimeObserverForInterval:time queue:NULL usingBlock:^(CMTime time){ [blockself syncSlider]; }];
    }
    //[self.view addSubview:slider];
    
    
}

- (void)syncSlider
{
    if (shorterPlayer == 1){
        const double time = CMTimeGetSeconds([playerView1.playerItem currentTime]);
        [slider setValue:(time - startTime1)];
    } else {
        const double time = CMTimeGetSeconds([playerView2.playerItem currentTime]);
        [slider setValue:(time - startTime2)];
    }
    currentTimeLabel.text = [self timeToString:slider.value];
}

- (void)sliderValueChanged
{
    if (playerView1.rate != 0.0f) {
        [self stop:playButtonItem];
    }
    
    NSLog(@"marginTime: %f", marginTime);
    
    CMTime time1, time2;
    if (shorterPlayer == 1) {
        time1 = CMTimeMakeWithSeconds(startTime1 + slider.value, NSEC_PER_SEC);
        time2 = CMTimeMakeWithSeconds(startTime2 + slider.value + marginTime, NSEC_PER_SEC);
    } else {
        time1 = CMTimeMakeWithSeconds(startTime1 + slider.value + marginTime, NSEC_PER_SEC);
        time2 = CMTimeMakeWithSeconds(startTime2 + slider.value, NSEC_PER_SEC);
    }
    [playerView1.playerItem seekToTime:time1 toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    [playerView2.playerItem seekToTime:time2 toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}

- (NSString* )timeToString:(float)value
{
    const NSInteger time = value;
    return [NSString stringWithFormat:@"%d:%02d", (int)(time / 60), (int)(time % 60)];
}

#pragma # ToolBar Methods
- (void)setupToolBar
{
    if (!toolbar) {
        toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height-89, self.view.frame.size.width, 45.)];
    }
    toolbar.barStyle = UIBarStyleBlackOpaque;
    toolbar.tintColor = [UIColor grayColor];
    toolbar.translucent = YES;
    if (playButtonItem == nil) {
        playButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(play:)];
    }
    if (stopButtonItem == nil) {
        stopButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPause target:self action:@selector(play:)];
    }
    controllerButtonItem = playButtonItem;
    if (rewindButtonItem == nil) {
        rewindButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind target:self action:@selector(rewind:)];
    }
    if (forwardButtonItem == nil) {
        forwardButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward target:self action:@selector(forward:)];
    }
    if (adjustButtonItem == nil) {
        adjustButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Adjust" style:2 target:self action:@selector(adjust:)];
    }
    if (configButtonItem == nil) {
        configButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Config" style:2 target:self action:@selector(config:)];
    }
    if (space == nil) {
        space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    }
    toolbar.items = [NSArray arrayWithObjects:
                     space,
                     adjustButtonItem,
                     space,
                     rewindButtonItem,
                     space,
                     controllerButtonItem,
                     space,
                     forwardButtonItem,
                     space,
                     configButtonItem,
                     space,
                     nil];
    //[self.view addSubview:toolbar];
}

- (void) updateToolBar
{
    if (playing) {
        controllerButtonItem = stopButtonItem;
    } else {
        controllerButtonItem = playButtonItem;
    }
    [toolbar setItems:[NSArray arrayWithObjects:
                       space,
                       adjustButtonItem,
                       space,
                       rewindButtonItem,
                       space,
                       controllerButtonItem,
                       space,
                       forwardButtonItem,
                       space,
                       configButtonItem,
                       space,
                       nil]
             animated:YES];
}

- (void)config:(UIBarButtonItem *)button
{
    [self stop:playButtonItem];
    
    configFlag = YES;
    if (selectPlaySpeedViewController == nil) {
        rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
        selectPlaySpeedViewController = [[SelectPlaySpeedViewController alloc] init];
        rootViewController.modalPresentationStyle = UIModalPresentationCurrentContext;
        selectPlaySpeedViewController.delegate = self;
    }
    [selectPlaySpeedViewController setSelectedPlaySpeed:playSpeed];
    [self presentViewController:selectPlaySpeedViewController animated:YES completion:nil];
    [self updateToolBar];
}

- (void)play:(UIBarButtonItem *)button
{
    if(playing) {
        [self stop:button];
    }else {
        playing = YES;
        playerView1.userInteractionEnabled = NO;
        playerView2.userInteractionEnabled = NO;
        playerView1.rate = playSpeed;
        playerView2.rate = playSpeed;
    }
    [self updateToolBar];
}

- (void)stop:(UIBarButtonItem *)button
{
    playing = NO;
    playerView1.userInteractionEnabled = YES;
    playerView2.userInteractionEnabled = YES;
    playerView1.rate = 0.0f;
    playerView2.rate = 0.0f;
    
    [playerView1 anyUpdateLabel];
    [playerView2 anyUpdateLabel];
}

- (void)rewind:(UIBarButtonItem *)button
{
    [playerView1 rewindFrame];
    [playerView2 rewindFrame];
}

- (void)forward:(UIBarButtonItem *)button
{
    [playerView1 forwardFrame];
    [playerView2 forwardFrame];
}

- (void)adjust:(UIBarButtonItem *)button
{
    [self stop:playButtonItem];
    
    Float64 duration1 = CMTimeGetSeconds(playerView1.playerItem.asset.duration);
    Float64 duration2 = CMTimeGetSeconds(playerView2.playerItem.asset.duration);
    if ((duration1 - flagTime1) < (duration2 - flagTime2)) {
        shorterPlayer = 1;
    } else {
        shorterPlayer = 2;
    }
    [playerView1.playerItem seekToTime:CMTimeMakeWithSeconds(flagTime1, NSEC_PER_SEC) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    [playerView2.playerItem seekToTime:CMTimeMakeWithSeconds(flagTime2, NSEC_PER_SEC) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    startTime1 = flagTime1;
    startTime2 = flagTime2;
    [self setupSeekBar];
    //[self syncSlider];
    const CMTime time = CMTimeMake(1, 10);
    __block ComparePlayerViewController *blockself = self;
    if (shorterPlayer == 1){
        [playerView1.player addPeriodicTimeObserverForInterval:time queue:NULL usingBlock:^(CMTime time){ [blockself syncSlider]; }];
    } else {
        [playerView2.player addPeriodicTimeObserverForInterval:time queue:NULL usingBlock:^(CMTime time){ [blockself syncSlider]; }];
    }
    [self updateToolBar];
}

#pragma # Observer Methods
- (void)playerDidPlayToEnd:(NSNotification *)notification
{
    if (playerView1.rate == 0.0 && playerView2.rate == 0.0) {
        [self stop:playButtonItem];
        [playerView1.player seekToTime:kCMTimeZero];
        [playerView2.player seekToTime:kCMTimeZero];
        startTime1 = 0.0;
        startTime2 = 0.0;
        
        [self syncSlider];
        [self updateToolBar];
    }
    
}


- (void)changeMarginTime:(NSNotification *)notification
{
    if (shorterPlayer == 2) {
        marginTime =  CMTimeGetSeconds(playerView1.playerItem.currentTime) - startTime1 - slider.value;
    } else {
        marginTime =  CMTimeGetSeconds(playerView2.playerItem.currentTime) - startTime2 - slider.value;
    }
}

- (void)playerTimeJumped:(NSNotification *)notification
{
    marginTime = CMTimeGetSeconds(playerView1.playerItem.currentTime) - CMTimeGetSeconds(playerView2.playerItem.currentTime);
}

- (void)finishView:(float)returnVal
{
    [self dismissViewControllerAnimated:YES completion:nil];
    playSpeed = returnVal;
    NSLog(@"%f", playSpeed);
}

@end