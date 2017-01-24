//
//  LBDevice.m
//  littleBulb
//
//  Created by yy on 13-3-9.
//
//

#import "LBDevice.h"
#import "ZZDatabase.h"
#import "LBLightShield.h"
#import "LBTools.h"

@interface LBDevice ()

@end

@implementation LBDevice

+ (NSString *)nameWithPeripheral:(CBPeripheral *)p {
    return [LBDevice deviceWithPeripheral:p].name;
}

+ (LBDevice *)deviceWithPeripheral:(CBPeripheral *)p {
    static NSMutableDictionary *deviceContainer;
    if (!deviceContainer) {
        deviceContainer = [NSMutableDictionary dictionary];
    }
    
    NSString *key = [p.identifier UUIDString];
    LBDevice *device = [deviceContainer objectForKey:key];
    if (!device) {
        device = [[LBDevice alloc] initWithPeripheral:p];
        [deviceContainer setObject:device forKey:key];
    }
    return device;
}

+ (LBDevice *)deviceWithUUID:(NSString *)uuid {
    LBDevice *device = [[LBDevice alloc] initWithUUID:uuid];
    return device;
}

+ (NSString *)styleNameForStyle:(NSNumber *)style {
    if (style == nil || [style isEqual:[NSNull null]]) {
        return nil;
    }
    NSArray *names = @[@"过道灯", @"床头灯", @"台灯"];
    return [names objectAtIndex:[style intValue]];
}

+ (NSArray *)proximityForStyle:(NSNumber *)style {
    if (style == nil || [style isEqual:[NSNull null]]) {
        return nil;
    }
    
    int styleValue = [style intValue];
    if (styleValue == LBDeviceStyleAisle) {
        return @[@89, @108];
    } else if (styleValue == LBDeviceStyleBedside) {
#warning not for prod env
        return @[@50, @60];
    } else if (styleValue == LBDeviceStyleTable) {
        return @[@77, @88];
    }
    return nil;
}

+ (BOOL)isExistsUUID:(NSString *)uuid {
    FMDatabase *db = [ZZDatabase defaultDatabase];
    FMResultSet *s = [db executeQuery:@"SELECT id FROM devices WHERE uuid = ? LIMIT 1"
                 withArgumentsInArray:@[uuid]];
    while ([s next]) {
        return YES;
    }
    return NO;
}

- (id)initWithUUID:(NSString *)uuidString {
    self = [super init];
    if (self) {
        [self setupTable];
        [self insertDeviceWithUUID:uuidString];
        _uuid = uuidString;
    }
    return self;
}

- (id)initWithPeripheral:(CBPeripheral *)p {
    self = [super init];
    if (self) {
        [self setupTable];
        
        NSString *uuid = [p.identifier UUIDString];
        [self insertDeviceWithUUID:uuid];
        
        _peripheral = p;
        _uuid = uuid;
    }
    return self;
}

- (void)setupTable {
    FMDatabase *db = [ZZDatabase defaultDatabase];
    if (![db tableExists:kDeviceTable]) {
        NSString *sql =
        @"CREATE TABLE devices ("
        @"id INTEGER PRIMARY KEY AUTOINCREMENT,"
        @"uuid TEXT,"
        @"name TEXT,"
        @"style INT,"
        @"group_id INT,"
        @"created DATETIME DEFAULT CURRENT_TIMESTAMP,"
        @"modified DATETIME"
        @")";
        
        [db executeUpdate:sql];
    }
}

- (void)insertDeviceWithUUID:(NSString *)uuidString {
    FMDatabase *db = [ZZDatabase defaultDatabase];
    
    if (![LBDevice isExistsUUID:uuidString]) {
        NSString *sql =
        @"INSERT INTO devices "
        @"(uuid, group_id) "
        @"VALUES (?, ?) ";
        
        [db executeUpdate:sql withArgumentsInArray:@[uuidString, @0]];
    }
}

- (void)setupWithShield:(LBLightShield *)shield {
    _shield = shield;
    if (!_peripheral) {
        return;
    }
    
    _service = [LBTools findServiceFromUUID:[CBUUID UUIDWithString:kBleServiceUUID]
                                 peripheral:_peripheral];
    
    if (_service) {
        _writeChar = [LBTools findCharacteristicFromUUID:[CBUUID UUIDWithString:kBleDimmerUUID]
                                                    service:_service];
        _notiChar = [LBTools findCharacteristicFromUUID:[CBUUID UUIDWithString:kBleNotifyUUID]
                                                    service:_service];
    }
    
}

- (void)setName:(NSString *)name {
    [self setValue:name forKey:@"name"];
}

- (NSString *)name {
    NSString *theName = [self valueForkey:@"name"];
    if ([theName isEqual:[NSNull null]]) {
        return kBleName;
    }
    return theName;
}

- (void)setGroupId:(NSNumber *)groupId {
    [self setValue:groupId forKey:@"group_id"];
}

- (NSNumber *)groupId {
    return [self valueForkey:@"group_id"];
}

- (void)setStyle:(NSNumber *)style {
    [self setValue:style forKey:@"style"];
}

- (NSNumber *)style {
    return [self valueForkey:@"style"];
}

- (void)setValue:(id)value forKey:(NSString *)key {
    FMDatabase *db = [ZZDatabase defaultDatabase];
    NSString *sql = [NSString stringWithFormat:
                     @"update devices set %@ = ? where uuid = ?", key];
    [db executeUpdate:sql withArgumentsInArray:@[value, _uuid]];
}

- (id)valueForkey:(NSString *)key {
    FMDatabase *db = [ZZDatabase defaultDatabase];
    NSString *sql = [NSString stringWithFormat:
                     @"select %@ from devices where uuid = ?", key];
    FMResultSet *s = [db executeQuery:sql withArgumentsInArray:@[_uuid]];
    id res = nil;
    if ([s next]) {
        res = [s objectForColumnIndex:0];
    }
    return res;
}

#pragma mark - BLE

- (BOOL)isConnected {
    return _peripheral && _peripheral.state == CBPeripheralStateConnected;
}

- (void)turnOff {
    [self changeBrightness:1 completion:nil];
    [self changeBrightness:0 completion:nil];
}

- (void)turnOn {
    dispatch_source_t clock = dispatch_source_create(
                                        DISPATCH_SOURCE_TYPE_TIMER,
                                        0, 0,
                                        dispatch_get_main_queue()
                                        );
    
    __block int i = 5;
    int step = 8;
    dispatch_source_set_event_handler(clock, ^{
        if (i > 255) {
            dispatch_source_cancel(clock);
            return;
        }
        [self changeBrightness:i completion:nil];
        i += step;
    });
    dispatch_resume(clock);
    
    dispatch_source_set_timer(clock,
                              DISPATCH_TIME_NOW,
                              1ull * NSEC_PER_SEC / 1000,
                              1ull * NSEC_PER_SEC / 15);
}

- (void)changeBrightness:(NSInteger)brightness
              completion:(LBShieldCompletionBlock)completion {
    
    uint8_t *bits = (uint8_t *)malloc(6 * sizeof(uint8_t));
    bits[0] = kSyncByte;
    bits[1] = brightness;
    bits[2] = 1;
    bits[3] = 1;
    bits[4] = 1;
    bits[5] = bits[1] ^ bits[2] ^ bits[3] ^ bits[4];
    
    NSData *data = [NSData dataWithBytes:bits length:6];
    NSLog(@"write data to characterlistic uuid: %@, name:%@, state: %d,data %@", _writeChar.UUID, _peripheral.name, _peripheral.state,data);
    [self writeData:data forCharacteristic:_writeChar completion:completion];
}

- (void)writeData:(NSData *)data
forCharacteristic:(CBCharacteristic *)characteristic
       completion:(LBShieldCompletionBlock)completion {
    
    [_shield peripheral:_peripheral
              writeData:data
      forCharacteristic:characteristic
             completion:completion];
}

@end
