//
//  SettingsController.m
//  routeConcepts
//
//  Created by Fabian Girolstein on 24.07.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Utils.h"
#import "RootViewController.h"
#import "routeConceptsAppDelegate.h"
#import "SettingsController.h"

#import "CloudMadeView.h"
#import "CloudMadeMapView.h"


NSString* const settingsChangedNotification = @"go";

@implementation SettingsController

@synthesize settingsNavigationItem;

- (IBAction) goThere:(id)sender
{	
	Utils* myUtils = [Utils sharedInstance];
		
	[myUtils setNewLatitude:[latitudeEntry.text floatValue]];
	[myUtils setNewLongitude:[longitudeEntry.text floatValue]];
	
	// Notification
	NSNotificationCenter* center;
	center = [NSNotificationCenter defaultCenter];
	[center postNotificationName:settingsChangedNotification object:self];
	
	// Pop to RootViewController
//	[[self navigationController] popViewControllerAnimated:YES];
	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction) cancel:(id)sender
{	
	// Pop to RootViewController
//	[[self navigationController] popViewControllerAnimated:YES];
	[self dismissModalViewControllerAnimated:YES];
}

- (id) init
{
	if (self = [super init]) 
	{
		self.title = @"Settings";
	}
	return self;
}

- (void) loadView
{
//	[self.navigationController setNavigationBarHidden:NO animated:YES];
	
	[[NSBundle mainBundle] loadNibNamed:@"Settings" owner:self options:nil];

	settingsNavigationBar = [[UINavigationBar alloc] init];
	settingsNavigationItem = [[UINavigationItem alloc] init];
	settingsNavigationBar.barStyle = UIBarStyleBlackTranslucent;
	
	[settingsNavigationBar sizeToFit];
	[settingsNavigationBar setFrame:CGRectMake(0.0, 0.0, 320.0, 44.0)];
	
	UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
															   style:UIBarButtonItemStylePlain
															  target:self
															  action:@selector(destroy)];
	settingsNavigationItem.title = @"Settings";
	settingsNavigationItem.rightBarButtonItem = doneButton;
	[settingsNavigationBar pushNavigationItem:settingsNavigationItem animated:YES];
	[self.view addSubview:settingsNavigationBar];
	

}

- (void) destroy
{
	[self dismissModalViewControllerAnimated:YES];
}

- (BOOL) textFieldShouldReturn:(UITextField*)theTextField 
{	
	[theTextField resignFirstResponder];
	return YES;
}

- (void)dealloc 
{
    [super dealloc];
}


@end
