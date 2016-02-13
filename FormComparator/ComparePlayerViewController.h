//
//  ComparePlayerViewController.h
//  FormComparator
//
//  Created by Takuya on 2014/05/18.
//  Copyright (c) 2014年 Takuya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "PlayerView.h"
#import "MoviesTableViewController.h"
#import "SelectPlaySpeedViewController.h"

@interface ComparePlayerViewController : UIViewController<SelectPlaySpeedDelegate, PlayerViewDelegate>

@property (strong, nonatomic) NSURL *selectedUrl1;
@property (strong, nonatomic) NSURL *selectedUrl2;
@property (nonatomic) float flagTime1;
@property (nonatomic) float flagTime2;
@property (nonatomic) BOOL configFlag;

@end