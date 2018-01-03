#import "PMVValue.h"

#define INVALID_NUM 0

@implementation PMVValue
- (void) addNumber: (double) number {
    RLMNumber* num = [RLMNumber new];
    num.value = number;
    [self.numbers addObject: num];
}

- (double) numberAt:(int) index {
    if (self.numbers.count <= index) {
        return INVALID_NUM;
    }
    
    RLMNumber* num = [self.numbers objectAtIndex: index];
    return num.value;
}

- (double) number {
    return [self numberAt: 0];
}

- (void) log {
#ifdef BLE_LOG_ENABLED
    if (self.type == Motion) {
        NSLog(@"Type - %d, Value - (%d, %d, %d)", (int)self.type, (int)[self numberAt: 0], (int)[self numberAt: 0], (int)[self numberAt: 0]);
    }
    else {
        NSLog(@"Type - %d, Value - %.2f", (int)self.type, [self number]);
    }
#endif
}
@end
