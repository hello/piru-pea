//
//  HEPSleepTrackerViewController.m
//  Pea
//
//  Created by Delisa Mason on 6/10/14.
//  Copyright (c) 2014 Hello. All rights reserved.
//
#import <LGBluetooth/LGBluetooth.h>

#import "HEPDevice.h"
#import "HEPDeviceService.h"
#import "HEPSleepTrackerViewController.h"
#import "HEPAuthorizationService.h"
#import "HEPDeviceService.h"
#import "HEPAuthenticationViewController.h"
#import "HEPDevicePickerTableViewController.h"
#import "HEPConnectedDeviceTableViewController.h"

@interface HEPSleepTrackerViewController () <UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UIButton* startTrackingButton;
@property (weak, nonatomic) IBOutlet UIButton* stopTrackingButton;
@end

@implementation HEPSleepTrackerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"tracker.title", nil);
    UIBarButtonItem* configItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"tracker.config.title", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(openConfig)];
    UIBarButtonItem* signOutItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"tracker.sign-out.title", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(signOut)];
    self.navigationItem.rightBarButtonItem = configItem;
    self.navigationItem.leftBarButtonItem = signOutItem;
    self.startTrackingButton.backgroundColor = [UIColor colorWithRed:0.1f green:0.7f blue:0.2f alpha:1.f];
    self.stopTrackingButton.backgroundColor = [UIColor redColor];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (![HEPDeviceService hasDevices]) {
        [self presentNavigationControllerForViewController:[[HEPDevicePickerTableViewController alloc] init]];
    }
}

- (IBAction)startTracking:(id)sender
{
    [self pickDevice:^(HEPDevice* device) {}];
}

- (IBAction)stopTracking:(id)sender
{
}

- (void)openConfig
{
    [self presentNavigationControllerForViewController:[[HEPConnectedDeviceTableViewController alloc] init]];
}

- (void)signOut
{
    [HEPAuthorizationService deauthorize];
    [self presentNavigationControllerForViewController:[[HEPAuthenticationViewController alloc] init]];
}

- (void)presentNavigationControllerForViewController:(UIViewController*)aController
{
    UINavigationController* controller = [[UINavigationController alloc] initWithRootViewController:aController];
    [self.navigationController presentViewController:controller animated:YES completion:NULL];
}

- (void)pickDevice:(void (^)(HEPDevice*))callback
{
    UIActionSheet* sheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"tracker.pick-device.message", nil)
                                                       delegate:self
                                              cancelButtonTitle:nil
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:nil];
    NSArray* devices = [HEPDeviceService archivedDevices];
    for (HEPDevice* device in devices) {
        [sheet addButtonWithTitle:device.name];
    }
    [sheet addButtonWithTitle:NSLocalizedString(@"actions.cancel", nil)];
    sheet.cancelButtonIndex = devices.count;
    [sheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet*)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
}

@end
