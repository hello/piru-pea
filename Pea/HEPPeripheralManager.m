//
//  HEPDeviceManager.m
//  Pea
//
//  Created by Delisa Mason on 6/9/14.
//  Copyright (c) 2014 Hello. All rights reserved.
//
#import <CoreBluetooth/CoreBluetooth.h>
#import <LGBluetooth/LGBluetooth.h>

#import "HEPPeripheralManager.h"
#import "HEPDeviceService.h"
#import "HEPDevice.h"

void readDateIntoArray(unsigned char bytes[8])
{
    NSDate* date = [NSDate date];
    NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents* components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit)fromDate:date];
    NSInteger weekday = components.weekday;
    bytes[0] = (char)(components.year >> 8);
    bytes[1] = (char)components.year;
    bytes[2] = (char)components.month;
    bytes[3] = (char)components.day;
    bytes[4] = (char)components.hour;
    bytes[5] = (char)components.minute;
    bytes[6] = (char)components.second;
    bytes[7] = weekday == 1 ? 7 : weekday - 1;
}

NSString* const HEPDeviceManagerDidWriteCurrentTimeNotification = @"HEPDeviceManagerDidWriteCurrentTimeNotification";

static NSString* const HEPDeviceServiceELLO = @"0000E110-1212-EFDE-1523-785FEABCD123";
static NSString* const HEPDeviceServiceFFA0 = @"0000FFA0-1212-EFDE-1523-785FEABCD123";
static NSString* const HEPDeviceCharacteristicDEED = @"DEED";
static NSString* const HEPDeviceCharacteristicD00D = @"D00D";
static NSString* const HEPDeviceCharacteristic2A0A = @"2A0A";
static NSString* const HEPDeviceCharacteristicFFAA = @"FFAA";

@interface HEPPeripheralManager ()
@property (nonatomic, getter=shouldDisconnectPeripheral) BOOL disconnectPeripheral;
@property (nonatomic, strong, readwrite) LGPeripheral* peripheral;
@end

@implementation HEPPeripheralManager

- (instancetype)initWithPeripheral:(LGPeripheral*)peripheral
{
    if (self = [super init]) {
        _peripheral = peripheral;
    }
    return self;
}

- (void)writeCurrentTime
{
    [self connectAndDiscoverServiceWithUUIDString:HEPDeviceServiceELLO andPerformBlock:^(LGService* helloService) {
        LGCharacteristic* deed  = [self characteristicWithUUIDString:HEPDeviceCharacteristicDEED onService:helloService];
        
        [deed writeByte:0x6 completion:^(NSError *error) {
            unsigned char dateBytes[8] = {};
            readDateIntoArray(dateBytes);
            NSData* date = [NSData dataWithBytes:dateBytes length:8];
            NSLog(@"Write Current Time: %@", date);
            [deed writeValue:date completion:^(NSError *error) {
                [self readCurrentTime];
            }];
        }];
    }];
}

- (void)readCurrentTime
{
    __weak typeof(self) weakSelf = self;
    [self connectAndDiscoverServiceWithUUIDString:HEPDeviceServiceELLO andPerformBlock:^(LGService* helloService) {
        typeof(self) strongSelf = weakSelf;
        LGCharacteristic* read = [self characteristicWithUUIDString:HEPDeviceCharacteristic2A0A onService:helloService];
        [read setNotifyValue:YES completion:^(NSError *error) {
            LGCharacteristic* deed = [self characteristicWithUUIDString:HEPDeviceCharacteristicDEED onService:helloService];
            [deed writeByte:0x5 completion:^(NSError *error) {}];
        } onUpdate:^(NSData *data, NSError *error) {
            NSLog(@"Current Time: %@", data);
            [strongSelf disconnect];
        }];
    }];
}

- (NSData*)fetchData
{
    return nil;
}

- (void)calibrate
{
    [self connectAndDiscoverServiceWithUUIDString:HEPDeviceServiceFFA0 andPerformBlock:^(LGService* service) {
        LGService* helloService = [self serviceWithUUIDString:HEPDeviceServiceELLO];
        [helloService discoverCharacteristicsWithCompletion:^(NSArray *characteristics, NSError *error) {
            LGCharacteristic* ffaa = [self characteristicWithUUIDString:HEPDeviceCharacteristicFFAA onService:service];
            [ffaa setNotifyValue:YES completion:^(NSError *error) {
                LGCharacteristic* deed = [self characteristicWithUUIDString:HEPDeviceCharacteristicDEED onService:helloService];
                LGCharacteristic* dood = [self characteristicWithUUIDString:HEPDeviceCharacteristicD00D onService:helloService];
                [deed writeByte:0x2 completion:^(NSError *writeError) {
                    [dood readValueWithBlock:^(NSData *data, NSError *error) {
                        NSLog(@"should get 0x2: %@", data);
                    }];
                }];
            } onUpdate:^(NSData *data, NSError *error) {
                NSLog(@"Should get (near) zeroes: %@", data);
            }];
        }];
    }];
}

- (void)startDataCollection
{
    __weak typeof(self) weakSelf = self;
    [self connectAndDiscoverServiceWithUUIDString:HEPDeviceServiceELLO andPerformBlock:^(LGService* helloService) {
        typeof(self) strongSelf = weakSelf;
        LGCharacteristic* deed = [strongSelf characteristicWithUUIDString:HEPDeviceCharacteristicDEED onService:helloService];
        LGCharacteristic* dood = [strongSelf characteristicWithUUIDString:HEPDeviceCharacteristicD00D onService:helloService];
        [deed writeByte:0x1 completion:^(NSError *error) {
            [dood readValueWithBlock:^(NSData *data, NSError *error) {
                NSLog(@"should get 0x1: %@", data);
                if (!error) {
                    [strongSelf updateDeviceWithDataRecordingState:YES];
                }
                [strongSelf disconnect];
            }];
        }];
    }];
}

- (void)stopDataCollection
{
    __weak typeof(self) weakSelf = self;
    [self connectAndDiscoverServiceWithUUIDString:HEPDeviceServiceELLO andPerformBlock:^(LGService* helloService) {
        typeof(self) strongSelf = weakSelf;
        LGCharacteristic* deed = [strongSelf characteristicWithUUIDString:HEPDeviceCharacteristicDEED onService:helloService];
        LGCharacteristic* dood = [strongSelf characteristicWithUUIDString:HEPDeviceCharacteristicD00D onService:helloService];
        [deed writeByte:0x0 completion:^(NSError *error) {
            [dood readValueWithBlock:^(NSData *data, NSError *error) {
                NSLog(@"should get 0x0: %@", data);
                if (!error) {
                    [strongSelf updateDeviceWithDataRecordingState:NO];
                }
                [strongSelf disconnect];
            }];
        }];
    }];
}

- (void)disconnect
{
    __weak typeof(self) weakSelf = self;
    [self connectAndDiscoverServiceWithUUIDString:HEPDeviceServiceELLO andPerformBlock:^(LGService* helloService) {
        typeof(self) strongSelf = weakSelf;
        LGCharacteristic* deed = [strongSelf characteristicWithUUIDString:HEPDeviceCharacteristicDEED onService:helloService];
        LGCharacteristic* dood = [strongSelf characteristicWithUUIDString:HEPDeviceCharacteristicD00D onService:helloService];
        [dood setNotifyValue:YES completion:^(NSError *error) {
            [deed writeByte:0x3 completion:^(NSError *error) {
                NSLog(@"Disconnected? %@", error);
            }];
        } onUpdate:^(NSData *data, NSError *error) {
            NSLog(@"Should get 0x3: %@", data);
        }];
    }];
}

#pragma mark - Private

- (void)connectAndDiscoverServiceWithUUIDString:(NSString*)UUIDString andPerformBlock:(void (^)(LGService*))block
{
    if (self.peripheral.cbPeripheral.state == CBPeripheralStateConnected) {
        [self discoverServiceWithUUIDString:UUIDString andPerformBlock:block];
    } else {
        __block LGPeripheral* peripheral = self.peripheral;
        __weak typeof(self) weakSelf = self;
        [peripheral connectWithCompletion:^(NSError* error) {
            [weakSelf discoverServiceWithUUIDString:UUIDString andPerformBlock:block];
        }];
    }
}

- (void)discoverServiceWithUUIDString:(NSString*)UUIDString andPerformBlock:(void (^)(LGService*))block
{
    [self.peripheral discoverServices:nil completion:^(NSArray* services, NSError* error) {
        LGService* service = [self serviceWithUUIDString:UUIDString inArray:services];
        if (service.characteristics) {
            if (block)
                block(service);
        } else {
            [service discoverCharacteristicsWithCompletion:^(NSArray *characteristics, NSError *error) {
                if (block)
                    block(service);
            }];
        }
    }];
}

- (void)updateDeviceWithDataRecordingState:(BOOL)isRecordingData
{
    HEPDevice* device = [HEPDeviceService deviceWithIdentifier:self.peripheral.UUIDString];
    device.recordingData = isRecordingData;
    [HEPDeviceService updateDevice:device];
}

#pragma mark Peripheral filtering

- (LGService*)serviceWithUUIDString:(NSString*)UUIDString
{
    return [self serviceWithUUIDString:UUIDString inArray:self.peripheral.services];
}

- (LGService*)serviceWithUUIDString:(NSString*)UUIDString inArray:(NSArray*)services
{
    for (LGService* service in services) {
        if ([[service.UUIDString uppercaseString] isEqualToString:UUIDString]) {
            return service;
        }
    }
    return nil;
}

- (LGCharacteristic*)characteristicWithUUIDString:(NSString*)UUIDString onService:(LGService*)service
{
    for (LGCharacteristic* characteristic in service.characteristics) {
        if ([[characteristic.UUIDString uppercaseString] isEqualToString:UUIDString]) {
            return characteristic;
        }
    }
    return nil;
}

@end
