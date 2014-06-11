//
//  HEPConnectedDeviceTableViewController.m
//  Pea
//
//  Created by Delisa Mason on 6/10/14.
//  Copyright (c) 2014 Hello. All rights reserved.
//

#import "HEPConnectedDeviceTableViewController.h"
#import "HEPDevicePickerTableViewController.h"
#import "HEPDeviceInfoViewController.h"
#import "HEPDeviceTableViewCell.h"
#import "HEPDeviceService.h"
#import "HEPDevice.h"

static NSString* const HEPConnectedDeviceCellIdentifier = @"HEPConnectedDeviceCellIdentifier";

@interface HEPConnectedDeviceTableViewController ()

@property (nonatomic, strong) NSArray* devices;
@end

@implementation HEPConnectedDeviceTableViewController

- (id)init
{
    self = [super initWithNibName:NSStringFromClass([HEPConnectedDeviceTableViewController class]) bundle:nil];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"device-list.title", nil);
    self.devices = [HEPDeviceService archivedDevices];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([HEPDeviceTableViewCell class]) bundle:nil] forCellReuseIdentifier:HEPConnectedDeviceCellIdentifier];
    self.tableView.rowHeight = HEPDeviceTableViewCellHeight;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addDevice)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(closeView)];
}

#pragma mark - Actions

- (void)addDevice
{
    [self.navigationController pushViewController:[HEPDevicePickerTableViewController new] animated:YES];
}

- (void)closeView
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Table view data source

- (HEPDevice*)deviceAtIndexPath:(NSIndexPath*)indexPath
{
    return self.devices[indexPath.row];
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.devices.count;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    HEPDeviceTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:HEPConnectedDeviceCellIdentifier forIndexPath:indexPath];
    HEPDevice* device = [self deviceAtIndexPath:indexPath];
    cell.nameLabel.text = device.name;
    cell.identifierLabel.text = device.identifier;
    cell.signalStrengthLabel.text = nil;
    return cell;
}

- (BOOL)tableView:(UITableView*)tableView canEditRowAtIndexPath:(NSIndexPath*)indexPath
{
    return YES;
}

- (void)tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        HEPDevice* device = [self deviceAtIndexPath:indexPath];
        [HEPDeviceService removeDevice:device];
        self.devices = [HEPDeviceService archivedDevices];
        [tableView deleteRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    HEPDevice* device = [self deviceAtIndexPath:indexPath];
    UINavigationController* wrapper = [[UINavigationController alloc] initWithRootViewController:[[HEPDeviceInfoViewController alloc] initWithDevice:device]];
    [self.navigationController presentViewController:wrapper animated:YES completion:NULL];
}

@end
