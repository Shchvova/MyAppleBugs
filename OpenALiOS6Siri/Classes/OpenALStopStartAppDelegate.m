//
//  OpenALStopStartAppDelegate.m
//  OpenALStopStart
//
//  Created by Eric Wing on 1/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "OpenALStopStartAppDelegate.h"
#import "OpenALStopStartViewController.h"
#import "ALmixer.h"
#import <AudioToolbox/AudioToolbox.h>



@interface OpenALStopStartAppDelegate ()
@property(assign, nonatomic) bool audioSessionActive;
@property(assign, nonatomic, getter=isInInterruption) bool inInterruption;
- (void) beginInterruption;
- (void) endInterruption;
@end


// I suspect it doesn't handle interruptions because I couldn't find any audio session stuff in the code.
static void Internal_InterruptionCallback(void* user_data, UInt32 interruption_state)
{
	NSLog(@"Internal_InterruptionCallback: %d", interruption_state);
	OpenALStopStartAppDelegate* app_delegate = (OpenALStopStartAppDelegate*)user_data;
	if(kAudioSessionBeginInterruption == interruption_state)
	{
		[app_delegate beginInterruption];
		
	}
	else if(kAudioSessionEndInterruption == interruption_state)
	{
		[app_delegate endInterruption];
	}
}


static const char* CoreAudio_FourCCToString(int32_t error_code)
{
	static char return_string[16];
	uint32_t big_endian_code = htonl(error_code);
	char* big_endian_str = (char*)&big_endian_code;
	// see if it appears to be a 4-char-code
	if(isprint(big_endian_str[0])
	   && isprint(big_endian_str[1])
	   && isprint(big_endian_str[2])
	   && isprint (big_endian_str[3]))
	{
		return_string[0] = '\'';
		return_string[1] = big_endian_str[0];
		return_string[2] = big_endian_str[1];
		return_string[3] = big_endian_str[2];
		return_string[4] = big_endian_str[3];
		return_string[5] = '\'';
		return_string[6] = '\0';
	}
	else if(error_code > -200000 && error_code < 200000)
	{
		// no, format it as an integer
		snprintf(return_string, 16, "%d", error_code);
	}
	else
	{
		// no, format it as an integer but in hex
		snprintf(return_string, 16, "0x%x", error_code);
	}
	return return_string;
}


@implementation OpenALStopStartAppDelegate

@synthesize window;
@synthesize viewController;


// Apple doesn't have a GetSessionActive call so we must track this state ourselves.
// Corona must always go through this API for our values to remain consistent.
- (void) setAudioSessionActive:(bool)is_active
{
//	bool ret_flag = true;
	// This check will be a problem if we don't consistently go through this API.
	// But bypassing this check may have negative performance implications or worse, particularly if audio is currently playing.
//	if(is_active == _audioSessionActive)
//	{
//		return true;
//	}
	
	OSStatus the_error;
	if(is_active)
	{
		the_error = AudioSessionSetActive(is_active);
	}
	else
	{
		// New to iOS 4.0
		// This might allow things like the iPod player to resume if they were cut off when we took control of the audio session.
		the_error = AudioSessionSetActiveWithFlags(is_active, kAudioSessionSetActiveFlag_NotifyOthersOnDeactivation);
	}
	if(noErr != the_error)
	{
		NSLog(@"Error setting audio session active to %d! %s\n", is_active, CoreAudio_FourCCToString(the_error));
		// Not sure how to deal with failure. Sometimes failure means we are setting to an already existing state in which case
		// we don't want to return and set our shadow variable.
		// iOS 4/5 bug: A user leaving an app via notification center triggers a unnecessary resume/suspend event in Cocoa.
		// This event forces us to re-initialize the audio system on resume which seems to lead to breaking audio completely.
		// My theory is that Core Audio is trying to shutdown and reactivating OpenAL messes things up.
		// It turns out setting the Audio Session to active seems to always fail here so we might be able to use that as a workaround clue.
		// The problem is that setting the audio session to the currently set state (e.g. on when already on, off when already off) also triggers an error.
		// And since there is no GetActive() API, we can't know the state since Apple may change it for us on audio interruptions or 3rd party API calls may change the state behind our back. So relying on this flag too much will also cause problems. But in a single isolated case of an EndInterruption, this might just work.
//		ret_flag = false;
	}
	// Setting after call in case operation failed
//	_audioSessionActive = is_active;
//	return ret_flag;
}

- (void) beginInterruption
{
	NSLog(@"%@", NSStringFromSelector(_cmd));

	if(false == [self isInInterruption])
	{
		NSLog(@"beginning interruption");
		[self setInInterruption:true];
		ALmixer_PauseChannel(-1);
		ALmixer_BeginInterruption();
	}
	else
	{
		NSLog(@"Already in interruption");
	}
}

- (void) endInterruption
{
	NSLog(@"%@", NSStringFromSelector(_cmd));

	if(true == [self isInInterruption])
	{
		NSLog(@"ending interruption");

//		usleep(1000*100); // Seems to help in this test case, but not in the general case.
		[self setAudioSessionActive:true];
		ALmixer_EndInterruption();
		[self setInInterruption:false];
		ALmixer_ResumeChannel(-1);
	}
	else
	{
		NSLog(@"Already ended interruption");
	}

}

- (IBAction) playSound:(id)sender
{
	ALmixer_PlayChannelTimed(-1, almixerDataForButton, 0, -1);
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	NSLog(@"%@", NSStringFromSelector(_cmd));

	OSStatus the_error = AudioSessionInitialize(NULL, NULL, Internal_InterruptionCallback, self);
	if(noErr != the_error)
	{
		NSLog(@"Error initializing audio session! %s\n", CoreAudio_FourCCToString(the_error));
	}
	
	
	ALmixer_Init(0, 0, 0);

	almixerData = ALmixer_LoadAll([[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"laser1.wav"] UTF8String], NO);

//	almixerData = ALmixer_LoadStream([[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"battle_hymn_of_the_republic.mp3"] UTF8String], 0, 0, 0, 0, 0);
	
	almixerDataForButton = ALmixer_LoadAll([[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"laser1.wav"] UTF8String], NO);

	ALmixer_PlayChannelTimed(-1, almixerData, -1, -1);
    [self.window addSubview:self.viewController.view];
 
	return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	NSLog(@"%@", NSStringFromSelector(_cmd));
	[self beginInterruption];
    [self.viewController stopAnimation];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	NSLog(@"%@", NSStringFromSelector(_cmd));
	[self endInterruption];

    [self.viewController startAnimation];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	NSLog(@"%@", NSStringFromSelector(_cmd));
    [self.viewController stopAnimation];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	NSLog(@"%@", NSStringFromSelector(_cmd));
    // Handle any background procedures not related to animation here.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	NSLog(@"%@", NSStringFromSelector(_cmd));
    // Handle any foreground procedures not related to animation here.
}

- (void)dealloc
{
//	[callbackTimer release];
	ALmixer_FreeData(almixerData);
	ALmixer_Quit();
    [viewController release];
    [window release];
    
    [super dealloc];
}

@end
