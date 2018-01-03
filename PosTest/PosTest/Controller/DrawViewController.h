//
//  DrawViewController.h
//  PosTest
//
//  Created by Macmini on 1/2/18.
//  Copyright © 2018 Santo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Realm/Realm.h>
#import "PMVValue.h"

RLM_ARRAY_TYPE(PMVValue)

@interface DrawViewController : UIViewController
@property RLMArray<PMVValue>* values;
@end
