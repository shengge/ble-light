//
//  LBViewController.h
//  littleBulb
//
//  Created by yy on 13-4-20.
//
//

#import <UIKit/UIKit.h>
#import "LBGroupCell.h"
#import "LBLightShield.h"

@class LBGroupList;

@interface LBGroupListViewController : UITableViewController <UIAlertViewDelegate, UITextFieldDelegate>

@property (strong, nonatomic) LBGroupList *groupList;
@property (strong, nonatomic) NSArray *allGroups;

- (IBAction)addClicked:(id)sender;

@end
