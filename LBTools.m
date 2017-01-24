//
//  LBTools.m
//  littleBulb
//
//  Created by liaojinhua on 14-5-21.
//
//

#import "LBTools.h"

@implementation LBTools

+ (NSString *)stringWithUUID:(CFUUIDRef)uuid
{
    CFStringRef string = CFUUIDCreateString(NULL, uuid);
    return (__bridge_transfer NSString *)string;
}
+ (CBService *)findServiceFromUUID:(CBUUID *)UUID
                        peripheral:(CBPeripheral *)peripheral
{
    NSLog(@"the services count is %d\n", peripheral.services.count);
    for (CBService *s in peripheral.services) {
        if ([[s.UUID data] isEqualToData:[UUID data]]) {
            return s;
        }
    }
    return  nil;
}
+ (CBCharacteristic *)findCharacteristicFromUUID:(CBUUID *)UUID
                                         service:(CBService *)service
{
    for (CBCharacteristic *c in service.characteristics) {
        if ([[c.UUID data] isEqualToData:[UUID data]]) {
            return c;
        }
    }
    return nil;
}

@end
