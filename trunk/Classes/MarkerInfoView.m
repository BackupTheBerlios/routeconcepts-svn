//
//  MarkerInfoView.m
//  routeConcepts
//
//  Created by Fabian Girolstein on 14.08.09.
//  Copyright 2009-2010 __MyCompanyName__. All rights reserved.
//

#import "MarkerInfoView.h"
#import "CloudMadeView.h"


@implementation MarkerInfoView

@synthesize addressLabel;
@synthesize coordinatesLabel;
@synthesize mapView;


- (MarkerInfoView*) initWithFrame: (CGRect)rect
{	
	self = [super initWithFrame:rect];
	
	[self setAlpha:0.8];
	[self setBackgroundColor: [UIColor blackColor]];
	
	// Add address label
	addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 10.0, 300.0, 20.0)];
	addressLabel.text = @"Adresse";
	addressLabel.adjustsFontSizeToFitWidth = YES;
	addressLabel.textColor = [UIColor whiteColor];
	addressLabel.backgroundColor = [UIColor clearColor];
	[self addSubview:addressLabel];
	[addressLabel release];
	
	// Add coordinates label
	coordinatesLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 40.0, 300.0, 20.0)];
	coordinatesLabel.text = @"Koordinaten";
	coordinatesLabel.adjustsFontSizeToFitWidth = YES;
	coordinatesLabel.textColor = [UIColor whiteColor];
	coordinatesLabel.backgroundColor = [UIColor clearColor];
	[self addSubview:coordinatesLabel];
	[coordinatesLabel release];
	
	UIButton* removeMarkerButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] initWithFrame:CGRectMake(10.0, 80.0, 140.0, 50.0)];
	[removeMarkerButton setTitle:@"Remove" forState:UIControlStateNormal];
	removeMarkerButton.titleLabel.font = [UIFont systemFontOfSize:23.0];
//	[removeMarkerButton setFont:[UIFont systemFontOfSize:23.0]];
	[removeMarkerButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	[removeMarkerButton addTarget:self action:@selector(removeMarker) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:removeMarkerButton];
	
	UIButton* cancelMarkerInfoButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] initWithFrame:CGRectMake(170.0, 80.0, 140.0, 50.0)];
	[cancelMarkerInfoButton setTitle:@"Cancel" forState:UIControlStateNormal];
	cancelMarkerInfoButton.titleLabel.font = [UIFont systemFontOfSize:23.0];
//	[cancelMarkerInfoButton setFont:[UIFont systemFontOfSize:23.0]];
	[cancelMarkerInfoButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	[cancelMarkerInfoButton addTarget:self action:@selector(removeView) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:cancelMarkerInfoButton];
	return self;
}

- (void) removeView
{
	// Scroll away the overlay
	CGContextRef context = UIGraphicsGetCurrentContext();
	[UIView beginAnimations:nil context:context];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:0.5];
	
	CGRect rect = [self frame];
	rect.origin.y = 480;
	[self setFrame:rect];
	
	// Complete the animation
	[UIView commitAnimations];
}

- (void) removeMarker
{
	
}

- (void) presentView
{
	// Scroll in the overlay
	CGContextRef context = UIGraphicsGetCurrentContext();
	[UIView beginAnimations:nil context:context];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:0.5];
	
	CGRect rect = [self frame];
	rect.origin.y = 310.0;
	[self setFrame:rect];
	
	// Complete the animation
	[UIView commitAnimations];
}

- (void) dealloc
{
	[super dealloc];
}

@end
