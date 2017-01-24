//
//  LBGroupDeviceViewController.m
//  littleBulb
//
//  Created by yy on 13-4-28.
//
//

#import "LBGroupDeviceViewController.h"
#import "LBGroup.h"
#import "LBSelectDeviceViewController.h"
#import "LBDevice.h"

@interface LBGroupDeviceViewController ()

@end

@implementation LBGroupDeviceViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItems = @[_switchButton, _addButton];
    
}

- (void)viewDidUnload {
    [self setAddButton:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    for (LBDevice *device in _group.devices) {
        [_group.sensor connect:device.peripheral];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    for (LBDevice *device in _group.devices) {
        [_group.sensor disconnect:device.peripheral];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"selectDeviceSegue"]) {
        UINavigationController *nav =
        (UINavigationController *)segue.destinationViewController;
        LBSelectDeviceViewController *ctrl =
        (LBSelectDeviceViewController *)[nav.viewControllers objectAtIndex:0];
        ctrl.delegate = self;
    }
}

- (IBAction)switchToggled:(UISwitch *)sender {
    if (sender.on) {
        [_group turnOn];
    } else {
        [_group turnOff];
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_group.devices count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"groupDeviceCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier
                                                            forIndexPath:indexPath];
    
    LBDevice *device = [_group.devices objectAtIndex:indexPath.row];
    cell.textLabel.text = device.name;
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        LBDevice *device = [_group.devices objectAtIndex:indexPath.row];
        [_group removeDevice:device];
        [tableView deleteRowsAtIndexPaths:@[indexPath]
                         withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - custom method

- (void)dismissSelectViewController {
    [self dismissViewControllerAnimated:YES completion:^{
        [self.tableView reloadData];
    }];
}

- (BOOL)addDevices:(NSArray *)objects {
    if (objects.count + _group.devices.count > 10) {
        return NO;
    }
    for (LBDevice *device in objects) {
        [_group addDevice:device];
    }
    return YES;
}

#pragma mark - IBAction

- (IBAction)addClicked:(id)sender {
    [self performSegueWithIdentifier:@"selectDeviceSegue" sender:nil];
}

@end
