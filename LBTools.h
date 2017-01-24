//
//  LBTools.h
//  littleBulb
//
//  Created by liaojinhua on 14-5-21.
//
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface LBTools : NSObject

+ (NSString *)stringWithUUID:(CFUUIDRef)uuid;
+ (CBService *)findServiceFromUUID:(CBUUID *)UUID
                        peripheral:(CBPeripheral *)peripheral;
+ (CBCharacteristic *)findCharacteristicFromUUID:(CBUUID *)UUID
                                         service:(CBService *)service;

@end
