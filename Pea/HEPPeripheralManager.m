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

NSString* const HEPDeviceServiceELLO = @"0000E110-1212-EFDE-1523-785FEABCD123";
NSString* const HEPDeviceServiceFFA0 = @"0000FFA0-1212-EFDE-1523-785FEABCD123";
static NSString* const HEPDeviceCharacteristicDEED = @"DEED";
static NSString* const HEPDeviceCharacteristicD00D = @"D00D";
static NSString* const HEPDeviceCharacteristicDayDateTime = @"2A0A";
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

- (void)writeCurrentTimeWithCompletion:(HEPDeviceErrorBlock)completionBlock
{
    [self connectAndDiscoverServiceWithUUIDString:HEPDeviceServiceELLO andPerformBlock:^(LGService* helloService) {
        LGCharacteristic* deed = [self characteristicWithUUIDString:HEPDeviceCharacteristicDEED onService:helloService];
        [deed writeByte:0x6 completion:^(NSError *error) {
            if (error) {
                if (completionBlock)
                    completionBlock(error);
                return;
            }
            unsigned char dateBytes[8] = {};
            readDateIntoArray(dateBytes);
            NSData* date = [NSData dataWithBytes:dateBytes length:8];
            NSLog(@"Write Current Time: %@", date);
            [deed writeValue:date completion:^(NSError *error) {
                if (completionBlock)
                    completionBlock(error);
            }];
        }];
    } failureBlock:completionBlock];
}

- (void)readCurrentTimeWithCompletion:(HEPDeviceErrorBlock)completionBlock
{
    __weak typeof(self) weakSelf = self;
    [self connectAndDiscoverServiceWithUUIDString:HEPDeviceServiceELLO andPerformBlock:^(LGService* helloService) {
        typeof(self) strongSelf = weakSelf;
        LGCharacteristic* read = [self characteristicWithUUIDString:HEPDeviceCharacteristicDayDateTime onService:helloService];
        [read setNotifyValue:YES completion:^(NSError *error) {
            if (error) {
                if (completionBlock)
                    completionBlock(error);
                return;
            }
            LGCharacteristic* deed = [self characteristicWithUUIDString:HEPDeviceCharacteristicDEED onService:helloService];
            [deed writeByte:0x5 completion:^(NSError *error) {
                if (error) {
                    if (completionBlock)
                        completionBlock(error);
                }
            }];
        } onUpdate:^(NSData *data, NSError *error) {
            if (completionBlock)
                completionBlock(error);
            [strongSelf disconnectWithCompletion:NULL];
        }];
    } failureBlock:completionBlock];
}

- (NSData*)fetchDataWithCompletion:(HEPDeviceErrorBlock)completionBlock
{
    return nil;
}

- (void)calibrateWithCompletion:(HEPDeviceErrorBlock)completionBlock
{
    [self connectAndDiscoverServiceWithUUIDString:HEPDeviceServiceFFA0 andPerformBlock:^(LGService* service) {
        LGService* helloService = [self serviceWithUUIDString:HEPDeviceServiceELLO];
        [helloService discoverCharacteristicsWithCompletion:^(NSArray *characteristics, NSError *error) {
            LGCharacteristic* ffaa = [self characteristicWithUUIDString:HEPDeviceCharacteristicFFAA onService:service];
            [ffaa setNotifyValue:YES completion:^(NSError *error) {
                if (error) {
                    if (completionBlock)
                        completionBlock(error);
                    return;
                }
                LGCharacteristic* deed = [self characteristicWithUUIDString:HEPDeviceCharacteristicDEED onService:helloService];
                LGCharacteristic* dood = [self characteristicWithUUIDString:HEPDeviceCharacteristicD00D onService:helloService];
                [deed writeByte:0x2 completion:^(NSError *error) {
                    if (error) {
                        if (completionBlock)
                            completionBlock(error);
                        return;
                    }
                    [dood readValueWithBlock:^(NSData *data, NSError *error) {
                        if (completionBlock)
                            completionBlock(error);
                        NSLog(@"should get 0x2: %@", data);
                    }];
                }];
            } onUpdate:^(NSData *data, NSError *error) {
//                NSLog(@"Should get some values: %@", data);
            }];
        }];
    } failureBlock:completionBlock];
}

- (void)startDataCollectionWithCompletion:(HEPDeviceErrorBlock)completionBlock
{
    __weak typeof(self) weakSelf = self;
    [self connectAndDiscoverServiceWithUUIDString:HEPDeviceServiceELLO andPerformBlock:^(LGService* helloService) {
        typeof(self) strongSelf = weakSelf;
        LGCharacteristic* deed = [strongSelf characteristicWithUUIDString:HEPDeviceCharacteristicDEED onService:helloService];
        LGCharacteristic* dood = [strongSelf characteristicWithUUIDString:HEPDeviceCharacteristicD00D onService:helloService];
        [deed writeByte:0x1 completion:^(NSError *error) {
            if (error) {
                if (completionBlock)
                    completionBlock(error);
                return;
            }
            [dood readValueWithBlock:^(NSData *data, NSError *error) {
                if (error) {
                    if (completionBlock)
                        completionBlock(error);
                    return;
                }
                [strongSelf updateDeviceWithDataRecordingState:YES];
                [strongSelf disconnectWithCompletion:NULL];
            }];
        }];
    } failureBlock:completionBlock];
}

- (void)stopDataCollectionWithCompletion:(HEPDeviceErrorBlock)completionBlock
{
    __weak typeof(self) weakSelf = self;
    [self connectAndDiscoverServiceWithUUIDString:HEPDeviceServiceELLO andPerformBlock:^(LGService* helloService) {
        typeof(self) strongSelf = weakSelf;
        LGCharacteristic* deed = [strongSelf characteristicWithUUIDString:HEPDeviceCharacteristicDEED onService:helloService];
        LGCharacteristic* dood = [strongSelf characteristicWithUUIDString:HEPDeviceCharacteristicD00D onService:helloService];
        [deed writeByte:0x0 completion:^(NSError *error) {
            if (error) {
                if (completionBlock)
                    completionBlock(error);
                return;
            }
            [dood readValueWithBlock:^(NSData *data, NSError *error) {
                if (error) {
                    if (completionBlock)
                        completionBlock(error);
                    return;
                }
                [strongSelf updateDeviceWithDataRecordingState:NO];
                [strongSelf disconnectWithCompletion:NULL];
            }];
        }];
    } failureBlock:completionBlock];
}

- (void)disconnectWithCompletion:(HEPDeviceErrorBlock)completionBlock
{
    if (![self isConnected]) {
        if (completionBlock)
            completionBlock(nil);
        return;
    }

    __weak typeof(self) weakSelf = self;
    [self discoverServiceWithUUIDString:HEPDeviceServiceELLO andPerformBlock:^(LGService* helloService) {
        typeof(self) strongSelf = weakSelf;
        LGCharacteristic* deed = [strongSelf characteristicWithUUIDString:HEPDeviceCharacteristicDEED onService:helloService];
        LGCharacteristic* dood = [strongSelf characteristicWithUUIDString:HEPDeviceCharacteristicD00D onService:helloService];
        [dood setNotifyValue:YES completion:^(NSError *error) {
            if (error) {
                if (completionBlock)
                    completionBlock(error);
                return;
            }
            [deed writeByte:0x3 completion:^(NSError *error) {
                if (error) {
                    if (completionBlock)
                        completionBlock(error);
                }
            }];
        } onUpdate:^(NSData *data, NSError *error) {
            if (completionBlock)
                completionBlock(error);
        }];
    } failureBlock:completionBlock];
}

#pragma mark - Private

- (BOOL)isConnected
{
    return self.peripheral.cbPeripheral.state == CBPeripheralStateConnected;
}

/**
 *  Connects to a peripheral and discovers available services, invoking a block with a matching service
 *  upon success.
 *
 *  @param UUIDString   UUID of a particular service on which characteristics are queried
 *  @param successBlock block invoked when connection succeeds
 *  @param failureBlock block invoked when connection fails
 */
- (void)connectAndDiscoverServiceWithUUIDString:(NSString*)UUIDString andPerformBlock:(void (^)(LGService*))successBlock failureBlock:(HEPDeviceErrorBlock)failureBlock
{
    if ([self isConnected]) {
        [self discoverServiceWithUUIDString:UUIDString andPerformBlock:successBlock failureBlock:failureBlock];
    } else {
        __weak typeof(self) weakSelf = self;
        [self.peripheral connectWithTimeout:3 completion:^(NSError* error) {
            typeof(self) strongSelf = weakSelf;
            if (error) {
                if (failureBlock)
                    failureBlock(error);
                return;
            }
            [strongSelf discoverServiceWithUUIDString:UUIDString andPerformBlock:successBlock failureBlock:failureBlock];
        }];
    }
}

- (void)discoverServiceWithUUIDString:(NSString*)UUIDString andPerformBlock:(void (^)(LGService*))successBlock failureBlock:(HEPDeviceErrorBlock)failureBlock
{
    [self.peripheral discoverServices:nil completion:^(NSArray* services, NSError* error) {
        if (error) {
            if (failureBlock)
                failureBlock(error);
            return;
        }
        LGService* service = [self serviceWithUUIDString:UUIDString inArray:services];
        if (service.characteristics) {
            if (successBlock)
                successBlock(service);
        } else {
            [service discoverCharacteristicsWithCompletion:^(NSArray *characteristics, NSError *error) {
                if (error) {
                    if (failureBlock)
                        failureBlock(error);
                    return;
                }
                if (successBlock)
                    successBlock(service);
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
