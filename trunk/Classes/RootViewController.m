//
//  RootViewController.m
//  routeConcepts
//
//  Created by Fabian Girolstein on 24.07.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Utils.h"
#import "UIProgressHUD.h"
#import "RootViewController.h"
#import "SettingsController.h"
#import "routeConceptsAppDelegate.h"
#import "HelperConstant.h"

#import "CloudMadeView.h"
#import "CloudMadeMapView.h"

#import "PlaceMarker.h"
#import <QuartzCore/QuartzCore.h>

@implementation RootViewController

@synthesize mapStyleView;
@synthesize markerInfoView;

int notificationCenterCount = 0;
int idxCount = 0;

- (void) killHUD:(id) aHUD
{
	[aHUD show:NO];
	[aHUD release];
}

- (void) presentHUD
{
	Utils* myUtils = [Utils sharedInstance];
	id HUD = [[UIProgressHUD alloc] initWithWindow:[self.view superview]];
	[HUD setText:@"Retrieving actual position"];
	[HUD show:YES];
	[myUtils setHUDid:HUD];
	
}

//- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//	
//	switch (buttonIndex) 
//	{
//        case 0:
//		{
//            [mapView markPlace:LATITUDE :LONGITUDE :nil];
//			idxCount++;
//        } break;
//            
//        case 1:
//		{
//			if (idxCount > 0 )
//			{
//				idxCount--;
//				[mapView removeMarkerByIdx:idxCount];
//			}
//        } break;
//            
//        default:
//		{
//		} break;
//    }
//	
//	[actionSheet release];
//}

- (void) setMarker
{
	[mapView markPlace:LATITUDE :LONGITUDE :nil];
	idxCount++;
}

- (void) presentMarkerInfo
{
	[self.markerInfoView presentView];
}

-(id) init
{
    if(self=[super init])
    {
		// Increase NotificationCenter Count
		notificationCenterCount++;
		
		if (notificationCenterCount <= 1)
		{
			// Notification Center
			NSNotificationCenter* center;
			center = [NSNotificationCenter defaultCenter];
			[center addObserver:self selector:@selector(settingsChangedNotification:) name:settingsChangedNotification object:nil];
			[center addObserver:self selector:@selector(mapStyleChangedNotification:) name:mapStyleChangedNotification object:nil];
		}
    }
	return self;
}

-(void) loadView
{	
	struct MapSettings mapsettings =  CreateMapSettings(BASEURL,APIKEY,STILEID,TILE_SIZE,ZOOM,BUSEGPS,LATITUDE,LONGITUDE,DEFAULT_TILESERVER,SUBDOMAINS,WIDTH,HEIGHT);

    mapView = [[[CloudMadeView alloc] InitWithMap:[[UIScreen mainScreen] bounds] : mapsettings] autorelease];
    mapView.tag = 3;
    self.view = mapView;
	
	/*
	 Toolbar
	*/
	// Initialize Toolbar
	toolbar = [[UIToolbar alloc] init];
	toolbar.barStyle = UIBarStyleBlackTranslucent;
	
	[toolbar setFrame:CGRectMake(0.0, -44.0, 320.0, 44.0)];
	
	// Create FlexibleSpace and Button in Toolbar
	UIBarButtonItem* spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	
	UIBarButtonItem* infoButton = [[UIBarButtonItem alloc] initWithTitle:@"Info"
																   style:UIBarButtonItemStyleBordered
																  target:self 
																  action:@selector(infoClicked)];
	
	UIBarButtonItem* settingsButton = [[UIBarButtonItem alloc] initWithTitle:@"Settings"
																	   style:UIBarButtonItemStyleBordered
																	  target:self 
																	  action:@selector(switch:)];
	
	UIBarButtonItem* markerButton = [[[UIBarButtonItem alloc] initWithTitle:@"Marker"
																	   style:UIBarButtonItemStyleBordered
																	  target:self 
																	  action:@selector(setMarker)] autorelease];
	
	UIBarButtonItem* findMe = [[UIBarButtonItem alloc] initWithTitle:@"Find me"
															   style:UIBarButtonItemStyleBordered
															  target:self
															  action:@selector(findMe)];
	
	[toolbar setItems:[NSArray arrayWithObjects: markerButton, findMe, spacer, infoButton, settingsButton, nil]];
	
	[self.view addSubview:toolbar];
	
	/*
	 Menu Button
	*/
	UIButton* menuButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] initWithFrame:CGRectMake(110.0, -20.0, 100.0, 50.0)];
	[menuButton addTarget:self action:@selector(menuClicked) forControlEvents:UIControlEventTouchUpInside];
	[menuButton setTag:100];
	menuButton.alpha = 0.5;
	[self.view addSubview:menuButton];
	
	UILabel* menuLabel = [[UILabel alloc] initWithFrame:CGRectMake(115.0, 5.0, 90.0, 20.0)];
	menuLabel.text = @"Menu";
	menuLabel.backgroundColor = [UIColor clearColor];
	[menuLabel setTextAlignment:UITextAlignmentCenter];
	[menuLabel setTag:101];
	[self.view addSubview:menuLabel];
	
	/*
	 Zoom In Button
	*/
	UIButton* zoomInButton = [[UIButton buttonWithType:UIButtonTypeCustom] initWithFrame:CGRectMake(0.0, 0.0, 32.0, 32.0)];
	[zoomInButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"search_add.png"]] forState:UIControlStateNormal];
	[zoomInButton setCenter:CGPointMake(290.0, 20.0)];
	[zoomInButton setTag:102];
	[zoomInButton addTarget:self action:@selector(zoomInWithButton) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:zoomInButton];
	
	/*
	 Zoom Out Button
	 */
	UIButton* zoomOutButton = [[UIButton buttonWithType:UIButtonTypeCustom] initWithFrame:CGRectMake(0.0, 0.0, 32.0, 32.0)];
	[zoomOutButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"search_remove.png"]] forState:UIControlStateNormal];	
	[zoomOutButton setCenter:CGPointMake(30.0, 20.0)];
	[zoomOutButton setTag:103];
	[zoomOutButton addTarget:self action:@selector(zoomOutWithButton) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:zoomOutButton];
	
	/*
	 Map Style View
	*/
	self.mapStyleView = [[ChooseMapStyle alloc] initWithFrame:CGRectMake(300.0f, 290.0f, 150.0f, 100.0f)];
	[self.mapStyleView setCenter:CGPointMake(375.0f, 240.0f)];
	[self.view addSubview:mapStyleView];
	[self.mapStyleView release];
	
	/*
	 MarkerInfoView
	 */
	self.markerInfoView = [[MarkerInfoView alloc] initWithFrame:CGRectMake(0.0, 480.0, 320.0, 150.0)];
	[self.view addSubview:markerInfoView];
	[self.markerInfoView release];
	
		
}

- (void) StartTimer
{
	/*
	 Timer for Menu Button
	 */
	timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(menuClose) userInfo:nil repeats:NO];
}

- (void) touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
    //touchMovedEventCounter = 0;
    NSSet *allTouches = [event allTouches];
	
    UITouch* touchTmp = [touches anyObject];
    NSUInteger numTaps = [touchTmp tapCount];	
    
	if (numTaps < 2) 
        [self.nextResponder touchesBegan:touches withEvent:event];	
	
    switch ([allTouches count]) 
	{
        case 1:
		{
            UITouch *touch = [[allTouches allObjects] objectAtIndex:0];
//			NSLog(@"VIEW_TOUCHED: %@", touch.view);
			if ( touch.view == self.mapStyleView )
			{
				[self.mapStyleView presentView];
			}
        } break;
		default:
            break;
    }
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
    // Return YES for supported orientations
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
	return YES;
}

- (void)findMe
{
    CLLocationManager*  locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = 1000; // 1 kilometer
    locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    [locationManager startUpdatingLocation]; // set up location manager
	[self presentHUD];
}

- (void)infoClicked
{
	
	CGPoint newCenter = [mapView.cloudMadeMapView getMapCenter];
	NSLog(@"NewCenter  lat: %f  long: %f", newCenter.x, newCenter.y);

//	NSLog(@"DEFAULT_LAT: %+.6f  DEFAULT_LONG: %+.6f\n",LATITUDE,LONGITUDE);
//	NSLog(@"NEW_LAT: %+.6f  NEW_LONG: %+.6f\n",latitude,longitude);

//	[mapStyleView removeView];
	
}

- (void) menuClicked
{
	UIView* buttonToHide;
	buttonToHide = [self.view viewWithTag:100];
	[buttonToHide setHidden:YES];
	UIView* button2ToHide;
	button2ToHide = [self.view viewWithTag:102];
	[button2ToHide setHidden:YES];
	UIView* button3ToHide;
	button3ToHide = [self.view viewWithTag:103];
	[button3ToHide setHidden:YES];
	
	UIView* labelToHide;
	labelToHide = [self.view viewWithTag:101];
	[labelToHide setHidden:YES];

	// Animate the Toolbar to show
	CGContextRef context = UIGraphicsGetCurrentContext();
	[UIView beginAnimations:nil context:context];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:0.5];
	CGRect rect = [toolbar frame];
	rect.origin.y = -1.0;
	[toolbar setFrame:rect];
	// Complete the animation
	[UIView commitAnimations];
	
	[self StartTimer];
}

- (void) menuClose
{
	// Animate the Toolbar to hide
	CGContextRef context = UIGraphicsGetCurrentContext();
	[UIView beginAnimations:nil context:context];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:0.5];
	CGRect rect = [toolbar frame];
	rect.origin.y = -44.0;
	[toolbar setFrame:rect];
	// Complete the animation
	[UIView commitAnimations];
	
	UIView* buttonToHide;
	buttonToHide = [self.view viewWithTag:100];
	[buttonToHide setHidden:NO];
	UIView* labelToHide;
	labelToHide = [self.view viewWithTag:101];
	[labelToHide setHidden:NO];
	UIView* button2ToHide;
	button2ToHide = [self.view viewWithTag:102];
	[button2ToHide setHidden:NO];
	UIView* button3ToHide;
	button3ToHide = [self.view viewWithTag:103];
	[button3ToHide setHidden:NO];
	timer = nil;
	[timer invalidate];
	[timer release];
}


- (void) switch: (id) sender
{
	//[[self navigationController] pushViewController:[[SettingsController alloc] init] animated:YES];
	SettingsController* settings = [[SettingsController alloc] initWithNibName:@"Settings" bundle:nil];
	[self presentModalViewController:settings animated:YES];
}

- (void) settingsChangedNotification:(NSNotification*)notification
{	
	Utils* myUtils = [Utils sharedInstance];
	
//	NSLog(@"Notification %@ von %@", [notification name], [notification object]);
	NSLog(@"Lat: %f",[myUtils getNewLatitude]);
	NSLog(@"Long: %f",[myUtils getNewLongitude]);
	
	[mapView.cloudMadeMapView setCenter:[myUtils getNewLatitude] : [myUtils getNewLongitude] ];
}

- (void) mapStyleChangedNotification:(NSNotification*)notification
{
//	NSLog(@"Notification1 %@ von %@", [notification name], [notification object]);
	if ( [notification name] == @"mapstyle" )
	{
		Utils* myUtils = [Utils sharedInstance];
		NSLog(@"Los gehts mit: %@", [myUtils getNewTileserver]);
		[mapView changeMapStyle:[myUtils getNewTileserver]];
	}
}

- (void)dealloc 
{
	NSNotificationCenter* center;
	center = [NSNotificationCenter defaultCenter];
	[center removeObserver:self];
	[self.mapStyleView release];
    [super dealloc];
}


- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
	// Kill HUD
	Utils* myUtils = [Utils sharedInstance];
	[self performSelector:@selector(killHUD:) withObject:[myUtils getHUDid]];
	
    // Disable future updates to save power.
    [manager stopUpdatingLocation];
    [mapView.cloudMadeMapView setCenter:newLocation.coordinate.latitude : newLocation.coordinate.longitude ];
	latitude = newLocation.coordinate.latitude;
	longitude = newLocation.coordinate.longitude;
	
	//NSLog(@"Old Coordinates: %+.6f, %+.6f\n", oldLocation.coordinate.latitude, oldLocation.coordinate.longitude);
	//	NSLog(@"New Coordinates: %+.6f, %+.6f\n", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
	//	NSLog(@"Altitude: %+.6f\n", newLocation.altitude);
	//	NSLog(@"Description: %@\n", [newLocation description]);
	//	NSDate* timestamp = newLocation.timestamp;
	//	NSTimeInterval age = [timestamp timeIntervalSinceNow];
	//	NSLog(@"Notification age: %.4f\n", age);
	
}

- (void) zoomInWithButton
{
	[mapView.cloudMadeMapView zoomIn];
}

- (void) zoomOutWithButton
{
	[mapView.cloudMadeMapView zoomOut];
}

@end

