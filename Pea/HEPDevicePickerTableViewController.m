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

static NSString* const pillUUIDString = @"0000E110-1212-EFDE-1523-785FEABCD123";
static NSString* const pillCellIdentifier = @"pillCell";

@interface HEPDevicePickerTableViewController ()<CBCentralManagerDelegate>

@property (nonatomic,strong,readonly) CBCentralManager *centralManager;
@property (nonatomic,strong) NSArray* discoveredDevices;
@end

@implementation HEPDevicePickerTableViewController

+ (dispatch_queue_t)centralManagerQueue {
    static dispatch_queue_t queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create("co.hello.device_picker", DISPATCH_QUEUE_CONCURRENT);
    });
    return queue;
}

- (id)init {
    if (self = [super initWithStyle:UITableViewStylePlain]) {
        _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:[HEPDevicePickerTableViewController centralManagerQueue]];
        _discoveredDevices = @[];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self tableView] registerClass:[UITableViewCell class]
             forCellReuseIdentifier:pillCellIdentifier];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self unregisterObservers];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self registerObservers];
    [self scanForServices];
}

- (void)registerObservers {
    [self addObserver:self
           forKeyPath:NSStringFromSelector(@selector(discoveredDevices))
              options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew
              context:NULL];
}

- (void)unregisterObservers {
    [self removeObserver:self forKeyPath:NSStringFromSelector(@selector(discoveredDevices))];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(discoveredDevices))]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[self tableView] reloadData];
        });
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == 0 ? self.discoveredDevices.count : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:pillCellIdentifier forIndexPath:indexPath];
    CBPeripheral* device = self.discoveredDevices[indexPath.row];
    cell.textLabel.text = device.name;
    return cell;
}

#pragma mark - Central manager

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
}

- (void)scanForServices {
    [self centralManager]
    [[self centralManager] scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:pillUUIDString]]
                                                  options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@YES}];
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    self.discoveredDevices = [self.discoveredDevices arrayByAddingObject:peripheral];
}

@end
