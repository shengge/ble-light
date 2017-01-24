//
//  LBGroupRow.h
//  littleBulb
//
//  Created by yy on 13-4-24.
//
//

#import <Foundation/Foundation.h>
#import "LBLightShield.h"

@class LBDevice;

@interface LBGroup: NSObject

@property (strong, nonatomic) NSNumber *identifier;
@property (copy, nonatomic) NSString *name;
@property (strong, nonatomic) NSNumber *deviceNumber;
@property (strong, nonatomic) NSArray *devices;
@property (weak, nonatomic) LBLightShield *sensor;

- (id)initWithName:(NSString *)name;
- (void)addDevice:(LBDevice *)device;
- (void)removeDevice:(LBDevice *)device;

- (void)turnOn;
- (void)turnOff;
- (void)changeBrightness:(NSInteger)brightness
              completion:(LBShieldCompletionBlock)completion;

+ (LBGroup *)groupWithName:(NSString *)name;
+ (NSArray *)devicesWithoutGroup;

@end
