//
//  BLESimulator.h
//  LifeFlow
//
//  Created by Macmini on 10/9/17.
//  Copyright © 2017 CULabs. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PMVValue;

@protocol BLESimulatorDelegate
- (void) bleSimulatorConnected;
- (void) valueReceived: (PMVValue*) value;
- (void) bleSimulatorDisconnected;
- (void) timeUpdated: (NSTimeInterval) currentTimeInSecs;
@end

@interface BLESimulator : NSObject
+ (instancetype)shared;

@property (nonatomic, strong) NSTimer* timer;
@property (nonatomic, strong) id<BLESimulatorDelegate> delegate;
@property (nonatomic, assign) BOOL isCapturing;

- (void) startSimulation;
- (void) endSimulation;
@end

