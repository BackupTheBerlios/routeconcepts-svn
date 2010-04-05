//
//  PlaceMarker.m
//  routeConcepts
//
//  Created by Fabian Girolstein on 24.07.09.
//  Copyright 2009-2010 __MyCompanyName__. All rights reserved.
//

#import "PlaceMarker.h"
#import "HelperConstant.h"
#import "CloudMadeView.h"
#import "UICalloutView.h"




@implementation PlaceMarker

@synthesize delegate;
@synthesize location;
@synthesize nID;
@synthesize bDragable;

@synthesize fLongitude;
@synthesize fLatitude;

int disclosureCounter = 0;

- (id) init
{
	//UIImage *image = [UIImage imageNamed:@"balloon.png"];
	UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%s",DEFAULT_IMAGE_NAME]];
	if(image!=nil)
	{
		[super initWithFrame:CGRectMake(0, 0, [image size].width, [image size].height)];
		self.image = image;
	    //self.multipleTouchEnabled = YES;
	    self.userInteractionEnabled = YES;
		self.bDragable = TRUE;
	}
	return self;
}

-(void) setMarker:(float)x :(float) y 
{
	[self setCenter:CGPointMake(x,y)];
}

- (void)dealloc {
	[super dealloc];
}


- (void) touchesBeginEvent:(NSSet*)touches withEvent:(UIEvent*)event
{
}

- (void) tochesMovedEvent:(NSSet*)touches withEvent:(UIEvent*)event
{
}

- (void) moveMap:(float) x :(float) y
{
	CGPoint pCenter = self.center;
	pCenter.x-=x;
	pCenter.y-=y;	
	[self setCenter:pCenter];
//	[self setCenter:CGPointMake(x,y)];	
}


- (void) touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
    touchMovedEventCounter = 0;
    NSSet *allTouches = [event allTouches];
    
    switch ([allTouches count]) 
	{
        case 1:
		{
			
            UITouch *touch = [[allTouches allObjects] objectAtIndex:0];
            [self setPanningModeWithLocation:[touch locationInView:self]];
			if (disclosureCounter == 0)
			{
			//	[self showDisclosureAt:[touch locationInView:self]];
				disclosureCounter++;
			}
        } break;
	}
           
}

- (void) touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event
{
	// Tricky procedure which was stolen from another application but it looks like it's working fine
	// Without this trick we have many fake callings of this function  	
	if (++touchMovedEventCounter % (int)(1.0 / (1.0 - DROPPED_TOUCH_MOVED_EVENTS_RATIO)))
        return;
    
	if(!self.bDragable)
		return;
	
    NSSet *allTouches = [event allTouches];
    
    switch ([allTouches count])
	{
        case 1: {
            if (! [self isPanning])
			{
                [self reset];
                break;
            }
            UITouch *touch = [[allTouches allObjects] objectAtIndex:0];
            CGPoint currentLocation = [touch locationInView:self];
            int dX = (int)(currentLocation.x - lastTouchLocation.x);
            int dY = (int)(currentLocation.y - lastTouchLocation.y);
			[self moveMap:-dX :-dY];
        };
	}
            
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	id del = delegate;	
	if(!touchMovedEventCounter)
	{
		if(delegate)
		{
			if([del respondsToSelector:@selector(markerWasClicked:)])			
				[delegate markerWasClicked:self]; 
		}
		[self reset];	
	}
	else
	{
		if([del respondsToSelector:@selector(markerWasMoved:)])
			[delegate markerWasMoved:self];	
	}
}
	
- (void) setPanningModeWithLocation:(CGPoint)_location
{
    lastTouchLocation = _location;
    lastTouchSpacing = -1;
}

- (BOOL) isPanning
{
    return lastTouchLocation.x > 0 ? YES : NO;
}

- (void) reset
{
	lastTouchLocation = CGPointMake(-1, -1);
	lastTouchSpacing = -1;
}

-(void) setMarkerImage:(UIImage*) image
{
	//[super initWithFrame:CGRectMake(0, 0, [image size].width, [image size].height)];
	//self.contentMode = UIViewContentModeRedraw;
	super.bounds = CGRectMake(0, 0, [image size].width, [image size].height);
	self.image = image;
}

-(void) setLocation:(Location*) loc
{
	location = loc;
	self.bDragable = (loc.bStaticPlace)?FALSE:TRUE;
}

/// CalloutView

- (void) hideDisclosure: (UIPushButton*) calloutButton
{
	UICalloutView* callout = (UICalloutView*)[calloutButton superview];
	[callout fadeOutWithDuration:1.0f];
	disclosureCounter--;
}

- (UICalloutView*) buildDisclosure
{
	UICalloutView* callout = [[[UICalloutView alloc] initWithFrame:CGRectZero] autorelease];
	callout.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	callout.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
	
	// You can easily customize the information and the target
	[callout setTemporaryTitle:@"You Tapped Here!"];
	[callout setTitle:@"More Info..."];
	[callout addTarget:self action:@selector(hideDisclosure:)];
	
	// Optional delegate methods are:
	// calloutView:willMoveToAnchorPoint:animated:
	// calloutView:didMoveToAnchorPoint:animated:
	// [callout setDelegate:self]; 
	
	
	return callout;
}

- (void) pushed
{
	NSLog(@"Bin gedrückt");
}

- (void) showDisclosureAt:(CGPoint) aPoint
{
	NSLog(@"Point: x=%f  y=%f", aPoint.x, aPoint.y);
//	UICalloutView* callout = [self buildDisclosure];
//	[callout setAnchorPoint:aPoint boundaryRect:CGRectMake(0.0f, 0.0f, 320.0f, 100.0f) animate:YES];
//	[self addSubview:callout];
//	markerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(20.0, 40.0, 100.0, 30.0)];
//	markerToolbar.barStyle = UIBarStyleBlackTranslucent;
//	UIBarButtonItem* infoButton = [[UIBarButtonItem alloc] initWithTitle:@"Info"
//																	   style:UIBarButtonItemStyleBordered
//																	  target:self 
//																	  action:@selector(pushed)];
//		
//	[markerToolbar setItems:[NSArray arrayWithObjects: infoButton, nil]];
//	
//	[self addSubview:markerToolbar];
}

@end
