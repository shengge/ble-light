//
//  LBSelectDeviceViewController.m
//  littleBulb
//
//  Created by yy on 13-4-30.
//
//

#import "LBSelectDeviceViewController.h"
#import "LBDevice.h"
#import "LBGroup.h"
#import "LBGroupDeviceViewController.h"

@interface LBSelectDeviceViewController ()

@end

@implementation LBSelectDeviceViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _devices = [LBGroup devicesWithoutGroup];
    self.tableView.allowsMultipleSelection = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_devices count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"selectDeviceCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    LBDevice *device = [_devices objectAtIndex:indexPath.row];
    cell.textLabel.text = device.name;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *thisCell = [tableView cellForRowAtIndexPath:indexPath];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    thisCell.accessoryType = thisCell.accessoryType == UITableViewCellAccessoryNone ?
    UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
}

#pragma mark - IBAction

- (IBAction)doneClicked:(id)sender {
    int cnt = [_devices count];
    NSMutableArray *objects = [NSMutableArray array];
    for (int i = 0; i < cnt; i++) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:
                                 [NSIndexPath indexPathForRow:i inSection:0]];
        
        if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
            LBDevice *device = [_devices objectAtIndex:i];
            [objects addObject:device];
        }
        
    }
    if(![_delegate addDevices:objects]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"一个分组最多可以包含10个设备" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
    } else {
        [_delegate dismissSelectViewController];
    }
}

@end
