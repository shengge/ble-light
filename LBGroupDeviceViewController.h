//
//  LBGroupDeviceViewController.h
//  littleBulb
//
//  Created by yy on 13-4-28.
//
//

#import <UIKit/UIKit.h>

@class LBGroup;

@interface LBGroupDeviceViewController : UITableViewController

@property (strong, nonatomic) IBOutlet UIBarButtonItem *addButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *switchButton;
@property (strong, nonatomic) LBGroup *group;

- (void)dismissSelectViewController;
- (BOOL)addDevices:(NSArray *)objects;
    
- (IBAction)addClicked:(id)sender;

@end
