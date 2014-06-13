//
//  HEPDeviceService.m
//  Pea
//
//  Created by Delisa Mason on 6/10/14.
//  Copyright (c) 2014 Hello. All rights reserved.
//

#import "HEPDeviceService.h"
#import "HEPDevice.h"

static NSString* const HEPDeviceServiceArchiveKey = @"HEPDeviceArchive";

@implementation HEPDeviceService

+ (BOOL)hasDevices
{
    return [self archivedDevices].count > 0;
}

+ (void)addDevice:(HEPDevice*)device
{
    if (!device)
        return;
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"identifier = %@", device.identifier];
    NSArray* archivedDevices = [self archivedDevices];
    if ([archivedDevices filteredArrayUsingPredicate:predicate].count == 0) {
        [self archiveDevices:[[self archivedDevices] arrayByAddingObject:device]];
    }
}

+ (void)removeDevice:(HEPDevice*)device
{
    if (!device)
        return;
    NSArray* devices = [[self archivedDevices] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(HEPDevice* evaluatedObject, NSDictionary* bindings) {

        return ![evaluatedObject.identifier isEqual:device.identifier];
                                                                           }]];
    [self archiveDevices:devices];
}

+ (void)updateDevice:(HEPDevice*)device
{
    if (!device)
        return;
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"identifier != %@", device.identifier];
    NSArray* archivedDevices = [[self archivedDevices] filteredArrayUsingPredicate:predicate];
    [self archiveDevices:[archivedDevices arrayByAddingObject:device]];
}

+ (void)removeAllDevices
{
    [NSKeyedArchiver archiveRootObject:nil toFile:[self archivedDevicesPath]];
}

+ (NSArray*)archivedDevices
{
    return [NSKeyedUnarchiver unarchiveObjectWithFile:[self archivedDevicesPath]] ?: @[];
}

+ (void)archiveDevices:(NSArray*)devices
{
    [NSKeyedArchiver archiveRootObject:devices toFile:[self archivedDevicesPath]];
}

+ (HEPDevice*)deviceWithIdentifier:(NSString*)identifier
{
    for (HEPDevice* device in [self archivedDevices]) {
        if ([[device.identifier uppercaseString] isEqualToString:[identifier uppercaseString]]) {
            return device;
        }
    }
    return nil;
}

+ (NSString*)archivedDevicesPath
{
    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    return [documentsPath stringByAppendingPathComponent:HEPDeviceServiceArchiveKey];
}

@end
