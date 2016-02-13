//
//  FlagPlayerViewController.h
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
#import "FlagClass.h"

@interface FlagPlayerViewController : UIViewController<SelectPlaySpeedDelegate, PlayerViewDelegate>

@property (strong, nonatomic) NSURL *selectedUrl;
@property (nonatomic) float flagTime;
@property (nonatomic) BOOL configFlag;

@end
