//
//  AppDelegate.m
//  RotateViewOld
//
//  Created by Eric Wing on 9/7/12.
//  Copyright (c) 2012 test. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)dealloc
{
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	// Insert code here to initialize your application
}

- (IBAction)rotate:(id)sender
{
	[[[self someView] animator] setFrameCenterRotation:[[self someView] frameCenterRotation] + 90.0];

}
@end
