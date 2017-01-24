//
//  BLEDeviceViewController.h
//  HelloBTSmart
//
//  Created by BTSmartShield on 7/13/12.
//  Copyright (c) 2012 BTSmartShield.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LBLightShield.h"

#define RSSI_THRESHOLD  -60
#define WARNING_MESSAGE @"z"

@class CBPeripheral;
@class LBDevice;

@interface BLEDeviceViewController : UIViewController<UITextFieldDelegate, UIAlertViewDelegate, UIActionSheetDelegate>

@property (strong, nonatomic) LBLightShield *sensor;
@property (strong, nonatomic) LBDevice *device;
@property (nonatomic) NSInteger brightValue;
@property (nonatomic) NSInteger lastBrightValue;
@property (strong, nonatomic) NSDate *lastWriteTime;
@property (nonatomic) BOOL powerOn;

@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UIView *gestureView;

- (IBAction)renameClicked:(id)sender;
- (IBAction)styleClicked:(id)sender;

@end
