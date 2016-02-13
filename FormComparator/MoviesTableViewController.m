//
//  MoviesTableViewController.m
//  FormComparator
//
//  Created by Takuya on 2014/05/18.
//  Copyright (c) 2014年 Takuya. All rights reserved.
//

#import "MoviesTableViewController.h"
#import "FlagPlayerViewController.h"
#import "ComparePlayerViewController.h"

@interface MoviesTableViewController ()
{
    NSMutableArray *urls;
    NSMutableArray *thumbnails;
    NSMutableArray *assetProperties;
    NSDictionary *flagTimeDic;
    UISegmentedControl *Compare_Flag;
    NSDictionary *titleDic;
    
    FlagPlayerViewController *flagPlayerViewController;
    ComparePlayerViewController *comparePlayerViewController;
    
    int selectedIndex;
}
@end

@implementation MoviesTableViewController

@synthesize selectedUrls;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    flagPlayerViewController = [[FlagPlayerViewController alloc] init];
    comparePlayerViewController = [[ComparePlayerViewController alloc] init];
    flagTimeDic = [FlagClass getFlagTimeDictionary];
    self.navigationController.navigationBarHidden = NO;
    Compare_Flag = [[UISegmentedControl alloc] initWithItems:@[@"Compare", @"Flag"]];
    Compare_Flag.selectedSegmentIndex = 1;
    [Compare_Flag addTarget:self action:@selector(C_F:) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView = Compare_Flag;
    self.editButtonItem.title = @"Edit";
    UIBarButtonItem *barbtn = [[UIBarButtonItem alloc] initWithTitle:@"Reload"
                                                               style:UIBarButtonItemStylePlain
                                                              target:self
                                                              action:@selector(tableReload:)];
    self.navigationItem.leftBarButtonItem = barbtn;
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    selectedIndex = 999;
    selectedUrls = [[NSMutableArray alloc] init];
    [self loadALAssetsGroupe];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self getTitleDic];
    if (animated) {
        //selectedUrls = [[NSMutableArray alloc] init];
        [self.view removeFromSuperview];
        flagTimeDic = [FlagClass getFlagTimeDictionary];
        [self.tableView reloadData];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [urls count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // set cells
    NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    } else {
        for (UIView *view in [cell.contentView subviews]) {
                [view removeFromSuperview];
        }
    }
    
    if (selectedIndex != 999 && indexPath.row == selectedIndex) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    NSDictionary *assetProperty = [assetProperties objectAtIndex:indexPath.row];
    NSDate *movieDate = [assetProperty objectForKey:@"date"];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat  = @"yyyyMMddHHmmss";
    NSString *key = [df stringFromDate:movieDate];
    UITextField *tf = [[UITextField alloc] initWithFrame:CGRectMake(110, 5, 320, 30)];
    tf.delegate = self;
    tf.tag = indexPath.row;
    tf.autoresizingMask=UIViewAutoresizingFlexibleRightMargin;
    tf.autoresizesSubviews=YES;
    tf.returnKeyType = UIReturnKeyDone;
    NSString *title;
    if ([[titleDic allKeys] containsObject:key]) {
        title = [titleDic objectForKey:key];
    } else {
        NSDateFormatter *titleDf = [[NSDateFormatter alloc] init];
        titleDf.dateFormat  = @"yyyy/MM/dd HH:mm";
        title = [titleDf stringFromDate:movieDate];
    }
    tf.text = title;
    [cell.contentView addSubview:tf];
    
    NSURL *url = [urls objectAtIndex:indexPath.row];
    NSString *flagTime = [flagTimeDic objectForKey:[url absoluteString]];
    float flg = 0;
    if (flagTime) flg = flagTime.floatValue;
    flagTime = [FlagClass getFlagTimeForLabel:flg];
    cell.imageView.image = [thumbnails objectAtIndex:indexPath.row];
    NSNumber *durationTime = [assetProperty objectForKey:@"duration"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%3.02f(Flag Time:%@)", durationTime.floatValue,  flagTime];
    
    return cell;
}

// Do this event when a cell was selected
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int selectedCount;
    switch (Compare_Flag.selectedSegmentIndex) {
        case 0:
            selectedCount = 2;
            if ([selectedUrls count] > 0) {
                if (selectedIndex == indexPath.row) {
                    selectedIndex = 999;
                    [selectedUrls removeObject:[urls objectAtIndex:indexPath.row]];
                    [self.tableView reloadData];
                    return;
                }
            }
            selectedIndex = indexPath.row;
            [selectedUrls addObject:[urls objectAtIndex:indexPath.row]];
            if (selectedUrls.count == 2) {
                NSURL *url = [selectedUrls objectAtIndex:0];
                [comparePlayerViewController setSelectedUrl1:url];
                NSString *flg1 = [flagTimeDic objectForKey:[url absoluteString]];
                if (flg1) {
                    [comparePlayerViewController setFlagTime1:flg1.floatValue];
                } else {
                    [comparePlayerViewController setFlagTime1:0.0];
                }
                url = [selectedUrls objectAtIndex:1];
                [comparePlayerViewController setSelectedUrl2:url];
                NSString *flg2 = [flagTimeDic objectForKey:[url absoluteString]];
                if (flg2) {
                    [comparePlayerViewController setFlagTime2:flg2.floatValue];
                } else {
                    [comparePlayerViewController setFlagTime2:0.0];
                }
                [selectedUrls removeAllObjects];
                selectedIndex = 999;
                [comparePlayerViewController setConfigFlag:NO];
                [self.navigationController pushViewController:comparePlayerViewController animated:YES];
            } else if (selectedUrls.count > 2) {
                [selectedUrls removeAllObjects];
                selectedIndex = 999;
            }
            break;
            
        case 1:
            selectedCount = 1;
            [selectedUrls addObject:[urls objectAtIndex:indexPath.row]];
            if (selectedUrls.count == 1) {
                [flagPlayerViewController setSelectedUrl:[selectedUrls objectAtIndex:0]];
                NSString *flg = [flagTimeDic objectForKey:[[selectedUrls objectAtIndex:0] absoluteString]];
                if (flg) {
                    [flagPlayerViewController setFlagTime:flg.floatValue];
                } else {
                    [flagPlayerViewController setFlagTime:0.0];
                }
                [selectedUrls removeAllObjects];
                selectedIndex = 999;
                [flagPlayerViewController setConfigFlag:NO];
                [self.navigationController pushViewController:flagPlayerViewController animated:YES];
            } else {
                [selectedUrls removeAllObjects];
                selectedIndex = 999;
            }
            break;
            
        default:
            break;
    }
    if (selectedUrls.count == selectedCount) {
        
    }
    [self.tableView reloadData];
}

-(CGFloat)tableView:(UITableView*)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *key = [[urls objectAtIndex:indexPath.row] absoluteString];
    if ([flagTimeDic objectForKey:key]) {
        NSMutableDictionary *newDic = [[NSMutableDictionary alloc] init];
        [newDic setDictionary:flagTimeDic];
        [newDic removeObjectForKey:key];
        [FlagClass updateFlagTimeAll:newDic];
        flagTimeDic = [FlagClass getFlagTimeDictionary];
        [self.tableView reloadData];
    }
    [self setEditing:NO animated:YES];
}

- (NSString *)tableView:(UITableView *)tableView
titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"Reset";
}

-(void)setEditing:(BOOL)editing animated:(BOOL)animated{
    [super setEditing:editing animated:YES];
    
    if(editing){
        self.editButtonItem.title = @"Done";
    }else{
        self.editButtonItem.title = @"Edit";
    }
    [self.tableView reloadData];
}

#pragma mark - Load Movies
// Load Movies in Cameraralls
- (void) loadALAssetsGroupe
{
    urls = [[NSMutableArray alloc] init];
    thumbnails = [[NSMutableArray alloc] init];
    assetProperties = [[NSMutableArray alloc] init];
    
	ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                           usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                               
                               [group setAssetsFilter:[ALAssetsFilter allVideos]];
                               
                               [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                                   if (result) {
                                       NSArray *keyArrayForProperty = @[@"duration", @"date", @"representation"];
                                       NSDictionary *assetProperty =
                                       [NSDictionary dictionaryWithObjects:@[[result valueForProperty:ALAssetPropertyDuration], [result valueForProperty:ALAssetPropertyDate], [result valueForProperty:ALAssetPropertyRepresentations]] forKeys:keyArrayForProperty];
                                       [assetProperties addObject:assetProperty];
                                       [urls addObject:[[result defaultRepresentation] url]];
                                       UIImage *imageThumbnail = [UIImage imageWithCGImage:[result thumbnail]];
                                       [thumbnails addObject:imageThumbnail];
                                   } else {
                                       [self.tableView reloadData];
                                   }
                               }];
                           }
                         failureBlock:^(NSError *error) {
                             NSLog(@"Could not get AssetLibrary.");
                         }
     ];
}

- (void)C_F:(UISegmentedControl *)CorF
{
    [selectedUrls removeAllObjects];
    selectedIndex = 999;
    switch (CorF.selectedSegmentIndex) {
        case 0:
            self.editing = NO;
            self.navigationItem.rightBarButtonItem = nil;
            break;
        case 1:
            self.navigationItem.rightBarButtonItem = self.editButtonItem;
            break;
        default:
            break;
    }
    [self.tableView reloadData];
}

- (void) tableReload:(id) btn
{
    [selectedUrls removeAllObjects];
    selectedIndex = 999;
    [self loadALAssetsGroupe];
}

- (void)getTitleDic
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    titleDic = [userDefaults dictionaryForKey:@"titles"];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField*)textField
{
    if (self.editing) {
        return YES;
    }
    return NO;
}

- (BOOL)textFieldShouldEndEditing:(UITextField*)textField
{
    if (textField.text.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"名前を入力してください。" message:@"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return NO;
    }
    
    int row = textField.tag;
    NSDictionary *assetProperty = [assetProperties objectAtIndex:row];
    NSDate *movieDate = [assetProperty objectForKey:@"date"];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat  = @"yyyy/MM/dd HH:mm";
    NSString *movieDateStr = [df stringFromDate:movieDate];
    
    if ([textField.text isEqualToString:movieDateStr]) {
        [textField resignFirstResponder];
        return YES;
    }
    
    df.dateFormat  = @"yyyyMMddHHmmss";
    NSString *key = [df stringFromDate:movieDate];
    if ([[titleDic objectForKey:key] isEqualToString:textField.text]) {
        [textField resignFirstResponder];
        return YES;
    }
    
    if ([[titleDic allValues] containsObject:textField.text]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"既に同じ名前の動画があります。" message:@"別の名前を指定してください。" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return NO;
    }
    
    NSMutableDictionary *newTitleDic = [NSMutableDictionary dictionaryWithDictionary:titleDic];
    [newTitleDic setObject:textField.text forKey:key];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:@"titles"];
    [userDefaults setObject:newTitleDic forKey:@"titles"];
    [userDefaults synchronize];
    
    [self getTitleDic];
    
    [textField resignFirstResponder];
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField*)textField
{
    [textField resignFirstResponder];
    return YES;
}
@end
