//
//  LBGroupRow.m
//  littleBulb
//
//  Created by yy on 13-4-24.
//
//

#import "LBGroup.h"
#import "LBDevice.h"
#import "LBGroupList.h"
#import "LBDefine.h"
#import "ZZDatabase.h"

@implementation LBGroup

- (id)initWithName:(NSString *)name {
    self = [super init];
    if (self) {
        _name = name;
        FMDatabase *db = [ZZDatabase defaultDatabase];
        [LBGroupList setupTable];
        
        if (![LBGroupList isExistsName:name]) {
            NSString *sql =
            @"INSERT INTO groups "
            @"(name, device_number) "
            @"VALUES (?, ?) ";
            
            [db executeUpdate:sql withArgumentsInArray:@[name, @0]];
            _identifier = [NSNumber numberWithLongLong:[db lastInsertRowId]];
        }
    }
    return self;
}

- (void)addDevice:(LBDevice *)device {
    device.groupId = self.identifier;
}

- (void)removeDevice:(LBDevice *)device {
    device.groupId = @0;
}

- (NSArray *)devices {
    FMDatabase *db = [ZZDatabase defaultDatabase];
    FMResultSet *s = [db executeQuery:@"SELECT * FROM devices where group_id = ? ORDER BY id DESC"
                 withArgumentsInArray:@[self.identifier]];
    NSMutableArray *res = [NSMutableArray array];
    while ([s next]) {
        NSString *uuid = [s objectForColumnName:@"uuid"];
        CBPeripheral *p = [_sensor peripheralForUUID:uuid];
        if (p) {
            LBDevice *device = [LBDevice deviceWithPeripheral:p];
            device.shield = _sensor;
            [res addObject:device];
        }
    }
    return res;
}

- (NSNumber *)identifier {
    if (_identifier == nil) {
        FMDatabase *db = [ZZDatabase defaultDatabase];
        FMResultSet *s = [db executeQuery:@"SELECT id FROM groups WHERE name = ? LIMIT 1"
                     withArgumentsInArray:@[_name]];
        while ([s next]) {
            _identifier = [s objectForColumnIndex:0];
        }
    }
    return _identifier;
}

- (void)turnOn {
    for (LBDevice *device in self.devices) {
        [device turnOn];
    }
}

- (void)turnOff {
    for (LBDevice *device in self.devices) {
        [device turnOff];
    }
}

- (void)changeBrightness:(NSInteger)brightness
              completion:(LBShieldCompletionBlock)completion {
    for (LBDevice *device in self.devices) {
        [device changeBrightness:brightness completion:completion];
    }
}

+ (LBGroup *)groupWithName:(NSString *)name {
    return [[LBGroup alloc] initWithName:name];
}

+ (NSArray *)devicesWithoutGroup {
    FMDatabase *db = [ZZDatabase defaultDatabase];
    FMResultSet *s = [db executeQuery:@"SELECT * FROM devices where group_id = 0 ORDER BY id DESC"];
    NSMutableArray *res = [NSMutableArray array];
    while ([s next]) {
        NSString *uuid = [s objectForColumnName:@"uuid"];
        LBDevice *device = [[LBDevice alloc] initWithUUID:uuid];
        [res addObject:device];
    }
    return res;
}

@end
