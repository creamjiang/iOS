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

#import <SenTestingKit/SenTestingKit.h>
#import "ORObjectIdentifier.h"
#import "ORLabel.h"

#define SOME_TEXT @"Some text"
#define SOME_OTHER_TEXT @"Some other text"

@interface ORLabelTest : SenTestCase

@property (nonatomic, strong) ORLabel *label;

@end

@implementation ORLabelTest

- (void)setUp
{
    self.label = [[ORLabel alloc] initWithIdentifier:[[ORObjectIdentifier alloc] initWithIntegerId:1] text:SOME_TEXT];
}

- (void)tearDown
{
    self.label = nil;
}

/**
 * Validates that initializer does return object with text property set as expected.
 */
- (void)testInitDoesSetTextCorrectly
{
    STAssertNotNil(self.label, @"Label should have been instantied correctly");
    STAssertEqualObjects(SOME_TEXT, self.label.text, @"Text property of label should be one set by initializer");
}

/**
 * Validates that KVO is triggered with appropriate value when label text property is changed.
 */
- (void)testKVOWhenSettingLabelText
{
    [self.label addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionNew context:NULL];
    self.label.text = SOME_OTHER_TEXT;
    [self.label removeObserver:self forKeyPath:@"text"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    STAssertEqualObjects(self.label, object, @"Should observe change for label");
    if ([@"text" isEqualToString:keyPath]) {
        STAssertEqualObjects(SOME_OTHER_TEXT, [change valueForKey:NSKeyValueChangeNewKey], @"Observed new value should be newly set label text");
    }
}

@end