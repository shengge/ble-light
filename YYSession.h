//
//  YYSession.h
//  iDu
//
//  Created by yancan on 11-12-21.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YYSession : NSObject

@property (nonatomic, strong) NSMutableDictionary *item;

+ (void)initialize;
+ (YYSession *)session;
- (id)objectForKey:(id)aKey;
- (void)setValue:(id)object forKey:(id)aKey;
- (void)removeObjectForKey:(id)aKey;

@end
