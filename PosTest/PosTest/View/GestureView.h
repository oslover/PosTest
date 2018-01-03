//
//  GestureView.h
//  PosTest
//
//  Created by Macmini on 1/2/18.
//  Copyright © 2018 Santo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PMVValue.h"

RLM_ARRAY_TYPE(PMVValue)

IB_DESIGNABLE
@interface GestureView : UIView
@property RLMArray<PMVValue>* values;
@property (nonatomic, strong) NSTimer* timer;
@property (nonatomic, assign) BOOL playing;
@property (nonatomic, assign) NSTimeInterval currentTime;

- (void) start;
- (void) stop;
- (void) draw;
- (void) clear;
@end
