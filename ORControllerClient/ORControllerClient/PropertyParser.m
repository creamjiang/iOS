//
//  PropertyParser.m
//  openremote
//
//  Created by Eric Bariaux on 04/05/12.
//  Copyright (c) 2012 OpenRemote, Inc. All rights reserved.
//

#import "PropertyParser.h"

@interface PropertyParser()

@property (nonatomic, strong, readwrite) NSString *name;
@property (nonatomic, strong, readwrite) NSString *value;

@end

@implementation PropertyParser

- (id)initWithRegister:(DefinitionElementParserRegister *)aRegister attributes:(NSDictionary *)attributeDict
{
    self = [super initWithRegister:aRegister attributes:attributeDict];
    if (self) {
        self.name = [attributeDict valueForKey:@"name"];
        self.value = [attributeDict valueForKey:@"value"];
    }
    return self;
}

@synthesize name;
@synthesize value;

@end