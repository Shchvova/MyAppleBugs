//
//  OpenALStopStartAppDelegate.m
//  OpenALStopStart
//
//  Created by Eric Wing on 1/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "OpenALStopStartAppDelegate.h"
#import "OpenALStopStartViewController.h"

@interface OpenALStopStartAppDelegate ()
- (void) playSound;
@end


static void PlaybackFinishedCallback(ALint which_channel, ALuint al_source, ALmixer_Data* almixer_data, ALboolean finished_naturally, void* user_data)
{
	NSLog(@"callback");
}

@implementation OpenALStopStartAppDelegate

@synthesize window;
@synthesize viewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	ALmixer_Init(0, 0, 0);
	ALmixer_SetPlaybackFinishedCallback(PlaybackFinishedCallback, self);

	almixerData = ALmixer_LoadAll([[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"laser1.wav"] UTF8String], NO);
//	almixerData = ALmixer_LoadStream([[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"laser1.wav"] UTF8String], 4096, 2, 2, NO);
	ALuint channel = ALmixer_PlayChannelTimed(0, almixerData, 0, -1);
	ALmixer_PauseChannel(channel);
	// Uncommenting this in to force a wait allows things to work.
//	usleep(1000*1000);
	ALmixer_ResumeChannel(channel);
	
	
    [self.window addSubview:self.viewController.view];
	return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [self.viewController stopAnimation];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [self.viewController startAnimation];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [self.viewController stopAnimation];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Handle any background procedures not related to animation here.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Handle any foreground procedures not related to animation here.
}

- (void)dealloc
{
	[callbackTimer release];
	ALmixer_FreeData(almixerData);
	ALmixer_Quit();
    [viewController release];
    [window release];
    
    [super dealloc];
}

@end
