//
//  HEPDevice.h
//  Pea
//
//  Created by Delisa Mason on 6/10/14.
//  Copyright (c) 2014 Hello. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HEPDevice : NSObject <NSCoding>

@property (nonatomic, strong, readonly) NSString* identifier;
@property (nonatomic, strong, readonly) NSString* name;
@property (nonatomic, getter=isRecordingData) BOOL recordingData;

- (instancetype)initWithName:(NSString*)name identifier:(NSString*)identifier;
@end
