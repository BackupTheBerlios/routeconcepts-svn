//
//  RootViewController.h
//  routeConcepts
//
//  Created by Fabian Girolstein on 24.07.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CloudMadeView.h"
#import "ChooseMapStyle.h"
#import "MarkerInfoView.h"
#import <CoreLocation/CoreLocation.h>


@interface RootViewController : UIViewController <CLLocationManagerDelegate, UIActionSheetDelegate>
{
	CloudMadeView* mapView;
	UIToolbar* toolbar;
	ChooseMapStyle* mapStyleView;
	MarkerInfoView* markerInfoView;
	float latitude,longitude;
	NSTimer* timer;
}

@property (nonatomic, retain) ChooseMapStyle* mapStyleView;
@property (nonatomic, retain) MarkerInfoView* markerInfoView;

@end
