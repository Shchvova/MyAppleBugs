//
//  AppDelegate.m
//  OpenALPauseResumeMac
//
//  Created by Eric Wing on 8/28/12.
//  Copyright (c) 2012 Eric Wing. All rights reserved.
//

#import "AppDelegate.h"
#include "ALmixer.h"

static void PlaybackFinishedCallback(ALint which_channel, ALuint al_source, ALmixer_Data* almixer_data, ALboolean finished_naturally, void* user_data)
{
	NSLog(@"callback");
}


@implementation AppDelegate
{
	ALmixer_Data* almixerData;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
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
	
	
}


@end
