
#import <LGBluetooth/LGBluetooth.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import <SenseKit/BLE.h>
#import <SenseKit/SENAuthorizationService.h>

#import "HEPSleepTrackerViewController.h"
#import "HEPAuthenticationViewController.h"
#import "HEPDevicePickerTableViewController.h"
#import "HEPConnectedDeviceTableViewController.h"

typedef void (^HEPPickDeviceBlock)(SENDevice* device);

@interface HEPSleepTrackerViewController () <UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UIButton* startTrackingButton;
@property (weak, nonatomic) IBOutlet UIButton* stopTrackingButton;
@property (nonatomic, strong) NSArray* devices;
@property (strong) HEPPickDeviceBlock pickDeviceBlock;
@end

@implementation HEPSleepTrackerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureNavigationBar];
    [self configureButtons];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (![SENAuthorizationService isAuthorized]) {
        [self presentNavigationControllerForViewController:[HEPAuthenticationViewController new]];
    } else if (![SENDeviceService hasDevices]) {
        [self searchForDevices];
    }
}

- (void)configureNavigationBar
{
    self.title = NSLocalizedString(@"tracker.title", nil);
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"tracker.config.title", nil) style:UIBarButtonItemStyleBordered target:self action:@selector(openConfig)];
}

- (void)configureButtons
{
    [self.startTrackingButton setTitle:NSLocalizedString(@"tracker.start.title", nil) forState:UIControlStateNormal];
    [self.stopTrackingButton setTitle:NSLocalizedString(@"tracker.stop.title", nil) forState:UIControlStateNormal];
    self.startTrackingButton.backgroundColor = [UIColor colorWithRed:0.1f green:0.7f blue:0.2f alpha:1.f];
    self.stopTrackingButton.backgroundColor = [UIColor redColor];
}

#pragma mark - Actions

- (IBAction)startTracking:(id)sender
{
    __weak typeof(self) weakSelf = self;
    [self pickDevice:^(SENDevice* device) {
        [weakSelf toggleDataCollectionState:YES forDevice:device];
    }];
}

- (IBAction)stopTracking:(id)sender
{
    __weak typeof(self) weakSelf = self;
    [self pickDevice:^(SENDevice* device) {
        [weakSelf toggleDataCollectionState:NO forDevice:device];
    }];
}

- (void)toggleDataCollectionState:(BOOL)shouldTrack forDevice:(SENDevice*)device
{
    if (!device)
        return;

    LGPeripheral* peripheral = [[[LGCentralManager sharedInstance] retrievePeripheralsWithIdentifiers:@[ [[NSUUID alloc] initWithUUIDString:device.identifier] ]] firstObject];
    SENPeripheralManager* manager = [[SENPeripheralManager alloc] initWithPeripheral:peripheral];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
    void (^completion)(NSError*) = ^(NSError *error) {
        if (error) {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            return;
        }
        [SVProgressHUD dismiss];
        if (!shouldTrack)
            [manager fetchDataWithCompletion:NULL];
    };
    if (shouldTrack) {
        [manager startDataCollectionWithCompletion:completion];
    } else {
        [manager stopDataCollectionWithCompletion:completion];
    }
}

- (void)openConfig
{
    [self presentNavigationControllerForViewController:[[HEPConnectedDeviceTableViewController alloc] init]];
}

- (void)searchForDevices
{
    [self presentNavigationControllerForViewController:[[HEPDevicePickerTableViewController alloc] init]];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet*)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (!self.pickDeviceBlock || buttonIndex > (self.devices.count - 1))
        return;

    self.pickDeviceBlock(self.devices[buttonIndex]);
}

#pragma mark - Private

- (void)presentNavigationControllerForViewController:(UIViewController*)aController
{
    UINavigationController* controller = [[UINavigationController alloc] initWithRootViewController:aController];
    [self.navigationController presentViewController:controller animated:YES completion:NULL];
}

- (void)pickDevice:(HEPPickDeviceBlock)callback
{
    if (!callback)
        return;

    self.devices = [SENDeviceService archivedDevices];
    switch (self.devices.count) {
    case 0:
        [self searchForDevices];
        break;
    case 1:
        callback([self.devices firstObject]);
        break;
    default: {
        self.pickDeviceBlock = callback;
        UIActionSheet* sheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"tracker.pick-device.message", nil)
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                             destructiveButtonTitle:nil
                                                  otherButtonTitles:nil];

        for (SENDevice* device in self.devices) {
            [sheet addButtonWithTitle:device.nickname];
        }
        [sheet addButtonWithTitle:NSLocalizedString(@"actions.cancel", nil)];
        sheet.cancelButtonIndex = self.devices.count;
        [sheet showInView:self.view];
    }
    }
}

@end
