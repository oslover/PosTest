//
//  BLESimulator.m
//  LifeFlow
//
//  Created by Macmini on 10/9/17.
//  Copyright © 2017 CULabs. All rights reserved.
//

#import "BLESimulator.h"
#import "PMVFactory.h"

@interface BLESimulator () {
    int timeInMiliSeconds;
    NSTimeInterval currentTime;
    
    int randomTimeForCounter;
}
@end

@implementation BLESimulator

+ (instancetype)shared {
    static BLESimulator *instance = nil;
    static dispatch_once_t predicate;
    
    dispatch_once(&predicate, ^{
        instance = [[BLESimulator alloc] init];
    });
    
    return instance;
}

- (void) startSimulation {
    if (_timer != nil) {
        [_timer invalidate];
    }
    
    if (self.delegate != nil) {
        [self.delegate bleSimulatorConnected];
    }
    
    timeInMiliSeconds = 0;
    randomTimeForCounter = 3;
    currentTime = 0;
    self.timer = [NSTimer scheduledTimerWithTimeInterval: 0.1f
                                              target: self
                                            selector: @selector(onUpdate:)
                                            userInfo: nil
                                             repeats: YES];
}

- (void) onUpdate :(NSTimer *)timer {
    if (self.delegate == nil) {
        return;
    }
    
    timeInMiliSeconds += 1;
    currentTime = [[NSDate date] timeIntervalSince1970];
    [self.delegate timeUpdated: currentTime];
    PMVValue* value = nil;
    
    if (timeInMiliSeconds % 2 == 0) { //200 ms
        value = [PMVFactory newValue: Motion time: currentTime];
        [self.delegate valueReceived: value];
    }
    if (timeInMiliSeconds % randomTimeForCounter == 0) { // 300 ms
        value = [PMVFactory newValue: Counter time: currentTime];
        randomTimeForCounter = arc4random_uniform(50) + 1;
        [self.delegate valueReceived: value];
    }
    if (timeInMiliSeconds % 5 == 0) { // 500 ms
        value = [PMVFactory newValue: HeartRate time: currentTime];
        [self.delegate valueReceived: value];
    }
    if (timeInMiliSeconds % 10 == 0) { // 1 sec
        value = [PMVFactory newValue: Humidity time: currentTime];
        [self.delegate valueReceived: value];
        value = [PMVFactory newValue: Temporature time: currentTime];
        [self.delegate valueReceived: value];
        value = [PMVFactory newValue: UV time: currentTime];
        [self.delegate valueReceived: value];
        value = [PMVFactory newValue: Battery time: currentTime];
        [self.delegate valueReceived: value];
    }
}

- (void) endSimulation {
    if (_timer != nil) {
        [_timer invalidate];
    }
    timeInMiliSeconds = 0;
    currentTime = 0;
    if (self.delegate != nil) {
        [self.delegate bleSimulatorDisconnected];
    }
}

@end
