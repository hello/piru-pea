//
//  HEPDeviceManager.m
//  Pea
//
//  Created by Delisa Mason on 6/9/14.
//  Copyright (c) 2014 Hello. All rights reserved.
//
#import <CoreBluetooth/CoreBluetooth.h>
#import "HEPCBPeripheralManager.h"
#import "HEPCBCentralManagerBroadcastDelegate.h"

typedef NS_ENUM(NSUInteger, HEPDeviceManagerAction) {
    HEPDeviceManagerActionReadTime,
    HEPDeviceManagerActionWriteTime,
    HEPDeviceManagerActionUpdateFirmware,
    HEPDeviceManagerActionNone,
};

void readDateIntoArray(unsigned short bytes[6])
{
    NSDate* date = [NSDate date];
    NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents* components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit)fromDate:date];
    bytes[0] = (short)components.year;
    bytes[1] = (char)components.month;
    bytes[2] = (char)components.day;
    bytes[3] = (char)components.hour;
    bytes[4] = (char)components.minute;
    bytes[5] = (char)components.second;
}

NSString* const HEPDeviceManagerDidWriteCurrentTimeNotification = @"HEPDeviceManagerDidWriteCurrentTimeNotification";

static NSString* const HEPDeviceServiceELLO = @"0000E110-1212-EFDE-1523-785FEABCD123";
static NSString* const HEPDeviceCharacteristicDEED = @"DEED";
static NSString* const HEPDeviceCharacteristic2A08 = @"2A08";

@interface HEPCBPeripheralManager ()
@property (nonatomic, getter=shouldDisconnectPeripheral) BOOL disconnectPeripheral;
@property (nonatomic, strong, readwrite) CBPeripheral* peripheral;
@property (nonatomic) HEPDeviceManagerAction nextAction;
@end

@implementation HEPCBPeripheralManager

+ (dispatch_queue_t)centralManagerQueue
{
    static dispatch_queue_t queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create("co.hello.device_picker", DISPATCH_QUEUE_CONCURRENT);
    });
    return queue;
}

+ (CBCentralManager*)sharedCentralManager
{
    static CBCentralManager* manager;
    static HEPCBCentralManagerBroadcastDelegate* delegate;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        delegate = [[HEPCBCentralManagerBroadcastDelegate alloc] init];
        manager = [[CBCentralManager alloc] initWithDelegate:delegate queue:[self centralManagerQueue]];
    });
    return manager;
}

- (instancetype)initWithPeripheral:(CBPeripheral*)peripheral
{
    if (self = [super init]) {
        _peripheral = peripheral;
        _nextAction = HEPDeviceManagerActionNone;
    }
    return self;
}

- (void)writeCurrentTime
{
    [self prepareServiceWithUUIDString:HEPDeviceServiceELLO forAction:HEPDeviceManagerActionWriteTime andPerformBlock:^{
        CBService* helloService = [self serviceWithUUIDString:HEPDeviceServiceELLO];
        CBCharacteristic* deed  = [self characteristicWithUUIDString:HEPDeviceCharacteristicDEED onService:helloService];
        const unsigned char bytes[] = { 0x6 };
        NSData *data = [NSData dataWithBytes:bytes length:sizeof(bytes)];
        [self.peripheral writeValue:data forCharacteristic:deed type:CBCharacteristicWriteWithResponse];
        unsigned short dateBytes[6] = {};
        readDateIntoArray(dateBytes);
//        self.nextAction = HEPDeviceManagerActionReadTime;
        [self.peripheral writeValue:[NSData dataWithBytes:dateBytes length:sizeof(dateBytes)] forCharacteristic:deed type:CBCharacteristicWriteWithResponse];
    }];
}

- (void)readCurrentTime
{
    [self prepareServiceWithUUIDString:HEPDeviceServiceELLO forAction:HEPDeviceManagerActionReadTime andPerformBlock:^{
        CBService* helloService  = [self serviceWithUUIDString:HEPDeviceServiceELLO];
        CBCharacteristic* read = [self characteristicWithUUIDString:HEPDeviceCharacteristic2A08 onService:helloService];
        CBCharacteristic* deed = [self characteristicWithUUIDString:HEPDeviceCharacteristicDEED onService:helloService];
        const unsigned char bytes[] = { 0x5 };
        [self.peripheral setNotifyValue:YES forCharacteristic:read];
        NSData *data = [NSData dataWithBytes:bytes length:sizeof(bytes)];
        [self.peripheral writeValue:data forCharacteristic:deed type:CBCharacteristicWriteWithResponse];
    }];
}

- (void)prepareServiceWithUUIDString:(NSString*)UUIDString forAction:(HEPDeviceManagerAction)action andPerformBlock:(void (^)(void))block
{
    if (!self.peripheral.state == CBPeripheralStateConnected) {
        self.nextAction = action;
        [[[self class] sharedCentralManager] connectPeripheral:self.peripheral options:nil];
    } else if (self.peripheral.services == nil) {
        self.nextAction = action;
        [self.peripheral discoverServices:nil];
    } else {
        CBService* service = [self serviceWithUUIDString:UUIDString];
        if (service.characteristics == nil) {
            self.nextAction = HEPDeviceManagerActionWriteTime;
            [self.peripheral discoverCharacteristics:nil forService:service];
        } else {
            block();
        }
    }
}

- (void)performNextAction
{
    HEPDeviceManagerAction action = self.nextAction;
    self.nextAction = HEPDeviceManagerActionNone;
    switch (action) {
    case HEPDeviceManagerActionReadTime:
        [self readCurrentTime];
        break;
    case HEPDeviceManagerActionWriteTime:
        [self writeCurrentTime];
        break;
    case HEPDeviceManagerActionUpdateFirmware:
        break;
    default:
        break;
    }
}

#pragma mark - CBPeripheral filtering

- (CBService*)serviceWithUUIDString:(NSString*)UUIDString
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"UUID == %@", [CBUUID UUIDWithString:UUIDString]];
    return [[self.peripheral.services filteredArrayUsingPredicate:predicate] firstObject];
}

- (CBCharacteristic*)characteristicWithUUIDString:(NSString*)UUIDString onService:(CBService*)service
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"UUID == %@", [CBUUID UUIDWithString:UUIDString]];
    return [[service.characteristics filteredArrayUsingPredicate:predicate] firstObject];
}

#pragma mark - CBCentralManagerDelegate

- (void)centralManager:(CBCentralManager*)central didDisconnectPeripheral:(CBPeripheral*)peripheral error:(NSError*)error
{
}

- (void)centralManager:(CBCentralManager*)central didConnectPeripheral:(CBPeripheral*)peripheral
{
    [self performNextAction];
}

- (void)centralManager:(CBCentralManager*)central didFailToConnectPeripheral:(CBPeripheral*)peripheral error:(NSError*)error
{
}

- (void)centralManager:(CBCentralManager*)central didRetrieveConnectedPeripherals:(NSArray*)peripherals
{
}

- (void)centralManagerDidUpdateState:(CBCentralManager*)central
{
}

#pragma mark - CBPeripheralDelegate

- (void)peripheral:(CBPeripheral*)peripheral didDiscoverCharacteristicsForService:(CBService*)service error:(NSError*)error
{
    [self performNextAction];
}

- (void)peripheral:(CBPeripheral*)peripheral didDiscoverServices:(NSError*)error
{
    [self performNextAction];
}

- (void)peripheral:(CBPeripheral*)peripheral didUpdateValueForCharacteristic:(CBCharacteristic*)characteristic error:(NSError*)error
{
    NSLog(@"characteristic: %@ error: %@", characteristic, error.localizedDescription);
}

- (void)peripheral:(CBPeripheral*)peripheral didWriteValueForCharacteristic:(CBCharacteristic*)characteristic error:(NSError*)error
{
    NSLog(@"characteristic: %@ error: %@", characteristic, error.localizedDescription);
    [self performNextAction];
}

- (void)peripheral:(CBPeripheral*)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic*)characteristic error:(NSError*)error
{
    if (error) {
        NSLog(@"Error changing notification state: %@",
              [error localizedDescription]);
    }
}

@end
