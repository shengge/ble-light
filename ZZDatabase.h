//
//  ZZDatabase.h
//  littleBulb
//
//  Created by yy on 13-4-21.
//
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"

@interface ZZDatabase : NSObject

@property (strong, nonatomic) FMDatabase *db;

+ (FMDatabase *)defaultDatabase;

@end
