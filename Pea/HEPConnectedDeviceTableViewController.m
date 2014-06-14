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
#import "HEPActionTableViewCell.h"
#import "HEPAuthorizationService.h"
#import "HEPDeviceService.h"
#import "HEPDevice.h"

static NSString* const HEPConnectedDeviceCellIdentifier = @"HEPConnectedDeviceCellIdentifier";
static NSString* const HEPActionCellIdentifier = @"HEPActionCellIdentifier";

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
    [self configureNavigationBar];
    [self configureTableView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.devices = [HEPDeviceService archivedDevices];
}

- (void)configureNavigationBar
{
    self.title = NSLocalizedString(@"device-list.title", nil);
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addDevice)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(closeView)];
}

- (void)configureTableView
{
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([HEPDeviceTableViewCell class]) bundle:nil] forCellReuseIdentifier:HEPConnectedDeviceCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([HEPActionTableViewCell class]) bundle:nil] forCellReuseIdentifier:HEPActionCellIdentifier];
    self.tableView.rowHeight = HEPDeviceTableViewCellHeight;
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

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return section == 0 ? self.devices.count : 1;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (indexPath.section == 0) {
        HEPDeviceTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:HEPConnectedDeviceCellIdentifier forIndexPath:indexPath];
        HEPDevice* device = [self deviceAtIndexPath:indexPath];
        cell.nameLabel.text = device.nickname;
        cell.identifierLabel.text = device.identifier;
        cell.signalStrengthLabel.text = nil;
        return cell;
    } else if (indexPath.section == 1) {
        HEPActionTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:HEPActionCellIdentifier forIndexPath:indexPath];
        cell.actionLabel.text = NSLocalizedString(@"actions.sign-out", nil);
        cell.actionLabel.textColor = [UIColor redColor];
        return cell;
    }
    return nil;
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

- (NSString*)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
    case 0:
        return NSLocalizedString(@"device-list.devices.title", nil);
    default:
        return @"";
    }
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return indexPath.section == 0 ? HEPDeviceTableViewCellHeight : 44.f;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (indexPath.section == 0) {
        HEPDevice* device = [self deviceAtIndexPath:indexPath];
        UINavigationController* wrapper = [[UINavigationController alloc] initWithRootViewController:[[HEPDeviceInfoViewController alloc] initWithDevice:device]];
        [self.navigationController presentViewController:wrapper animated:YES completion:NULL];
    } else if (indexPath.section == 1) {
        [HEPAuthorizationService deauthorize];
        [self closeView];
    }
}

@end
