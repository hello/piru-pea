//
//  HEPConnectedDeviceTableViewCell.h
//  Pea
//
//  Created by Delisa Mason on 6/10/14.
//  Copyright (c) 2014 Hello. All rights reserved.
//

#import <UIKit/UIKit.h>

extern CGFloat const HEPDeviceTableViewCellHeight;

@interface HEPDeviceTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel* nameLabel;
@property (weak, nonatomic) IBOutlet UILabel* identifierLabel;
@property (weak, nonatomic) IBOutlet UILabel* signalStrengthLabel;
@end
