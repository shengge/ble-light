//
//  LBSelectDeviceViewController.h
//  littleBulb
//
//  Created by yy on 13-4-30.
//
//

#import <UIKit/UIKit.h>

@class LBGroupDeviceViewController;

@interface LBSelectDeviceViewController : UITableViewController

@property (strong, nonatomic) NSArray *devices;
@property (weak, nonatomic) LBGroupDeviceViewController *delegate;

- (IBAction)doneClicked:(id)sender;

@end
