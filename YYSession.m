//
//  YYSession.m
//  iDu
//
//  Created by yancan on 11-12-21.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "YYSession.h"

static YYSession *kSession;

@implementation YYSession

@synthesize item;

+ (void)initialize {
    static BOOL initialized = NO;
    if(!initialized) {
        initialized = YES;
        kSession = [YYSession new];
        kSession.item = [NSMutableDictionary dictionary];
    }
}

+ (YYSession *)session {
    [self initialize];
    return kSession;
}

- (id)objectForKey:(id)aKey {
    return [self.item objectForKey:aKey];
}

- (void)setValue:(id)object forKey:(id)aKey {
    [self.item setValue:object forKey:aKey];
}

- (void)removeObjectForKey:(id)aKey {
    [self.item removeObjectForKey:aKey];
}

@end
