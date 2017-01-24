//
//  LBGroup.m
//  littleBulb
//
//  Created by yy on 13-4-20.
//
//

#import "LBGroupList.h"
#import "LBGroup.h"
#import "ZZDatabase.h"

@interface LBGroupList ()
@end

@implementation LBGroupList

- (id)init {
    self = [super init];
    if (self) {
        [LBGroupList setupTable];
    }
    return self;
}

- (id)initWithSensor:(LBLightShield *)sensor {
    self = [self init];
    if (self) {
        _sensor = sensor;
    }
    return self;
}

+ (void)setupTable {
    FMDatabase *db = [ZZDatabase defaultDatabase];
    if (![db tableExists:kGroupTable]) {
        NSString *sql =
        @"CREATE TABLE groups ("
        @"id INTEGER PRIMARY KEY AUTOINCREMENT,"
        @"name TEXT,"
        @"device_number INT,"
        @"created DATETIME DEFAULT CURRENT_TIMESTAMP,"
        @"modified DATETIME,"
        @"UNIQUE (name)"
        @")";
        
        [db executeUpdate:sql];
    }
}

- (NSArray *)allGroups {
    FMDatabase *db = [ZZDatabase defaultDatabase];
    FMResultSet *s = [db executeQuery:@"SELECT * FROM groups ORDER BY id DESC"];
    NSMutableArray *res = [NSMutableArray array];
    while ([s next]) {
        NSDictionary *row = @{
                              @"id"             : [s objectForColumnName:@"id"],
                              @"name"           : [s objectForColumnName:@"name"],
                              @"device_number"  : [s objectForColumnName:@"device_number"],
                              @"created"        : [s objectForColumnName:@"created"],
                              @"modified"       : [s objectForColumnName:@"modified"]
                              };
        LBGroup *group = [LBGroup groupWithName:row[@"name"]];
        group.sensor = _sensor;
        [res addObject:group];
    }
    return res;
}

- (void)deleteGroup:(LBGroup *)group
{
    [group.devices enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [group removeDevice:obj];
    }];
    FMDatabase *db = [ZZDatabase defaultDatabase];
    [db executeUpdate:@"DELETE FROM groups WHERE name = ?" withArgumentsInArray:@[group.name]];
}

+ (BOOL)isExistsName:(NSString *)name {
    FMDatabase *db = [ZZDatabase defaultDatabase];
    FMResultSet *s = [db executeQuery:@"SELECT id FROM groups WHERE name = ? LIMIT 1"
                 withArgumentsInArray:@[name]];
    while ([s next]) {
        return YES;
    }
    return NO;
}

@end
