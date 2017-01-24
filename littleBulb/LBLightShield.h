//
//  LBLightShield.h
//  littleBulb
//
//  Created by yy on 13-5-4.
//
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "LBDefine.h"

@class LBDevice;

typedef void (^LBShieldCompletionBlock)(id response, NSError *error);

@interface LBLightShield : NSObject<CBCentralManagerDelegate, CBPeripheralDelegate>

@property (strong, nonatomic) CBCentralManager *manager;

@property (nonatomic, strong) NSMutableArray *peripherals;
@property (strong, nonatomic) NSMutableArray *activePeripherals;

#pragma mark - Methods for controlling the BlueShield

- (int)findPeripherals:(NSInteger)timeout completion:(LBShieldCompletionBlock)completion;
- (void)addSavedDevice:(NSString *)uuid;
- (void)removeSavedDevice:(NSString *)uuid;
- (CBPeripheral *)peripheralForUUID:(NSString *)uuidString;

- (void)connect:(CBPeripheral *)peripheral;
- (void)disconnect:(CBPeripheral *)peripheral;
- (BOOL)isActived:(CBPeripheral *)peripheral;

- (void)peripheral:(CBPeripheral *)peripheral
         writeData:(NSData *)data
 forCharacteristic:(CBCharacteristic *)characteristic
        completion:(LBShieldCompletionBlock)completion;

@end
