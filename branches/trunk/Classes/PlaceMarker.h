//
//  PlaceMarker.h
//  routeConcepts
//
//  Created by Fabian Girolstein on 24.07.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CloudMadeView.h"
#import "Location.h"
#import "HelperConstant.h"


//! Class for presentation location's marker
@interface PlaceMarker : UIImageView <UserActions>
{
    CGPoint lastTouchLocation;          /**< point where last touch took place*/   
    CGFloat lastTouchSpacing;           /**< */    
    int     touchMovedEventCounter;	    /**< touch counter*/
    id<PlaceWasClicked>  delegate;
    Location* location;	
    int nID; 
	BOOL bDragable;
	float fLongitude;
	float fLatitude;
	CloudMadeView* mapView;
	UIToolbar* markerToolbar;
}

@property (nonatomic,readwrite) BOOL bDragable;
@property (nonatomic,readwrite) float fLongitude;
@property (nonatomic,readwrite) float fLatitude;


//! PlaceWasClicked delegate
@property (nonatomic, retain) id<PlaceWasClicked>  delegate;

//! marker details \sa Location
@property (nonatomic, retain)    Location* location;

//! Marker index in markers' array \sa CloudMadeView
@property (nonatomic,readwrite) int nID;

/**
  * Sets image for marker
  *  @param image image
*/
-(void) setMarkerImage:(UIImage*) image;

-(void) setPanningModeWithLocation:(CGPoint)location;

/**
 * Puts marker in given place
 * @param x X-coordinate
 * @param y Y-coordinate
*/
-(void) setMarker:(float)x :(float) y; 

-(BOOL) isPanning;

- (void) reset;

- (void) showDisclosureAt:(CGPoint) aPoint;
//
//- (UICalloutView*) buildDisclosure;
//
//- (void) hideDisclosure: (UIPushButton*) calloutButton;
@end
