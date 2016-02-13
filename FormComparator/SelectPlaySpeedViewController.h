//
//  SelectPlaySpeedViewController.h
//  FormComparator
//
//  Created by Takuya on 2014/05/18.
//  Copyright (c) 2014年 Takuya. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SelectPlaySpeedDelegate <NSObject>
- (void)finishView:(float)returnVal;
@end

@interface SelectPlaySpeedViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>
{
    id<SelectPlaySpeedDelegate> _delegate;
}
@property (nonatomic) id<SelectPlaySpeedDelegate> delegate;
@property (nonatomic) float selectedPlaySpeed;

- (id) initWithPlaySpeed:(float)playSpeed;

@end
