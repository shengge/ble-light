//
//  LBLightShield.m
//  littleBulb
//
//  Created by yy on 13-5-4.
//
//

#import "LBLightShield.h"
#import "LBDefine.h"
#import "LBDevice.h"
#import "LBTools.h"

static NSString *kMethodOperationDiscoverPeripheral = @"discover_peripheral";
static NSString *kMethodOperationDiscoverService    = @"discover_service";

static NSString *kMethodOperationWrite              = @"write";
static NSString *kMethodOperationRead               = @"read";

@interface LBLightShield ()

@property (nonatomic, strong) NSMutableDictionary *completions;

- (NSString *)blockKeyForPeripheral:(CBPeripheral *)peripheral
                             method:(NSString *)method;

@end


@implementation LBLightShield

- (id)init {
    self = [super init];
    if (self) {
        _manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:nil];
        _peripherals = [NSMutableArray array];
        _activePeripherals = [NSMutableArray array];
        _completions = [NSMutableDictionary dictionary];
    }
    return self;
}

- (CBPeripheral *)peripheralForUUID:(NSString *)uuidString {
    for (CBPeripheral *p in _peripherals) {
        if ([[p.identifier UUIDString] isEqualToString:uuidString]) {
            return p;
        }
    }
    
    return nil;
}

- (NSString *)blockKeyForPeripheral:(CBPeripheral *)peripheral
                             method:(NSString *)method {
    
    NSString *prefix = peripheral ? [peripheral.identifier UUIDString] : @"";
    return [NSString stringWithFormat:@"%@_%@", prefix, method];
}

- (int)findPeripherals:(NSInteger)timeout
    completion:(LBShieldCompletionBlock)completion {
    
    [_peripherals removeAllObjects];
    [_activePeripherals removeAllObjects];
    if ([_manager state] != CBCentralManagerStatePoweredOn) {
        NSLog(@"CoreBluetooth is not correctly initialized !\n");
    }

    NSString *blockKey = [self blockKeyForPeripheral:nil
                                              method:kMethodOperationDiscoverPeripheral];
    [_completions setValue:completion forKey:blockKey];
    
    NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                                        forKey:CBCentralManagerScanOptionAllowDuplicatesKey];
    [_manager scanForPeripheralsWithServices:nil options:options];
    
    return 0;
}

#pragma mark - Settings

// If we connect a device with the service we want, add it to our device list
// so that we can automatically restore it later.
- (void)addSavedDevice:(NSString *)uuid {
	NSArray	*storedDevices = [[NSUserDefaults standardUserDefaults] arrayForKey:kStoredDevices];
	NSMutableArray *newDevices = nil;
	
	if (![storedDevices isKindOfClass:[NSArray class]] && storedDevices != nil) {
        return;
    }
	
    newDevices = [NSMutableArray arrayWithArray:storedDevices];
    
    if (![newDevices containsObject:uuid]) {
        [newDevices addObject:uuid];
    }
    /* Store */
    [[NSUserDefaults standardUserDefaults] setObject:newDevices forKey:kStoredDevices];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

// If we explicitly disconnect a device, remove it from our device list
- (void)removeSavedDevice:(NSString *) uuid {
	NSArray	*storedDevices	= [[NSUserDefaults standardUserDefaults] arrayForKey:kStoredDevices];
	NSMutableArray *newDevices = nil;
	
	if ([storedDevices isKindOfClass:[NSArray class]]) {
		newDevices = [NSMutableArray arrayWithArray:storedDevices];
		
        [newDevices removeObject:uuid];


		/* Store */
		[[NSUserDefaults standardUserDefaults] setObject:newDevices forKey:kStoredDevices];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
}

#pragma mark - connect method

/*
 * connect
 * connect to a given peripheral
 *
 */
- (void)connect:(CBPeripheral *)peripheral {
    if (peripheral.state != CBPeripheralStateConnected) {
        [_manager connectPeripheral:peripheral options:nil];
    }
}

/*
 * disconnect
 * disconnect to a given peripheral
 *
 */
- (void)disconnect:(CBPeripheral *)peripheral {
    [_manager cancelPeripheralConnection:peripheral];
}

- (BOOL)isActived:(CBPeripheral *)peripheral {
    return [_activePeripherals containsObject:peripheral];
}


- (void)peripheral:(CBPeripheral *)peripheral
         writeData:(NSData *)data
 forCharacteristic:(CBCharacteristic *)characteristic
        completion:(LBShieldCompletionBlock)completion {
    
    NSString *blockKey = [self blockKeyForPeripheral:peripheral
                                              method:kMethodOperationWrite];
    [_completions setValue:completion forKey:blockKey];
    
    if (peripheral.state != CBPeripheralStateConnected) {
        NSLog(@"write err for disconnected %@", peripheral);
        return;
    }
    
    if (characteristic) {
        [peripheral writeValue:data
             forCharacteristic:characteristic
                          type:CBCharacteristicWriteWithResponse];
    }
}

#pragma mark - CBCentralManager Delegates

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    //TODO: to handle the state updates
    NSLog(@"centeral manager state:%d", central.state);
}

- (void)centralManager:(CBCentralManager *)central
 didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary *)advertisementData
                  RSSI:(NSNumber *)RSSI {
    
    if ([_peripherals containsObject:peripheral] ||
        ![peripheral.name isEqualToString:kBleName]) {
        return;
    }
    
    [_peripherals addObject:peripheral];
    NSString *blockKey = [self blockKeyForPeripheral:nil
                                              method:kMethodOperationDiscoverPeripheral];
    LBShieldCompletionBlock block = [_completions objectForKey:blockKey];
    if (block) {
        block(peripheral, nil);
    }
}

- (void)centralManager:(CBCentralManager *)central
  didConnectPeripheral:(CBPeripheral *)peripheral {
    if (![self isActived:peripheral]) {
        [self.activePeripherals addObject:peripheral];
    }
    
    peripheral.delegate = self;
    [peripheral discoverServices:nil];
    [self addSavedDevice:[peripheral.identifier UUIDString]];
    
    NSString *blockKey = [self blockKeyForPeripheral:nil
                                              method:kMethodOperationDiscoverPeripheral];
    LBShieldCompletionBlock block = [_completions objectForKey:blockKey];
    if (block) {
        block(peripheral, nil);
    }
    NSLog(@"connected to the peripheral %@", peripheral);
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"disconnected to the peripheral %@", peripheral);
	if ([self isActived:peripheral] &&
        [[NSUserDefaults standardUserDefaults] boolForKey:kAutomaticalllyReconnect]) {
		[self connect:peripheral];
	}
    
	[_activePeripherals removeObject:peripheral];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"failed to connect to peripheral %@: %@\n", [peripheral name], [error localizedDescription]);
}

// Callback from retrievePeripherals
- (void)centralManager:(CBCentralManager *)central
didRetrievePeripherals:(NSArray *)aPeripherals {
	for (CBPeripheral *peripheral in aPeripherals) {
		if (![_peripherals containsObject:peripheral]) {
			[_peripherals addObject:peripheral];
		}
		
		if (peripheral.state != CBPeripheralStateConnected) {
			[self connect:peripheral];
		}
	}
    
}

#pragma mark - CBPeripheralDelegates
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    if (error) {
        NSLog(@"discoverservices is uncesessful!\n");
        return;
    }
    
    CBService *gattService = [LBTools findServiceFromUUID:[CBUUID UUIDWithString:kBleServiceUUID]
                                               peripheral:peripheral];
    if (!gattService) {
        NSLog(@"The desired service is not found!\n");
        return;
    }
    
    [peripheral discoverCharacteristics:nil forService:gattService];
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        LBDevice *device = [LBDevice deviceWithPeripheral:peripheral];
        [device setupWithShield:self];
    });
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSString *blockKey = [self blockKeyForPeripheral:peripheral
                                              method:kMethodOperationWrite];
    LBShieldCompletionBlock block = [_completions objectForKey:blockKey];
    if (block) {
        block(nil, error);
    }
}

@end
