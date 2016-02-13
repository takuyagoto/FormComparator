//
//  FlagClass.m
//  FormComparator
//
//  Created by Takuya on 2014/05/18.
//  Copyright (c) 2014年 Takuya. All rights reserved.
//

#import "FlagClass.h"

@implementation FlagClass

+ (NSDictionary *)getFlagTimeDictionary
{
    NSUserDefaults *storage = [NSUserDefaults standardUserDefaults];
    NSDictionary *flagTimeDic = [storage dictionaryForKey:@"FlagTime"];
    return flagTimeDic;
}

+ (NSString *)getFlagTimeForLabel:(float)flagTime
{
    NSInteger time = flagTime;
    NSString *flgTimeStr = [NSString stringWithFormat:@"%d:%02d", (int)(time / 60), (int)(time % 60)];
    return flgTimeStr;
}

+ (void)updateFlagTime:(float)flagTime forKey:(NSString *)key
{
    NSMutableDictionary *flagTimeDic = [[NSMutableDictionary alloc] init];
    [flagTimeDic setDictionary:[self getFlagTimeDictionary]];
    if (!flagTimeDic) {
        flagTimeDic = [NSMutableDictionary dictionaryWithObjects:@[[NSString stringWithFormat:@"%f",flagTime]] forKeys:@[key]];
    } else {
        [flagTimeDic setObject:[NSString stringWithFormat:@"%f",flagTime] forKey:key];
    }
    [self updateFlagTimeAll:flagTimeDic];
}

+ (void)updateFlagTimeAll:(NSDictionary *)flagTimeDic
{
    NSUserDefaults *storage = [NSUserDefaults standardUserDefaults];
    [storage setObject:nil forKey:@"FlagTime"];
    [storage setObject:flagTimeDic forKey:@"FlagTime"];
    [storage synchronize];
}

@end
