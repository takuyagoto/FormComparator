//
//  PlayerView.h
//  FormComparator
//
//  Created by Takuya on 2014/05/18.
//  Copyright (c) 2014年 Takuya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol PlayerViewDelegate <NSObject>

@end

@interface PlayerView : UIView
{
    UILabel* debugLabel;
    id<PlayerViewDelegate> _delegate;
}

@property (nonatomic) id<PlayerViewDelegate> delegate;
@property (nonatomic, readonly) AVPlayer *player;
@property (nonatomic, readonly) AVPlayerItem *playerItem;
@property (nonatomic) float rate;
@property (nonatomic, readonly) BOOL analized;

- (id)initWithURL:(NSURL *)URL;
- (void)setURL:(NSURL *)URL;
- (void)anyUpdateLabel;
- (void)rewindFrame;
- (void)forwardFrame;
- (void)rotate90;

@end

@protocol UNPlayerViewDelegate <NSObject>

- (void)playerViewDidFinishAnalize:(PlayerView *)playerView;

@end
