//
//  HEPDevice.m
//  Pea
//
//  Created by Delisa Mason on 6/10/14.
//  Copyright (c) 2014 Hello. All rights reserved.
//

#import "HEPDevice.h"

static NSString* const IDENTIFIER_KEY = @"identifier";
static NSString* const NAME_KEY = @"name";

@implementation HEPDevice

- (instancetype)initWithName:(NSString *)name identifier:(NSString *)identifier {
    if (self = [super init]) {
        _identifier = identifier;
        _name = name;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _identifier = [aDecoder decodeObjectForKey:IDENTIFIER_KEY];
        _name = [aDecoder decodeObjectForKey:NAME_KEY];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.identifier forKey:IDENTIFIER_KEY];
    [aCoder encodeObject:self.name forKey:NAME_KEY];
}

@end
