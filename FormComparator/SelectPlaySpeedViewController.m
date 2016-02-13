//
//  SelectPlaySpeedViewController.m
//  FormComparator
//
//  Created by Takuya on 2014/05/18.
//  Copyright (c) 2014年 Takuya. All rights reserved.
//

#import "SelectPlaySpeedViewController.h"
@interface SelectPlaySpeedViewController ()
{
    NSArray *optionPlaySpeed;
    UIPickerView *piv;
}
@end

@implementation SelectPlaySpeedViewController

@synthesize selectedPlaySpeed;
@synthesize delegate = _delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        optionPlaySpeed = @[@"×1.00",@"×0.50"];
    }
    return self;
}

- (id)initWithPlaySpeed:(float)playSpeed
{
    self = [super init];
    selectedPlaySpeed = playSpeed;
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    //btn.center = self.view.center;
    btn.backgroundColor = [UIColor darkGrayColor];
    
    btn.frame = CGRectMake(self.view.frame.size.width / 2, self.view.frame.size.height - 288, 100, 30);
    [btn setTitle:@"完了" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(finish:)
  forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:btn];
    
    piv = [[UIPickerView alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2, self.view.frame.size.height - 258, 100, 100)];
    
    piv.backgroundColor = [UIColor whiteColor];
    piv.delegate = self;
    piv.dataSource = self;
    
    if (selectedPlaySpeed != 1.0) {
        [piv selectRow:[self getIndexOfPlaySpeed:selectedPlaySpeed] inComponent:0 animated:YES];
    } else {
        [piv selectRow:0 inComponent:0 animated:YES];
    }
    [self.view addSubview:piv];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.view.backgroundColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.7];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.view.backgroundColor = [UIColor clearColor];
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView*)pickerView
{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component
{
    return 4;
}

-(NSString*)pickerView:(UIPickerView*)pickerView
           titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    
    return [optionPlaySpeed objectAtIndex:row];
    
}

- (NSInteger) getIndexOfPlaySpeed:(float) playSpeed
{
    NSString *strVal = [NSString stringWithFormat:@"×%.2f", playSpeed];
    return [optionPlaySpeed indexOfObject:strVal];
}

- (float)getPickerValue
{
    NSString *strVal = [optionPlaySpeed objectAtIndex:[piv selectedRowInComponent:0]];
    //NSLog(@"%lu",[strVal length]);
    strVal = [strVal substringWithRange:NSMakeRange(1, 4)];
    return strVal.floatValue;
}

- (void)finish:(UIButton *)btn
{
    if ([_delegate respondsToSelector:@selector(finishView:)]){
        [_delegate finishView:[self getPickerValue]];
    }
    //[self dismissViewControllerAnimated:YES completion:nil];
}

@end