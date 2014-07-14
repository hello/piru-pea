
#import <LGBluetooth/LGBluetooth.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import <SenseKit/BLE.h>

#import "HEPDeviceInfoViewController.h"

@interface HEPDeviceInfoViewController ()

@property (nonatomic, strong) SENDevice* device;
@property (nonatomic, strong) SENPeripheralManager* manager;
@property (weak, nonatomic) IBOutlet UILabel* nameLabel;
@property (weak, nonatomic) IBOutlet UILabel* descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel* identifierLabel;
@property (weak, nonatomic) IBOutlet UILabel* dateLabel;
@property (weak, nonatomic) IBOutlet UIButton* calibrationButton;
@end

@implementation HEPDeviceInfoViewController

- (instancetype)initWithDevice:(SENDevice*)device
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
    self.title = NSLocalizedString(@"device-info.title", nil);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismiss)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshDevice];
}

- (void)refreshDevice
{
    self.device = [SENDeviceService deviceWithIdentifier:self.device.identifier];
    NSUUID* deviceUUID = [[NSUUID alloc] initWithUUIDString:self.device.identifier];
    LGPeripheral* peripheral = [[[LGCentralManager sharedInstance] retrievePeripheralsWithIdentifiers:@[ deviceUUID ]] firstObject];
    self.manager = [[SENPeripheralManager alloc] initWithPeripheral:peripheral];
    self.nameLabel.text = self.device.nickname;
    self.descriptionLabel.text = NSLocalizedString(@"device-info.calibration.message", nil);
    self.identifierLabel.text = self.device.identifier;
    self.dateLabel.text = [NSString stringWithFormat:NSLocalizedString(@"device-info.time.format", nil), self.device.date];
}

- (void)dismiss
{
    [self.manager disconnectWithCompletion:^(NSError* error) {
        [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
    }];
}

- (IBAction)calibrateDevice:(id)sender
{
    [SVProgressHUD showWithStatus:NSLocalizedString(@"device-info.action.calibrate.loading-message", nil) maskType:SVProgressHUDMaskTypeBlack];
    [self.manager writeCurrentTimeWithCompletion:^(NSError* error) {
        if (error) {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            return;
        }
        [self.manager calibrateWithCompletion:^(NSError* error) {
            if (error) {
                [SVProgressHUD showErrorWithStatus:error.localizedDescription];
                return;
            }
            [self refreshDevice];
            [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"status.success", nil)];
        }];
    }];
}

@end
