//
//  HEPDeviceManager.h
//  Pea
//
//  Created by Delisa Mason on 6/9/14.
//  Copyright (c) 2014 Hello. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CBCentralManager;
@class CBPeripheral;

/**
 *  Notification identifier sent when current time is set on a peripheral
 */
extern NSString* const HEPDeviceManagerDidWriteCurrentTimeNotification;

@interface HEPCBPeripheralManager : NSObject <CBPeripheralDelegate, CBCentralManagerDelegate>

+ (CBCentralManager*)sharedCentralManager;

- (instancetype)initWithPeripheral:(CBPeripheral*)peripheral;

- (void)writeCurrentTime;

- (void)readCurrentTime;

- (void)calibrate;

- (void)startDataCollection;

- (void)stopDataCollection;

- (NSData*)fetchData;

/**
 *  A list of discovered named devices, populated by calling `scanForPeripherals`
 */
@property (nonatomic, strong, readonly) NSArray* discoveredPeripherals;

/**
 *  The connected peripheral
 */
@property (nonatomic, strong, readonly) CBPeripheral* peripheral;

@end
