//
//  HEPCBCentralManagerDelegate.h
//  Pea
//
//  Created by Delisa Mason on 6/10/14.
//  Copyright (c) 2014 Hello. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

/**
 * Notification sent when the central manager connects a peripheral. The notification's userInfo
 * includes the connected peripheral.
 */
extern NSString* const HEPCBCentralManagerDidConnectPeripheralNotification;

/**
 * Notification sent when the central manager disconnects a peripheral. The notification's userInfo
 * includes the disconnected peripheral.
 */
extern NSString* const HEPCBCentralManagerDidDisconnectPeripheralNotification;

/**
 * Notification sent when the central manager discovers a peripheral. The notification's userInfo
 * includes the discovered peripheral.
 */
extern NSString* const HEPCBCentralManagerDidDiscoverPeripheralNotification;

/**
 * Notification sent when the central manager fails to connect a peripheral. The notification's userInfo
 * includes the peripheral which failed to connect.
 */
extern NSString* const HEPCBCentralManagerDidFailToConnectPeripheralNotification;

/**
 *
 * Notification sent when the central manager retrieves a list of connected peripherals. 
 * The notification's userInfo includes an NSArray* of connected peripherals.
 */
extern NSString* const HEPCBCentralManagerDidRetrieveConnectedPeripheralsNotification;

/**
 * Notification sent when the central manager retrieves a list of peripherals.
 * The notification's userInfo includes an NSArray* of peripherals.
 */
extern NSString* const HEPCBCentralManagerDidRetrievePeripheralsNotification;

/**
 *  Notification sent when the central manager changes state
 */
extern NSString* const HEPCBCentralManagerDidUpdateStateNotification;

/**
 *  Notification userInfo key for a peripheral
 */
extern NSString* const HEPCBCentralManagerPeripheralKey;

/**
 *  Notification userInfo key for a NSArray* of peripherals
 */
extern NSString* const HEPCBCentralManagerPeripheralsKey;

/**
 *  Notification userInfo key for the RSSI
 */
extern NSString* const HEPCBCentralManagerRSSIKey;

/**
 *  Thin wrapper around CBCentralManager protocol to broadcast events
 */
@interface HEPCBCentralManagerBroadcastDelegate : NSObject <CBCentralManagerDelegate>
@end
