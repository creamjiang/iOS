/*
 * OpenRemote, the Home of the Digital Home.
 * Copyright 2008-2012, OpenRemote Inc.
 *
 * See the contributors.txt file in the distribution for a
 * full listing of individual contributors.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
#import "ORControllerPollingSender.h"
#import "ServerDefinition.h"
#import "UIDevice+UDID.h"

@interface ORControllerPollingSender ()

@property (nonatomic, retain) ORControllerConfig *controller;
@property (nonatomic, retain) NSString *ids;
@property (nonatomic, retain) ControllerRequest *controllerRequest;

@end

@implementation ORControllerPollingSender

- (void)send
{
    NSAssert(!self.controllerRequest, @"ORControllerPollingSender can only be used to send a request once");
    
    NSString *deviceId = [[UIDevice currentDevice] uniqueID];
    NSString *urlPath = [[ServerDefinition controllerPollingPathForController:self.controller] stringByAppendingFormat:@"/%@/%@", deviceId, self.ids];
    self.controllerRequest = [[[ControllerRequest alloc] initWithController:self.controller] autorelease];
    self.controllerRequest.delegate = self;
    [self.controllerRequest getRequestWithPath:urlPath];
}

@synthesize controller;
@synthesize ids;
@synthesize controllerRequest;

@end