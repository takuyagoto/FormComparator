//
//  FlagPlayerViewController.m
//  FormComparator
//
//  Created by Takuya on 2014/05/18.
//  Copyright (c) 2014年 Takuya. All rights reserved.
//

#import "FlagPlayerViewController.h"

@interface FlagPlayerViewController ()
{
    MoviesTableViewController  *moviesTableViewController;
    
    PlayerView *playerView;
    UIToolbar *toolbar;
    UIBarButtonItem *playButtonItem;
    UIBarButtonItem *stopButtonItem;
    UIBarButtonItem *rewindButtonItem;
    UIBarButtonItem *forwardButtonItem;
    UIBarButtonItem *configButtonItem;
    UIBarButtonItem *flagButtonItem;
    UIBarButtonItem *controllerButtonItem;
    UIBarButtonItem *space;
    BOOL playing;
    
    UILabel *currentTimeLabel;
    UISlider *slider;
    UILabel *durationLabel;
    
    float playSpeed;
    
    UIActivityIndicatorView *indicatorView;
    double marginTime;
    
    SelectPlaySpeedViewController *selectPlaySpeedViewController;
    UIViewController *rootViewController;
    
}
@end

@implementation FlagPlayerViewController

@synthesize selectedUrl;
@synthesize flagTime;
@synthesize configFlag;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = NO;
    self.view.backgroundColor = [UIColor grayColor];
    self.view.userInteractionEnabled = YES;
    playSpeed = 1.0;
    
    selectPlaySpeedViewController = [[SelectPlaySpeedViewController alloc] init];
    rootViewController = [UIApplication sharedApplication].delegate.window.rootViewController;
    rootViewController.modalPresentationStyle = UIModalPresentationCurrentContext;
    selectPlaySpeedViewController.delegate = self;
    
    configFlag = NO;
    
    playerView = [[PlayerView alloc] initWithFrame:CGRectMake(0., 60., self.view.frame.size.width, self.view.frame.size.height - 144)];
    playerView.backgroundColor = [UIColor blackColor];
    playerView.delegate = self;
    playerView.userInteractionEnabled = YES;
    [self.view addSubview:playerView];
    
    [self setupSeekBar:CGRectMake(10., self.view.bounds.size.height-44, self.view.frame.size.width - 10, 44.)];
    [self setupToolBar];
    [self.view addSubview:toolbar];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //playerView = nil;
    [self stop:playButtonItem];
    //[playerView removeFromSuperview];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!configFlag) {
        
        playing = NO;
        if (playerView == nil) {
            playerView = [[PlayerView alloc] initWithFrame:CGRectMake(0., 60., self.view.frame.size.width, self.view.frame.size.height - 144)];
            playerView.backgroundColor = [UIColor blackColor];
            playerView.delegate = self;
            playerView.userInteractionEnabled = YES;
            [self.view addSubview:playerView];
        }
        
        if(selectedUrl) {
            marginTime = 0.0f;
            [playerView setURL:selectedUrl];
            [moviesTableViewController.selectedUrls removeAllObjects];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerDidPlayToEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:playerView.player.currentItem];
            
            // 再生時間をずらした際のイベント取得
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeMarginTime:) name:@"forward" object:playerView];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeMarginTime:) name:@"rewind" object:playerView];
            // 再生時間合わせイベント取得
            //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerTimeJumped:) name:AVPlayerItemTimeJumpedNotification object:playerView2.player.currentItem];
            
            slider.maximumValue = CMTimeGetSeconds(playerView.playerItem.asset.duration);
            
            durationLabel.text = [self timeToString:slider.maximumValue];
            
            const CMTime time = CMTimeMake(1, 10);
            __block FlagPlayerViewController *blockself = self;
            [playerView.player addPeriodicTimeObserverForInterval:time queue:NULL usingBlock:^(CMTime time){ [blockself syncSlider]; }];
        }else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

#pragma # SeekBar Methods
- (void)setupSeekBar:(CGRect)frame
{
    if (currentTimeLabel == nil) {
        currentTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, 40., frame.size.height)];
        currentTimeLabel.backgroundColor = [UIColor clearColor];
        [self.view addSubview:currentTimeLabel];
    }
    
    if (!flagTime) flagTime = 0.0;
    
    if (slider == nil) {
        slider = [[UISlider alloc] initWithFrame:CGRectMake(frame.origin.x+40, frame.origin.y, frame.size.width-110, frame.size.height)];
        slider.backgroundColor = [UIColor clearColor];
        slider.maximumValue = 0.0;
        slider.minimumValue = 0.0;
        slider.value = 0;
        [slider addTarget:self action:@selector(sliderValueChanged) forControlEvents:UIControlEventValueChanged];
        [self.view addSubview:slider];
    }
    
    if (durationLabel == nil) {
        durationLabel = [[UILabel alloc] initWithFrame:CGRectMake(frame.origin.x+frame.size.width-70, frame.origin.y, 40., frame.size.height)];
        durationLabel.backgroundColor = [UIColor clearColor];
        durationLabel.textAlignment = NSTextAlignmentRight;
        [self.view addSubview:durationLabel];
    }
    
    currentTimeLabel.text = [self timeToString:slider.value];
    durationLabel.text = [self timeToString:slider.maximumValue];
}

- (void)syncSlider
{
    CMTimeShow([playerView.playerItem currentTime]);
    const double time = CMTimeGetSeconds([playerView.playerItem currentTime]);
    [slider setValue:time];
    currentTimeLabel.text = [self timeToString:slider.value];
}

- (void)sliderValueChanged
{
    if (playerView.rate != 0.0f) {
        [self stop:playButtonItem];
    }
    
    NSLog(@"marginTime: %f", marginTime);
    
    CMTime time;
    time = CMTimeMakeWithSeconds(slider.value, NSEC_PER_SEC);
    
    [playerView.playerItem seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    [playerView anyUpdateLabel];
}

- (NSString* )timeToString:(float)value
{
    const NSInteger time = value;
    return [NSString stringWithFormat:@"%d:%02d", (int)(time / 60), (int)(time % 60)];
}

#pragma # ToolBar Methods
- (void)setupToolBar
{
    if (toolbar == nil) {
        toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height-88, self.view.frame.size.width, 44.)];
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
    if (flagButtonItem == nil) {
        flagButtonItem = [[UIBarButtonItem alloc] initWithTitle:[NSString stringWithFormat:@"Flag:%@", [FlagClass getFlagTimeForLabel:flagTime]] style:2 target:self action:@selector(flag:)];
    }
    if (configButtonItem == nil) {
        configButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Config" style:2 target:self action:@selector(config:)];
        
    }
    if (space == nil) {
        space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    }
    toolbar.items = [NSArray arrayWithObjects:
                     space,
                     flagButtonItem,
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
    [flagButtonItem setTitle:[NSString stringWithFormat:@"Flag:%@", [FlagClass getFlagTimeForLabel:flagTime]]];
    [toolbar setItems:[NSArray arrayWithObjects:
                       space,
                       flagButtonItem,
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
    [selectPlaySpeedViewController setSelectedPlaySpeed:playSpeed];
    [self presentViewController:selectPlaySpeedViewController animated:YES completion:nil];
    [self updateToolBar];
}

- (void)play:(UIBarButtonItem *)button
{
    if(playing) {
        [self stop:button];
        //controllerButtonItem = playButtonItem;
        
    }else {
        playing = YES;
        playerView.userInteractionEnabled = NO;
        playerView.rate = playSpeed;
        //controllerButtonItem = stopButtonItem;
    }
    [self updateToolBar];
}

- (void)stop:(UIBarButtonItem *)button
{
    playing = NO;
    playerView.userInteractionEnabled = YES;
    playerView.rate = 0.0f;
    //controllerButtonItem = playButtonItem;
}

- (void)rewind:(UIBarButtonItem *)button
{
    [playerView rewindFrame];
}

- (void)forward:(UIBarButtonItem *)button
{
    [playerView forwardFrame];
}

- (void)flag:(UIBarButtonItem *)button
{
    if (playing) {
        [self stop:playButtonItem];
    }
    flagTime = slider.value;
    [FlagClass updateFlagTime:flagTime forKey:[selectedUrl absoluteString]];
    [self updateToolBar];
}

#pragma # Observer Methods
- (void)playerDidPlayToEnd:(NSNotification *)notification
{
    [playerView.player pause];
    [self stop:playButtonItem];
    [playerView.player seekToTime:kCMTimeZero];
    [self updateToolBar];
}


- (void)changeMarginTime:(NSNotification *)notification
{
    marginTime = CMTimeGetSeconds(playerView.playerItem.currentTime);
}

- (void)playerTimeJumped:(NSNotification *)notification
{
    marginTime = CMTimeGetSeconds(playerView.playerItem.currentTime);
}

- (void)finishView:(float)returnVal
{
    playSpeed = returnVal;
    [self dismissViewControllerAnimated:YES completion:nil];
    NSLog(@"%f", playSpeed);
}

@end