//
//  MeasurementValueFactory.h
//  LifeFlow
//
//  Created by Macmini on 10/9/17.
//  Copyright © 2017 CULabs. All rights reserved.
//

#import "PMVValue.h"

@interface PMVFactory : NSObject
+ (instancetype)shared;
+ (PMVValue*) newValue: (NSInteger) type time: (NSTimeInterval) time;
@end
