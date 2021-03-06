/*
 * OpenRemote, the Home of the Digital Home.
 * Copyright 2008-2013, OpenRemote Inc.
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

#import "ORController.h"
#import "ORControllerAddress.h"
#import "ORSensorRegistry.h"
#import "ORSensorPollingManager.h"
#import "ORPanel.h"
#import "Definition.h"
#import "Label.h"

#import "ORLabel.h"

#import "ControllerREST_2_0_0_API.h"

@interface ORController ()

@property (strong, nonatomic) ORControllerAddress *address;
@property (nonatomic) BOOL connected;

@property (nonatomic, strong) ORSensorPollingManager *pollingManager;

@end

@implementation ORController

- (id)initWithControllerAddress:(ORControllerAddress *)anAddress
{
    self = [super init];
    if (self) {
        if (anAddress) {
            self.address = anAddress;
        } else {
            return nil;
        }
    }
    return self;
}

- (void)connectWithSuccessHandler:(void (^)(void))successHandler errorHandler:(void (^)(NSError *))errorHandler;
{
    // In this first version, we actually do not try to connect at this stage but wait for read configuration request
    
    // TODO: in next version, could fetch group members
    // TODO: in later version, this could be a good place to get the controller capabilities

    self.connected = YES;
    if (successHandler) {
        successHandler();
    }
}

- (void)disconnect
{
    if (self.pollingManager) {
        [self.pollingManager stop];
    }
    
    self.connected = NO;
}

- (BOOL)isConnected
{
    return self.connected;
}

- (void)requestPanelIdentityListWithSuccessHandler:(void (^)(NSArray *))successHandler errorHandler:(void (^)(NSError *))errorHandler
{
    // TODO: later based on information gathered during connect, would select the appropriate API/Object Model version
    
    ControllerREST_2_0_0_API *controllerAPI = [[ControllerREST_2_0_0_API alloc] init];
    
    [controllerAPI requestPanelIdentityListAtBaseURL:self.address.primaryURL
                                  withSuccessHandler:^(NSArray *panels) {
                                      successHandler(panels);
                                  }
                                        errorHandler:^(NSError *error) {
                                            if (errorHandler) {
                                                // TODO: encapsulate error ?
                                                errorHandler(error);
                                            }
                                        }];
}


// The returned Definition (should rename to PanelUILayout or something) will be connected to controller
// and update dynamically as required / instructed by controller.
// => this call should start the polling loop -> ORController object has responsibility for that -> should be a specific call for it / object dedicated to handling that
// Sensor registry is part of the PanelUILayout as it's a passive register, it basically maintains links
// Sensor update (cache ?) is part of ORController and has the logic to perform the updates based on values received
// Should the PanelUILayout contain the images / resources ?
- (void)requestPanelUILayout:(NSString *)panelName successHandler:(void (^)(Definition *))successHandler errorHandler:(void (^)(NSError *))errorHandler
{
    // TODO: what if not connected, how to handle that: either report as an error or try to connect
    // but define it, document it and test/handle as appropriate in this implementation
    
    // TODO: if we already had a configuration and sensor polling going, we need to stop it
    // Maybe wait to have received new configuration before doing it ?

    
    // TODO: this might be where the caching and resource fetching can take place ?
    
    ControllerREST_2_0_0_API *controllerAPI = [[ControllerREST_2_0_0_API alloc] init];
    
    [controllerAPI requestPanelLayoutWithLogicalName:panelName
                                           atBaseURL:self.address.primaryURL
                                  withSuccessHandler:^(Definition *panelDefinition) {
                                      if (self.pollingManager) {
                                          [self.pollingManager stop];
                                      }
                                      self.pollingManager = [[ORSensorPollingManager alloc] initWithControllerAPI:controllerAPI
                                                                                                controllerAddress:self.address
                                                                                                   sensorRegistry:panelDefinition.sensorRegistry];
                                      [self.pollingManager start];
                                      
                                      successHandler(panelDefinition);
                                  }
                                        errorHandler:^(NSError *error) {
                                            if (errorHandler) {
                                                // TODO: encapsulate error ?
                                                errorHandler(error);
                                            }
                                        }];
}

@end