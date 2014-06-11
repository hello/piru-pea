//
//  HEPDeviceInfoViewController.m
//  Pea
//
//  Created by Delisa Mason on 6/11/14.
//  Copyright (c) 2014 Hello. All rights reserved.
//

#import "HEPDeviceInfoViewController.h"
#import "HEPDevice.h"

@interface HEPDeviceInfoViewController ()

@property (nonatomic, strong) HEPDevice* device;
@property (weak, nonatomic) IBOutlet UILabel* nameLabel;
@property (weak, nonatomic) IBOutlet UILabel* descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel* identifierLabel;
@property (weak, nonatomic) IBOutlet UILabel* dateLabel;
@property (weak, nonatomic) IBOutlet UIButton* calibrationButton;
@end

@implementation HEPDeviceInfoViewController

- (instancetype)initWithDevice:(HEPDevice*)device
{
    self = [super initWithNibName:NSStringFromClass([HEPDeviceInfoViewController class]) bundle:nil];
    if (self) {
        _device = device;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismiss)];
    self.title = NSLocalizedString(@"device-info.title", nil);
    self.nameLabel.text = self.device.name;
    self.descriptionLabel.text = NSLocalizedString(@"device-info.calibration.message", nil);
    self.identifierLabel.text = self.device.identifier;

    // TODO: read time from device
    self.dateLabel.text = [NSString stringWithFormat:NSLocalizedString(@"device-info.time.format", nil), [NSDate date]];
}

- (void)dismiss
{
    [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)calibrateDevice:(id)sender
{
}

@end
