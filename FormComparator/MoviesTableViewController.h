//
//  MoviesTableViewController.h
//  FormComparator
//
//  Created by Takuya on 2014/05/18.
//  Copyright (c) 2014年 Takuya. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MoviesTableViewController : UITableViewController <UITextFieldDelegate>

@property (strong, nonatomic) NSMutableArray *selectedUrls;
@property (strong, nonatomic) UITableView *tableViewController;

@end
