//
//  HEPDeviceService.h
//  Pea
//
//  Created by Delisa Mason on 6/10/14.
//  Copyright (c) 2014 Hello. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HEPDevice;

@interface HEPDeviceService : NSObject

+ (BOOL)hasDevices;

/**
 *  An array of devices archived to disk
 */
+ (NSArray*)archivedDevices;

/**
 *  Add a given device to the disk store
 *
 *  @param device device to add
 */
+ (void)addDevice:(HEPDevice*)device;

/**
 *  Remove a given device from the disk store
 *
 *  @param device device to remove
 */
+ (void)removeDevice:(HEPDevice*)device;

/**
 *  Update a cached device with new data
 *
 *  @param device device to update
 */
+ (void)updateDevice:(HEPDevice*)device;

/**
 *  Store a given array of device objects, removing the existing store
 *
 *  @param devices devices to archive
 */
+ (void)archiveDevices:(NSArray*)devices;

/**
 *  Delete all devices in the existing store
 */
+ (void)removeAllDevices;

/**
 *  Finds a device in the disk store matching a given identifier
 *
 *  @param identifier the identifier to match
 *
 *  @return a matching device
 */
+ (HEPDevice*)deviceWithIdentifier:(NSString*)identifier;

@end
