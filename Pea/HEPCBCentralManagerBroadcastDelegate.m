//
//  HEPCBCentralManagerDelegate.m
//  Pea
//
//  Created by Delisa Mason on 6/10/14.
//  Copyright (c) 2014 Hello. All rights reserved.
//

#import "HEPCBCentralManagerBroadcastDelegate.h"

NSString* const HEPCBCentralManagerDidConnectPeripheralNotification = @"HEPCBCentralManagerDidConnectPeripheral";
NSString* const HEPCBCentralManagerDidDisconnectPeripheralNotification = @"HEPCBCentralManagerDidDisconnectPeripheral";
NSString* const HEPCBCentralManagerDidDiscoverPeripheralNotification = @"HEPCBCentralManagerDidDiscoverPeripheral";
NSString* const HEPCBCentralManagerDidFailToConnectPeripheralNotification = @"HEPCBCentralManagerDidFailToConnectPeripheral";
NSString* const HEPCBCentralManagerDidRetrieveConnectedPeripheralsNotification = @"HEPCBCentralManagerDidRetrieveConnectedPeripherals";
NSString* const HEPCBCentralManagerDidRetrievePeripheralsNotification = @"HEPCBCentralManagerDidRetrievePeripherals";
NSString* const HEPCBCentralManagerDidUpdateStateNotification = @"HEPCBCentralManagerDidUpdateState";

NSString* const HEPCBCentralManagerPeripheralKey = @"peripheral";
NSString* const HEPCBCentralManagerPeripheralsKey = @"peripherals";
NSString* const HEPCBCentralManagerRSSIKey = @"RSSI";

@implementation HEPCBCentralManagerBroadcastDelegate

- (void)centralManager:(CBCentralManager*)central didConnectPeripheral:(CBPeripheral*)peripheral
{
    [[NSNotificationCenter defaultCenter] postNotificationName:HEPCBCentralManagerDidConnectPeripheralNotification object:central userInfo:@{ HEPCBCentralManagerPeripheralKey : peripheral }];
}

- (void)centralManager:(CBCentralManager*)central didDisconnectPeripheral:(CBPeripheral*)peripheral error:(NSError*)error
{
    NSDictionary* userInfo = @{ NSLocalizedDescriptionKey : error.localizedDescription ?: @"",
                                HEPCBCentralManagerPeripheralKey : peripheral };
    [[NSNotificationCenter defaultCenter] postNotificationName:HEPCBCentralManagerDidDisconnectPeripheralNotification object:central userInfo:userInfo];
}

- (void)centralManager:(CBCentralManager*)central didDiscoverPeripheral:(CBPeripheral*)peripheral advertisementData:(NSDictionary*)advertisementData RSSI:(NSNumber*)RSSI
{
    [[NSNotificationCenter defaultCenter] postNotificationName:HEPCBCentralManagerDidDiscoverPeripheralNotification object:central userInfo:@{ HEPCBCentralManagerPeripheralKey : peripheral, HEPCBCentralManagerRSSIKey : RSSI }];
}

- (void)centralManager:(CBCentralManager*)central didFailToConnectPeripheral:(CBPeripheral*)peripheral error:(NSError*)error
{
    NSDictionary* userInfo = @{ HEPCBCentralManagerPeripheralKey : peripheral,
                                NSLocalizedDescriptionKey : error.localizedDescription ?: @"" };
    [[NSNotificationCenter defaultCenter] postNotificationName:HEPCBCentralManagerDidDiscoverPeripheralNotification object:central userInfo:userInfo];
}

- (void)centralManager:(CBCentralManager*)central didRetrieveConnectedPeripherals:(NSArray*)peripherals
{
    [[NSNotificationCenter defaultCenter] postNotificationName:HEPCBCentralManagerDidRetrieveConnectedPeripheralsNotification object:central userInfo:@{ HEPCBCentralManagerPeripheralsKey : peripherals }];
}

- (void)centralManager:(CBCentralManager*)central didRetrievePeripherals:(NSArray*)peripherals
{
    [[NSNotificationCenter defaultCenter] postNotificationName:HEPCBCentralManagerDidRetrievePeripheralsNotification object:central userInfo:@{ HEPCBCentralManagerPeripheralsKey : peripherals }];
}

- (void)centralManagerDidUpdateState:(CBCentralManager*)central
{
    [[NSNotificationCenter defaultCenter] postNotificationName:HEPCBCentralManagerDidUpdateStateNotification object:central];
}

@end
