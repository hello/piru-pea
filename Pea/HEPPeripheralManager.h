//
//  HEPDeviceManager.h
//  Pea
//
//  Created by Delisa Mason on 6/9/14.
//  Copyright (c) 2014 Hello. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LGPeripheral;
@class LGCentralManager;

typedef void (^HEPDeviceErrorBlock)(NSError* error);

extern NSString* const HEPDeviceServiceELLO;
extern NSString* const HEPDeviceServiceFFA0;

/**
 *  Notification identifier sent when current time is set on a peripheral
 */
extern NSString* const HEPDeviceManagerDidWriteCurrentTimeNotification;

@interface HEPPeripheralManager : NSObject

- (instancetype)initWithPeripheral:(LGPeripheral*)peripheral;

- (void)writeCurrentTimeWithCompletion:(HEPDeviceErrorBlock)completionBlock;

- (void)readCurrentTimeWithCompletion:(HEPDeviceErrorBlock)completionBlock;

- (void)calibrateWithCompletion:(HEPDeviceErrorBlock)completionBlock;

- (void)startDataCollectionWithCompletion:(HEPDeviceErrorBlock)completionBlock;

- (void)stopDataCollectionWithCompletion:(HEPDeviceErrorBlock)completionBlock;

- (void)disconnectWithCompletion:(HEPDeviceErrorBlock)completionBlock;

- (NSData*)fetchDataWithCompletion:(HEPDeviceErrorBlock)completionBlock;

/**
 *  A list of discovered named devices, populated by calling `scanForPeripherals`
 */
@property (nonatomic, strong, readonly) NSArray* discoveredPeripherals;

/**
 *  The connected peripheral
 */
@property (nonatomic, strong, readonly) LGPeripheral* peripheral;

@end
