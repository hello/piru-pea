//
//  HEPCentralManagerDelegate.h
//  Pea
//
//  Created by Delisa Mason on 6/6/14.
//  Copyright (c) 2014 Hello. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

#import "HEPeripheralPickerController.h"

@interface HEPCentralManagerDelegate : NSObject<CBCentralManagerDelegate, HEPeripheralPickerControllerDelegate>

@end
