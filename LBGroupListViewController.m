//
//  LBViewController.m
//  littleBulb
//
//  Created by yy on 13-4-20.
//
//

#import "LBGroupListViewController.h"
#import "LBGroup.h"
#import "LBGroupList.h"
#import "LBGroupDeviceViewController.h"
#import "YYSession.h"

@interface LBGroupListViewController ()

@end

@implementation LBGroupListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    LBLightShield *sensor = [[YYSession session] objectForKey:kSensorKey];
    _groupList = [[LBGroupList alloc] initWithSensor:sensor];
    _allGroups = [_groupList allGroups];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"groupDeviceSegue"]) {
        LBGroupDeviceViewController *ctrl = (LBGroupDeviceViewController *)segue.destinationViewController;
        ctrl.group = sender;
    }
}

#pragma mark - custom method

- (void)switchToggled:(id)sender {
    UISwitch *s = sender;
    LBGroupCell *cell = (LBGroupCell *)s.superview.superview;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    LBGroup *group = [_allGroups objectAtIndex:indexPath.row];
    if (s.on) {
        [group turnOn];
    } else {
        [group turnOff];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_allGroups count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"groupCell";
    LBGroupCell *cell = (LBGroupCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier
                                                                       forIndexPath:indexPath];
    
    LBGroup *group = [_allGroups objectAtIndex:indexPath.row];
    cell.titleLabel.text = group.name;
    [cell.cellSwitch addTarget:self
                        action:@selector(switchToggled:)
              forControlEvents:UIControlEventValueChanged];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [_groupList deleteGroup:[_allGroups objectAtIndex:indexPath.row]];
        _allGroups = [_groupList allGroups];
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [tableView endUpdates];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LBGroup *group = [_allGroups objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"groupDeviceSegue" sender:group];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == alertView.cancelButtonIndex) {
        return;
    }
   
    UITextField *textField = [alertView textFieldAtIndex:0];
    if (![textField.text length]) {
        return;
    }
    
    [LBGroup groupWithName:textField.text];
    _allGroups = [_groupList allGroups];
    [self.tableView reloadData];
}

#pragma mark - IBAction

- (IBAction)addClicked:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Add a group"
                                                    message:nil
                                                   delegate:self
                                          cancelButtonTitle:@"取消"
                                          otherButtonTitles:@"确定", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *textField = [alert textFieldAtIndex:0];
    textField.placeholder = @"Group's name";
    textField.delegate = self;
    [alert show];
}

@end
