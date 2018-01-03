//
//  DrawViewController.m
//  PosTest
//
//  Created by Macmini on 1/2/18.
//  Copyright © 2018 Santo. All rights reserved.
//

#import "DrawViewController.h"
#import "BLESimulator.h"
#import "GestureView.h"

@interface DrawViewController () <BLESimulatorDelegate>
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activity;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *buttonRecordStop;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *buttonPlay;
@property (weak, nonatomic) IBOutlet GestureView *vwGesture;

@property (nonatomic, assign) BOOL recording;
@end

@implementation DrawViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _buttonPlay.enabled = NO;
    [_activity stopAnimating];
    _recording = NO;
    [BLESimulator shared].delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)onPlay:(UIBarButtonItem*)sender {
    if (_vwGesture.playing) {
        [_vwGesture stop];
    }
    else {
        _vwGesture.values = self.values;
        [_vwGesture start];
    }
}

- (IBAction)onRecord:(UIBarButtonItem*)sender {
    [_vwGesture clear];

    if (_recording == NO) {
        if (self.values == nil) {
            self.values = [[RLMArray<PMVValue> alloc] initWithObjectClassName: [PMVValue className]];
        }
        else {
            [self.values removeAllObjects];
        }
        [_activity startAnimating];
        [sender setTitle: @"Stop"];
        _recording = YES;
        [[BLESimulator shared] startSimulation];
        _buttonPlay.enabled = NO;
    }
    else {
        _recording = NO;
        [sender setTitle: @"Recording"];
        _buttonPlay.enabled = YES;
        [_activity stopAnimating];
        [[BLESimulator shared] endSimulation];
    }
}

- (void)bleSimulatorConnected {
    
}

- (void)bleSimulatorDisconnected {
    
}

- (void)timeUpdated:(NSTimeInterval)currentTimeInSecs {
    
}

- (void)valueReceived:(PMVValue *)value {
    if (value.type == Motion) {
        [self.values addObject: value];
    }
}

@end
