//
//  FlagClass.h
//  FormComparator
//
//  Created by Takuya on 2014/05/18.
//  Copyright (c) 2014年 Takuya. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FlagClass : NSObject

+ (NSDictionary *)getFlagTimeDictionary;
+ (NSString *)getFlagTimeForLabel:(float)flagTime;
+ (void)updateFlagTime:(float)flagTime forKey:(NSString *)key;
+ (void)updateFlagTimeAll:(NSDictionary *)flagTimeDic;

@end
