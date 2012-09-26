//
//  OpenALStopStartAppDelegate.h
//  OpenALStopStart
//
//  Created by Eric Wing on 1/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "ALmixer.h"

@class OpenALStopStartViewController;

@interface OpenALStopStartAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    OpenALStopStartViewController *viewController;
	ALmixer_Data* almixerData;
	NSTimer* callbackTimer;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet OpenALStopStartViewController *viewController;


@end

