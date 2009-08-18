//
//  routeConceptsAppDelegate.m
//  routeConcepts
//
//  Created by Fabian Girolstein on 24.07.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//


#import "routeConceptsAppDelegate.h"
#import "RootViewController.h"
#import "SettingsController.h"
#import "ChooseMapStyle.h"

@class SettingsController;

@implementation routeConceptsAppDelegate

@synthesize window;
@synthesize navigationController;


- (void)applicationDidFinishLaunching:(UIApplication *)application
{
    RootViewController* rootController = [[RootViewController alloc] init];
    navigationController = [[UINavigationController alloc] initWithRootViewController:rootController ];
	
	self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
	[self.navigationController setNavigationBarHidden:YES];
	
    // Configure and show the window
    [window addSubview:[navigationController view]];
    [window makeKeyAndVisible];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	// Save data if appropriate
}


- (void)dealloc {
	[navigationController release];
	[window release];
	[super dealloc];
}

@end


