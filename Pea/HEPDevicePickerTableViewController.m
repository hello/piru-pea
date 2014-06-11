//
//  HEPDevicePickerTableViewController.m
//  Pea
//
//  Created by Delisa Mason on 6/6/14.
//  Copyright (c) 2014 Hello. All rights reserved.
//
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreBluetooth/CBUUID.h>

#import "HEPDevicePickerTableViewController.h"
#import "HEPCBPeripheralManager.h"
#import "HEPCBCentralManagerBroadcastDelegate.h"
#import "HEPDeviceTableViewCell.h"
#import "HEPDeviceService.h"
#import "HEPDevice.h"

static NSString* const pillServiceUUIDString = @"0000E110-1212-EFDE-1523-785FEABCD123";
static NSString* const pillCellIdentifier = @"pillCell";

@interface HEPDevicePickerTableViewController ()

@property (nonatomic, strong) NSArray* discoveredDevices;
@property (nonatomic, strong) NSMutableArray* discoveredDevicesRSSI;
@property (nonatomic, strong) HEPCBPeripheralManager* deviceManager;
@end

@implementation HEPDevicePickerTableViewController

- (id)init
{
    if (self = [super initWithStyle:UITableViewStylePlain]) {
        _discoveredDevices = @[];
        _discoveredDevicesRSSI = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"picker.title", nil);
    [[self tableView] registerNib:[UINib nibWithNibName:NSStringFromClass([HEPDeviceTableViewCell class]) bundle:nil]
           forCellReuseIdentifier:pillCellIdentifier];
    [[self tableView] setRowHeight:HEPDeviceTableViewCellHeight];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self stopScanningForServices];
    [self unregisterObservers];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self registerObservers];
    [self scanForServices];
}

- (void)dismissFromView
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Notification configuration

- (void)registerObservers
{
    CBCentralManager* manager = [HEPCBPeripheralManager sharedCentralManager];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(centralManagerUpdatedState:) name:HEPCBCentralManagerDidUpdateStateNotification object:manager];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(centralManagerConnectedPeripheral:) name:HEPCBCentralManagerDidConnectPeripheralNotification object:manager];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(centralManagerDiscoveredPeripheral:) name:HEPCBCentralManagerDidDiscoverPeripheralNotification object:manager];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(centralManagerFailedToConnectPeripheral:) name:HEPCBCentralManagerDidFailToConnectPeripheralNotification object:manager];
    [self addObserver:self
           forKeyPath:NSStringFromSelector(@selector(discoveredDevices))
              options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
              context:NULL];
}

- (void)unregisterObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeObserver:self forKeyPath:NSStringFromSelector(@selector(discoveredDevices))];
}

- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context
{
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(discoveredDevices))]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[self tableView] reloadData];
        });
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.discoveredDevices.count;
}

- (id)deviceAtIndexPath:(NSIndexPath*)indexPath
{
    return self.discoveredDevices[indexPath.row];
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    HEPDeviceTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:pillCellIdentifier forIndexPath:indexPath];
    CBPeripheral* device = [self deviceAtIndexPath:indexPath];
    cell.nameLabel.text = device.name;
    cell.identifierLabel.text = [device.identifier UUIDString];
    cell.signalStrengthLabel.text = [NSString stringWithFormat:NSLocalizedString(@"picker.peripheral.rssi.format", nil), self.discoveredDevicesRSSI[indexPath.row]];
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    CBPeripheral* device = [self deviceAtIndexPath:indexPath];
    [[HEPCBPeripheralManager sharedCentralManager] connectPeripheral:device options:nil];
}

#pragma mark - Central manager

- (BOOL)centralManagerIsPoweredOn
{
    return [HEPCBPeripheralManager sharedCentralManager].state == CBCentralManagerStatePoweredOn;
}

- (void)scanForServices
{
    if ([self centralManagerIsPoweredOn]) {
        [[HEPCBPeripheralManager sharedCentralManager] scanForPeripheralsWithServices:nil
                                                                              options:nil];
    }
}

- (void)stopScanningForServices
{
    if ([self centralManagerIsPoweredOn]) {
        [[HEPCBPeripheralManager sharedCentralManager] stopScan];
    }
}

- (void)centralManagerUpdatedState:(NSNotification*)notification
{
    if ([self centralManagerIsPoweredOn]) {
        [self scanForServices];
    }
}

- (void)centralManagerDiscoveredPeripheral:(NSNotification*)notification
{
    CBPeripheral* peripheral = notification.userInfo[HEPCBCentralManagerPeripheralKey];
    NSNumber* RSSI = notification.userInfo[HEPCBCentralManagerRSSIKey];
    if (peripheral.name.length > 0) {
        [self.discoveredDevicesRSSI addObject:RSSI];
        self.discoveredDevices = [self.discoveredDevices arrayByAddingObject:peripheral];
    }
}

- (void)centralManagerConnectedPeripheral:(NSNotification*)notification
{
    CBPeripheral* peripheral = notification.userInfo[HEPCBCentralManagerPeripheralKey];
    HEPDevice* device = [[HEPDevice alloc] initWithName:peripheral.name identifier:[peripheral.identifier UUIDString]];
    [HEPDeviceService addDevice:device];
    if (!self.deviceManager || ![self.deviceManager.peripheral isEqual:peripheral])
        self.deviceManager = [[HEPCBPeripheralManager alloc] initWithPeripheral:peripheral];
    [self dismissFromView];
}

- (void)centralManagerFailedToConnectPeripheral:(NSNotification*)notification
{
    CBPeripheral* peripheral = notification.userInfo[HEPCBCentralManagerPeripheralKey];
    NSString* errorDescription = notification.userInfo[NSLocalizedDescriptionKey];
    NSLog(@"Peripheral (%@) failed to connect: %@", peripheral.name, errorDescription);
}

@end
