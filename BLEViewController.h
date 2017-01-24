//
//  BLEViewController.h
//  HelloBTSmart
//
//  Created by BTSmartShield on 7/13/12.
//  Copyright (c) 2012 BTSmartShield.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LBLightShield.h"

@class BLEDeviceViewController;
@class LBDevice;

@interface BLEViewController : UITableViewController 

@property (strong, nonatomic) LBLightShield *sensor;
@property (nonatomic, strong) NSMutableArray *peripherals;

- (void)scanShields:(id)sender;

@end
