//
//  ZZDatabase.m
//  littleBulb
//
//  Created by yy on 13-4-21.
//
//

#import "ZZDatabase.h"

@implementation ZZDatabase

- (id)init {
    self = [super init];
    if (self != nil) {
        NSString *dbPath = LBPathForDocumentsResource(@"zz.db");
        _db = [FMDatabase databaseWithPath:dbPath];
        if (![_db open]) {
            NSLog(@"Cannot open db.");
        }
    }
    return self;
}

+ (FMDatabase *)defaultDatabase {
    static ZZDatabase *sharedInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance.db;
}

#pragma mark - private
NSString* LBPathForDocumentsResource(NSString* relativePath) {
    static NSString* documentsPath = nil;
    if (nil == documentsPath) {
        NSArray* dirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                            NSUserDomainMask,
                                                            YES);
        documentsPath = [dirs objectAtIndex:0];
    }
    return [documentsPath stringByAppendingPathComponent:relativePath];
}

@end
