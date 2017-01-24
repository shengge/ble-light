//
//  LBGroup.h
//  littleBulb
//
//  Created by yy on 13-4-20.
//
//

#import <Foundation/Foundation.h>
#import "LBLightShield.h"

@class LBGroup;

@interface LBGroupList : NSObject

@property (weak, nonatomic) LBLightShield *sensor;

- (id)initWithSensor:(LBLightShield *)sensor;
- (NSArray *)allGroups;
- (void)deleteGroup:(LBGroup *)group;

+ (BOOL)isExistsName:(NSString *)name;
+ (void)setupTable;

@end
