//
//  BLEViewController.m
//  HelloBTSmart
//
//  Created by BTSmartShield on 7/13/12.
//  Copyright (c) 2012 BTSmartShield.com. All rights reserved.
//

#import "BLEViewController.h"
#import "BLEDeviceViewController.h"
#import "LBDefine.h"
#import "LBDevice.h"
#import <CoreMotion/CoreMotion.h>
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>
#import "YYSession.h"

@interface BLEViewController ()

@property (nonatomic, strong) CMMotionManager *motionManger;

@end

@implementation BLEViewController

#pragma mark - lifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSUserDefaults standardUserDefaults] setBool:YES
                                            forKey:kAutomaticalllyReconnect];
    
    _sensor = [[LBLightShield alloc] init];
    [[YYSession session] setValue:_sensor forKey:kSensorKey];
    
    _peripherals = [NSMutableArray array];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidActived)
                                                 name:kNotiAppActived
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appEnterBackground)
                                                 name:kNotiAppBackground
                                               object:nil];
    
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self
                       action:@selector(dropViewDidBeginRefreshing:)
             forControlEvents:UIControlEventValueChanged];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self scanShields:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"deviceSegue"]) {
        CBPeripheral *peripheral = sender;
        [_sensor connect:peripheral];
        BLEDeviceViewController *dst = (BLEDeviceViewController *)segue.destinationViewController;
        LBDevice *device = [LBDevice deviceWithPeripheral:peripheral];
        dst.device = device;
        dst.sensor = _sensor;
    }
}

#pragma mark - custom method

- (void)appDidActived {
//    [[BluetoothLEManager sharedManager] discoverDevices];
}

- (void)appEnterBackground {
//    [[BluetoothLEManager sharedManager] stopScanning];
//    UILocalNotification *notification=[[UILocalNotification alloc] init];
//    if (notification != nil) {
//        NSLog(@">> support local notification");
//        NSDate *now= [NSDate new];
//        notification.fireDate= [now addTimeInterval:10];
//        notification.timeZone= [NSTimeZone defaultTimeZone];
//        notification.alertBody= @"该去吃晚饭了！";
//        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
//    }
    
}

- (void)scanShields:(id)sender {
    [_sensor findPeripherals:5 completion:^(id response, NSError *error) {
        [_peripherals removeAllObjects];
        [_peripherals addObjectsFromArray:_sensor.peripherals];
        [self.tableView reloadData];
    }];
}

- (void)didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    [self.tableView reloadData];
}

- (void)peripheral:(CBPeripheral *)peripheral
    didWriteValueForCharacteristic:(CBCharacteristic *)characteristic
    error:(NSError *)error {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotiPeripheralWrited
                                                        object:peripheral];
}

- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral {
    
    double averageRSSI = [peripheral.RSSI doubleValue];
    double pathLoss = 0 - averageRSSI;
    
    NSLog(@"pathLoss %f", pathLoss);
    
    LBDevice *device = [LBDevice deviceWithPeripheral:peripheral];
    NSArray *proximity = [LBDevice proximityForStyle:device.style];
    NSInteger on = [[proximity objectAtIndex:0] intValue];
    NSInteger off = [[proximity objectAtIndex:1] intValue];
    
    if (pathLoss < on) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotiPeripheralAround
                                                            object:peripheral];
    }
    
    if (pathLoss > off) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotiPeripheralLost
                                                            object:peripheral];
    }
}

#pragma mark - IBAction

#pragma mark - UITableViewDelegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_peripherals count];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CBPeripheral *peripheral = [_peripherals objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"deviceSegue" sender:peripheral];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"peripheralCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellId];
    }
    
    // Configure the cell
    CBPeripheral *peripheral = [_peripherals objectAtIndex:indexPath.row];
    NSString *name = [LBDevice nameWithPeripheral:peripheral];
    
    cell.textLabel.text = name;
    cell.detailTextLabel.text = [peripheral.RSSI stringValue];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    cell.imageView.image = [UIImage imageNamed:@"littleBulb"];
    
    return cell;
}


#pragma mark - refresh delegate

- (void)dropViewDidBeginRefreshing:(UIRefreshControl *)refreshControl {
    [self scanShields:nil];
    double delayInSeconds = 3.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [refreshControl endRefreshing];
    });
}

@end