//
//  BLDefine.h
//  HelloBTSmart
//
//  Created by yy on 13-2-28.
//
//

#define kBleName                        @"ABLight"

#pragma mark - notifys

#define kNotiAppActived                 @"app_actived"
#define kNotiAppBackground              @"app_background"
#define kNotiPeripheralAround           @"peripheral_around"
#define kNotiPeripheralLost             @"peripheral_lost"
#define kNotiPeripheralWrited           @"peripheral_writed"
#define kNotiAlarming                   @"alarming"
#define kNotiCoverUp                    @"cover_up"

#pragma mark - keys

#define kAutomaticalllyReconnect		@"auto_reconnect"
#define kRssiUpdateFrequencyHertz       1
#define kMaxRssiSamples                 3
#define kEventPeriod                    600
#define kEventTriggeredPeriod           30
#define kSyncByte                       'e'
#define kSensorKey                      @"sensor"
#define kStoredDevices                  @"StoredDevices"

#pragma mark - uuids

#define kTxPowerServiceUUID             @"180A"

#define kBleServiceUUID                 @"FAB0"
#define kBleDimmerUUID                  @"FAB1"
#define kBleNotifyUUID                  @"FAB2"

#pragma mark - table name

#define kGroupTable                     @"groups"
#define kDeviceGroupTable               @"device_group"
#define kDeviceTable                    @"devices"
