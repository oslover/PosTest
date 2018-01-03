#import <Foundation/Foundation.h>
#import "RLMNumber.h"

RLM_ARRAY_TYPE(RLMNumber)

typedef NS_ENUM(NSInteger, SensorType) {
    Counter = 1,
    Motion,
    HeartRate,
    Temporature,
    Humidity,
    UV,
    Battery
};

@interface PMVValue : RLMObject

@property NSInteger type;
@property NSTimeInterval timestamp;
@property RLMArray<RLMNumber>* numbers;

- (void) addNumber: (double) number;
- (double) numberAt:(int) index;
- (double) number;
- (void) log;
@end
