//
//  MeasurementValueFactory.m
//  LifeFlow
//
//  Created by Macmini on 10/9/17.
//  Copyright © 2017 CULabs. All rights reserved.
//

#import "PMVFactory.h"

@interface PMVFactory ()

@end
@implementation PMVFactory

+ (instancetype)shared {
    static PMVFactory *instance = nil;
    static dispatch_once_t predicate;
    
    dispatch_once(&predicate, ^{
        instance = [[PMVFactory alloc] init];
    });
    
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

+ (int) randomNumberBetween:(int)min maxNumber:(int)max {
    return min + arc4random_uniform(max - min + 1);
}

+ (PMVValue*) newValue: (NSInteger) type time: (NSTimeInterval) time {
    PMVValue* value = [PMVValue new];
    value.type = type;
    value.timestamp = time;
    
    switch (type) {
        case Counter:
            [value addNumber: 1];
            break;
        case Motion:
            [value addNumber: [self randomNumberBetween:-1024 maxNumber: 512]]; //x
            [value addNumber: [self randomNumberBetween:-1024 maxNumber: 512]]; //y
            [value addNumber: [self randomNumberBetween:-512 maxNumber: 512]]; //z
            break;
        case HeartRate:
            [value addNumber: [self randomNumberBetween: 0 maxNumber: 255]];
            break;
        case Temporature:
            [value addNumber: [self randomNumberBetween: -128 maxNumber: 127]];
            break;
        case Humidity:
            [value addNumber: [self randomNumberBetween: 0 maxNumber: 100]];
            break;
        case UV:
            [value addNumber: [self randomNumberBetween: 0 maxNumber: 11]];
            break;
        case Battery:
            [value addNumber: [self randomNumberBetween: 0 maxNumber: 5]];
            break;
        default:
            break;
    }
    return value;
}
@end
