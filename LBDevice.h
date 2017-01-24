//
//  LBDevice.h
//  littleBulb
//
//  Created by yy on 13-3-9.
//
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "LBLightShield.h"

typedef NS_ENUM(NSInteger, LBDeviceStyle) {
    LBDeviceStyleAisle,
    LBDeviceStyleBedside,
    LBDeviceStyleTable,
};

@interface LBDevice : NSObject 

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *uuid;
@property (nonatomic, strong) NSNumber *style;
@property (nonatomic, strong) NSNumber *groupId;
@property (nonatomic, weak) LBLightShield *shield;

@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic, strong) CBService *service;
@property (nonatomic, strong) CBCharacteristic *writeChar;
@property (nonatomic, strong) CBCharacteristic *notiChar;

+ (LBDevice *)deviceWithPeripheral:(CBPeripheral *)p;
+ (LBDevice *)deviceWithUUID:(NSString *)uuidString;
+ (NSString *)nameWithPeripheral:(CBPeripheral *)p;
+ (NSString *)styleNameForStyle:(NSNumber *)style;
+ (NSArray *)proximityForStyle:(NSNumber *)style;
+ (BOOL)isExistsUUID:(NSString *)uuid;

- (id)initWithPeripheral:(CBPeripheral *)p;
- (id)initWithUUID:(NSString *)uuidString;

- (void)setupWithShield:(LBLightShield *)shield;
- (void)turnOn;
- (void)turnOff;
- (void)changeBrightness:(NSInteger)brightness
              completion:(LBShieldCompletionBlock)completion;
- (BOOL)isConnected;

- (void)writeData:(NSData *)data
forCharacteristic:(CBCharacteristic *)characteristic
       completion:(LBShieldCompletionBlock)completion;

@end
