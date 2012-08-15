//
//  AppDelegate.m
//  IKImageViewTest
//
//  Created by Eric Wing on 8/14/12.
//  Copyright (c) 2012 test. All rights reserved.
//

#import "AppDelegate.h"
#import "MyImageView.h"

@interface AppDelegate ()
{
	IKImageView* myImageView;
//	MyImageView* myImageView;
	bool isLoading;
}
@property(nonatomic, retain) IKImageView* myImageView;
//@property(nonatomic, retain) MyImageView* myImageView;
@end

@implementation AppDelegate

- (void)dealloc
{
	[myImageView release];
    [super dealloc];
}

- (void) loadImage
{
	NSView* content_view = [[self window] contentView];

	[self setMyImageView:[[[IKImageView alloc] initWithFrame:NSMakeRect(0, 0, 1536/16, 2048/16)] autorelease] ];
//	[self setMyImageView:[[[MyImageView alloc] initWithFrame:NSMakeRect(-1000, 50, 2*1536, 2048)] autorelease] ];
	NSString* fullpath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"iPadRetina.png"];
	NSURL* urlpath = [NSURL fileURLWithPath:fullpath];
	[[self myImageView] setImageWithURL:urlpath];
	
	[content_view addSubview:[self myImageView]];
	isLoading = NO;
}
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	// Insert code here to initialize your application
	[self loadImage];
}

- (IBAction)reload:(id)the_sender
{
	if(isLoading)
	{
		return;
	}
	[[self myImageView] removeFromSuperview];
//	[[self myImageView] setImage:nil imageProperties:nil];
	[[self myImageView] setImageWithURL:nil];

	[self setMyImageView:nil];
	isLoading = YES;
	[self performSelector:@selector(loadImage) withObject:nil afterDelay:0.25];
//	[self loadImage];
}
- (IBAction)unload:(id)sender {
	[[self myImageView] removeFromSuperview];
	//	[[self myImageView] setImage:nil imageProperties:nil];
	[[self myImageView] setImageWithURL:nil];
	
	[self setMyImageView:nil];
}
- (IBAction)load:(id)sender {
	[self loadImage];

}

@end
