
#import <SenseKit/SENAuthorizationService.h>
#import <SenseKit/BLE.h>

#import "HEPConnectedDeviceTableViewController.h"
#import "HEPDevicePickerTableViewController.h"
#import "HEPDeviceInfoViewController.h"
#import "HEPDeviceTableViewCell.h"
#import "HEPActionTableViewCell.h"

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
    self.devices = [SENDeviceService archivedDevices];
}

- (void)configureNavigationBar
{
    self.title = NSLocalizedString(@"device-list.title", nil);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(closeView)];
}

- (void)configureTableView
{
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([HEPDeviceTableViewCell class]) bundle:nil] forCellReuseIdentifier:HEPConnectedDeviceCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([HEPActionTableViewCell class]) bundle:nil] forCellReuseIdentifier:HEPActionCellIdentifier];
    self.tableView.rowHeight = HEPDeviceTableViewCellHeight;
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 20.f, 0, 20.f);
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

- (BOOL)isDeviceIndexPath:(NSIndexPath*)indexPath
{
    return indexPath.section == 0 && indexPath.row < self.devices.count;
}

- (SENDevice*)deviceAtIndexPath:(NSIndexPath*)indexPath
{
    return self.devices[indexPath.row];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return section == 0 ? (self.devices.count + 1) : 1;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    if ([self isDeviceIndexPath:indexPath]) {
        HEPDeviceTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:HEPConnectedDeviceCellIdentifier forIndexPath:indexPath];
        SENDevice* device = [self deviceAtIndexPath:indexPath];
        cell.nameLabel.text = device.nickname;
        cell.identifierLabel.text = device.identifier;
        cell.signalStrengthLabel.text = nil;
        return cell;
    } else if (indexPath.section == 0) {
        HEPActionTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:HEPActionCellIdentifier forIndexPath:indexPath];
        cell.actionLabel.text = NSLocalizedString(@"picker.title", nil);
        cell.actionLabel.textColor = self.navigationController.navigationBar.tintColor;
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
    return [self isDeviceIndexPath:indexPath];
}

- (void)tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        SENDevice* device = [self deviceAtIndexPath:indexPath];
        [SENDeviceService removeDevice:device];
        self.devices = [SENDeviceService archivedDevices];
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
    return [self isDeviceIndexPath:indexPath] ? HEPDeviceTableViewCellHeight : 44.f;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    if ([self isDeviceIndexPath:indexPath]) {
        SENDevice* device = [self deviceAtIndexPath:indexPath];
        UINavigationController* wrapper = [[UINavigationController alloc] initWithRootViewController:[[HEPDeviceInfoViewController alloc] initWithDevice:device]];
        [self.navigationController presentViewController:wrapper animated:YES completion:NULL];
    } else if (indexPath.section == 0) {
        [self addDevice];
    } else if (indexPath.section == 1) {
        [SENAuthorizationService deauthorize];
        [self closeView];
    }
}

@end
