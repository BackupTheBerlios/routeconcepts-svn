//
//  CloudMadeView.m
//  routeConcepts
//
//  Created by Fabian Girolstein on 24.07.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "CloudMadeView.h"
#import "PlaceMarker.h"
#import "Utils.h"
#import "HelperConstant.h"
#import "UICalloutView.h"
#import <QuartzCore/QuartzCore.h>

@interface CloudMadeView (Private)
- (BOOL) isZooming;
- (void) setZoomingModeWithSpacing:(CGFloat)spacing;
- (CGFloat) eucledianDistanceFromPoint:(CGPoint)from toPoint:(CGPoint)to ;
- (void) reset;
- (BOOL) isPanning;
- (void) setPanningModeWithLocation:(CGPoint)location;
- (void) updateMarkersWithMoving:(float) x :(float) y;
- (void) updDel_touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event;
- (void) updDel_touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event;
- (void) removeLocation:(NSMutableArray*) array :(NSString*) strID;
- (void) updateMarkersWithMoving:(float) x :(float) y;
- (void) updateMarkersWithZooming;
@end

CGPoint gfRealMapCenter;

@implementation CloudMadeView

@synthesize eventDelegate;
@synthesize cloudMadeMapView;
@synthesize whereAmI;  

struct MapSettings CreateMapSettings(const char* baseUrl,const char* apikey,int stileid,int tilesize,int zoom,BOOL busegps,float latitude,float longitude,const char* rootDomain,const char* subdomain,int width,int height)
{
	struct MapSettings mapSettings = {"","",stileid,tilesize,zoom,busegps,latitude,longitude,"",""};
	mapSettings.baseUrl = baseUrl;
	mapSettings.apiKey = apikey;
	mapSettings.rootDomain = rootDomain;
	mapSettings.subDomain = subdomain;
	mapSettings.width = width;
	mapSettings.height = height;
	return mapSettings;
}


-(id) InitWithMap:(CGRect)frame:(struct MapSettings)mapsettings
{
    [self initWithFrame:frame];
	mapSettings = mapsettings;
    cloudMadeMapView = [[[CloudMadeMapView alloc] initWithFrame:frame] autorelease];
	[cloudMadeMapView initializeMap:mapsettings];
    [self addSubview:cloudMadeMapView];
	
	// "Term of Use" - Label
	termOfUse = [[UILabel alloc] initWithFrame:CGRectMake(0, 420, 320, 20)];
	termOfUse.text = @"Map data CCBYSA 2009 OpenStreetMap.org contributors";
	termOfUse.backgroundColor = [UIColor clearColor];
	termOfUse.minimumFontSize=0.05;
	termOfUse.textAlignment = UIBaselineAdjustmentAlignCenters| UITextAlignmentCenter;
	termOfUse.adjustsFontSizeToFitWidth=YES;
	[self addSubview:termOfUse];
    // "Term of Use" - Label
	
	[self reset];
	return self;
}

- (id)initWithFrame:(CGRect)frame
{
    if (! (self = [super initWithFrame:frame]))
        return nil;
	
    self.autoresizesSubviews = YES;
    self.multipleTouchEnabled = YES;
    return self;
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
            [self setPanningModeWithLocation:[touch locationInView:self]];
		} break;
            
        case 2:
		{
            UITouch *touch0 = [[allTouches allObjects] objectAtIndex:0];
            UITouch *touch1 = [[allTouches allObjects] objectAtIndex:1];
            CGFloat spacing = [self eucledianDistanceFromPoint:[touch0 locationInView:self] toPoint:[touch1 locationInView:self]];
            [self setZoomingModeWithSpacing:spacing];
        } break;
            
        default:
            [self reset];
            break;
    }
	[self updDel_touchesBegan:touches withEvent:event];	
}

- (void) touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event
{
	
    UITouch* touchTmp = [touches anyObject];
    NSUInteger numTaps = [touchTmp tapCount];	
    
	if (numTaps < 2) 
        [self.nextResponder touchesBegan:touches withEvent:event];	
		
	// Tricky procedure which was stolen from another application but it looks like it's working fine
	// Without this trick we have many fake callings of this function  	
	if (++touchMovedEventCounter % (int)(1.0 / (1.0 - DROPPED_TOUCH_MOVED_EVENTS_RATIO)))
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
            [self setPanningModeWithLocation:[touch locationInView:self]];
            [cloudMadeMapView setCenterWithPixel:-dX :-dY];
			[self updateMarkersWithMoving:-dX :-dY];
        } break;
            
        case 2:
		{
            if (! [self isZooming])
			{
                [self reset];
                break;
            }
            UITouch *touch0 = [[allTouches allObjects] objectAtIndex:0];
            UITouch *touch1 = [[allTouches allObjects] objectAtIndex:1];
            CGFloat spacing = [self eucledianDistanceFromPoint:[touch0 locationInView:self] toPoint:[touch1 locationInView:self]];
            CGFloat spacingRatio = spacing / lastTouchSpacing;
            
            if (spacingRatio >= ZOOM_OUT_TOUCH_SPACING_RATIO)
			{
                [self setZoomingModeWithSpacing:spacing];  
                [cloudMadeMapView zoomIn];
            }
            else if (spacingRatio <= ZOOM_IN_TOUCH_SPACING_RATIO)
				
			{
                [self setZoomingModeWithSpacing:spacing];
                [cloudMadeMapView zoomOut];
            }
			[self updateMarkersWithZooming];
        } break;
            
        default:
            [self reset];
            break;
    }
	//if(eventDelegate) 
	//	[eventDelegate tochesMovedEvent:touches withEvent:event];
	
	[self updDel_touchesMoved:touches withEvent:event];
}

- (void) reset
{
   lastTouchLocation = CGPointMake(-1, -1);
   lastTouchSpacing = -1;
}

- (BOOL) isPanning
{
    return lastTouchLocation.x > 0 ? YES : NO;
}

- (void) setPanningModeWithLocation:(CGPoint)location
{
    lastTouchLocation = location;
    lastTouchSpacing = -1;
} 


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [[event allTouches] anyObject];
	if( touch.tapCount == 2 )
	{
       [cloudMadeMapView zoomIn];
       [self updateMarkersWithZooming];
       [self updDel_touchesMoved:touches withEvent:event];
	}
}

- (void) dealloc 
{
	[super dealloc];
}

- (CGFloat) eucledianDistanceFromPoint:(CGPoint)from toPoint:(CGPoint)to 
{
    float dX = to.x - from.x;
    float dY = to.y - from.y;
    return sqrt(dX * dX + dY * dY);
}

- (void) setZoomingModeWithSpacing:(CGFloat)spacing
{
    lastTouchLocation = CGPointMake(-1, -1);
    lastTouchSpacing = spacing;
}

- (BOOL) isZooming
{
    return lastTouchSpacing > 0 ? YES : NO;
}


//-(void) changeMapStyle:(int) styleID :(int) tileSize
//{
//	mapSettings.tileSize = tileSize;
//	[cloudMadeMapView changeMapStyle:styleID :mapSettings.rootDomain :mapSettings.subDomain :mapSettings.tileSize :mapSettings.apiKey ];
//}

-(void) changeMapStyle:(const char*) rootDomain
{
	mapSettings.rootDomain = rootDomain;
	int styleID = 1;
	[cloudMadeMapView changeMapStyle:styleID :mapSettings.rootDomain :mapSettings.subDomain :mapSettings.tileSize :mapSettings.apiKey ];
}

-(void) adjustTermOfUse:(CGPoint) center 
{
	[termOfUse setCenter:center];
}

-(void) manageRotation:(UIInterfaceOrientation) orientation
{
	static int i=0;
	if(!i)
	{
		++i;
		return;
	}
	[cloudMadeMapView manageRotation:orientation];	
	if( UIInterfaceOrientationPortrait == orientation || UIInterfaceOrientationPortraitUpsideDown == orientation )
	{
		[self  adjustTermOfUse:TERM_OF_USE_PORTRAIT];
		self.frame = MAP_FRAME_PORTRAIT;
	}
	if(UIInterfaceOrientationLandscapeLeft == orientation || UIInterfaceOrientationLandscapeRight == orientation)
	{
		[self  adjustTermOfUse:TERM_OF_USE_LANDSCAPE];
		self.frame = MAP_FRAME_LANDSCAPE;		
	}
	[self sizeToFit];
}

-(void) setCenter:(float) x :(float) y
{
	CGPoint center = self.center;
	CGPoint px = [cloudMadeMapView transformLatLngToPoint:x :y];
	[self updateMarkersWithMoving:(center.x - px.x) :(center.y - px.y)];	
	[cloudMadeMapView setCenter:x :y];
}

-(CGPoint) transformLatLngToPoint:(float) lat :(float) lng
{
	return [cloudMadeMapView transformLatLngToPoint :lat :lng];
}


-(id) findMarker:(NSString*) strID
{
	for(PlaceMarker* loc in arrayOfLocations)
	{
		if( [loc.location.strID isEqualToString:strID])
			return loc;
	}
	return nil;
}

-(id) placeMarkerOnMap:(float) lat :(float) lng
{
	PlaceMarker* marker = [[PlaceMarker alloc] init];
	//CGPoint markerCoord = [self transformLatLngToPoint :lat :lng];
	
	CGPoint markerCoord = CGPointMake(160,240);

	if(!arrayOfLocations)
		arrayOfLocations = [[NSMutableArray alloc] init];
	
	
	 #define ANIMATION_DURATION (1.0)
	 #define CGAutorelease(x) (__typeof(x))[NSMakeCollectable(x) autorelease]

	// create the reflection layer
	CALayer *reflectionLayer = [CALayer layer];
	reflectionLayer.contents = [marker layer].contents; // share the contents image with the screen layer
	reflectionLayer.opacity = 0.5;
	//	 reflectionLayer.frame = CGRectOffset([marker layer].frame, 0.5, 416.0f + 0.5); // NSHeight(displayBounds)
	//reflectionLayer.frame = CGRectOffset([marker layer].frame, -130.0, -215.0); 
	reflectionLayer.frame = CGRectMake(8.0, 10.0, 35.0, 35.0);
	//	 reflectionLayer.transform = CATransform3DMakeScale(1.0, -1.0, 1.0); // flip the y-axis
	reflectionLayer.transform = CATransform3DMakeRotation(45.0, 1.0, -1.0, 1.0);
	reflectionLayer.sublayerTransform = reflectionLayer.transform;
	[[marker layer] addSublayer:reflectionLayer];
	
	[CATransaction begin];
	[CATransaction setValue:[NSNumber numberWithFloat:ANIMATION_DURATION] forKey:kCATransactionAnimationDuration];
	 
	 // scale it down
//	 CABasicAnimation *shrinkAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
//	 shrinkAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
//	 shrinkAnimation.toValue = [NSNumber numberWithFloat:0.0];
//	 [[marker layer] addAnimation:shrinkAnimation forKey:@"shrinkAnimation"];
//	 
//	 // fade it out
//	 CABasicAnimation *fadeAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
//	 fadeAnimation.toValue = [NSNumber numberWithFloat:0.0];
//	 fadeAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
//	 [[marker layer] addAnimation:fadeAnimation forKey:@"fadeAnimation"];
	 
	 // make it jump a couple of times
//	 CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
//	 CGMutablePathRef positionPath = CGAutorelease(CGPathCreateMutable());
//	 CGPathMoveToPoint(positionPath, NULL, [marker layer].position.x, [marker layer].position.y);
//	 CGPathAddQuadCurveToPoint(positionPath, NULL, [marker layer].position.x, - [marker layer].position.y, [marker layer].position.x, [marker layer].position.y);
//	 CGPathAddQuadCurveToPoint(positionPath, NULL, [marker layer].position.x, - [marker layer].position.y * 1.5, [marker layer].position.x, [marker layer].position.y);
//	 CGPathAddQuadCurveToPoint(positionPath, NULL, [marker layer].position.x, - [marker layer].position.y * 2.0, [marker layer].position.x, [marker layer].position.y);
//	 positionAnimation.path = positionPath;
//	 positionAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
//	 [[marker layer] addAnimation:positionAnimation forKey:@"positionAnimation"];
	 
	// move in
	CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
	CGMutablePathRef positionPath = CGAutorelease(CGPathCreateMutable());
	CGPathMoveToPoint(positionPath, NULL, 160.0 , 0.0);
	CGPathAddQuadCurveToPoint(positionPath, NULL, 160.0, 240.0, 160.0, 240.0);
	CGPathAddQuadCurveToPoint(positionPath, NULL, 160.0, 243.0, 160.0, 240.0);
	CGPathAddQuadCurveToPoint(positionPath, NULL, 160.0, 240.0, 160.0, 240.0);
	positionAnimation.path = positionPath;
	positionAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
	[[marker layer] addAnimation:positionAnimation forKey:@"positionAnimation"];
	
	[CATransaction commit];
	 
	[marker setMarker:markerCoord.x :markerCoord.y];
    [arrayOfLocations addObject:marker];
    marker.nID = arrayOfLocations.count - 1;
		
	[self addSubview:marker];
	return marker;
}

-(id) markPlace:(float)lat :(float)lng :(id) del
{
	PlaceMarker* marker = [self placeMarkerOnMap:lat :lng];
	marker.delegate = del;
	marker.fLatitude = lat;
	marker.fLongitude = lng;	
	return marker;
}

-(id) markPlace:(Location*)loc :(id) del;
{
	PlaceMarker* marker = [self findMarker:loc.strID];
    if(marker)
		return marker;  
	
	marker = [self placeMarkerOnMap:loc.fLatitude :loc.fLongitude];
	marker.delegate = del;	
	return marker;	
}

-(void) addDelegate:(id <UserActions>) delegate 
{
	if(!arrayOfDelegates)
		arrayOfDelegates = [[NSMutableArray alloc] init];
    [arrayOfDelegates addObject:delegate];	
}

-(void) updateMarkersWithMoving:(float) x :(float) y;
{
	for(PlaceMarker* marker in arrayOfLocations)
		[marker moveMap:x :y];
	
	for(id <UserActions> delegate in arrayOfDelegates)
	{
		id del = delegate;
		if([del respondsToSelector:@selector(moveMap::)])			
			[delegate moveMap:x :y];
	}

}


-(void) updDel_touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event
{
	 for(id <UserActions> delegate in arrayOfDelegates)
	 [delegate tochesMovedEvent:touches withEvent:event];
}

-(void) updDel_touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
	for(id<UserActions> delegate in arrayOfDelegates)
		[delegate touchesBeginEvent:touches withEvent:event];
}


-(CGPoint) getMapCenter
{
	return [cloudMadeMapView getMapCenter];
}

-(CGPoint) transformPointToLatLng:(float) x :(float) y
{
	return [cloudMadeMapView transformPointToLatLng:x :y];
}


-(void) removeLocation:(NSMutableArray*) array :(NSString*) strID
{
	int nIdx = 0; 
	for(id obj in array)
	{
       if ( [obj isKindOfClass:[PlaceMarker class]] )
	   {
		 PlaceMarker* marker = (PlaceMarker*)obj;  
		 if([marker.location.strID isEqualToString:strID])
		 {
			[marker removeFromSuperview];
			[array removeObjectAtIndex:nIdx]; 
			break;
		 }
		 nIdx++;
	   }
	}
}
-(void) removeMarkerByIdx:(int) nIdx
{
	if(nIdx < 0 || nIdx > arrayOfLocations.count)
		@throw [NSException exceptionWithName:@"removeMarkerByIdx" reason:@"Out of range index" userInfo:nil];
	
	PlaceMarker* marker = [arrayOfLocations objectAtIndex:nIdx];
	[marker removeFromSuperview];
	[arrayOfLocations removeObjectAtIndex:nIdx]; 
}

-(BOOL) removeMarker:(NSString*) strID
{
	[self removeLocation: arrayOfLocations :strID];
	//[self removeLocation: arrayOfDelegates :strID];
	return TRUE;
}

-(BOOL) updateMarker:(Location*) location;
{
	for(PlaceMarker* marker in arrayOfLocations)
	{
		if([marker.location.strID isEqualToString:location.strID])
		{
			if(![marker.location.strURL isEqualToString: location.strURL])
			{
			    [marker setMarkerImage:[Utils getImage:location.strURL]];	
			}
			marker.location = location;
			return TRUE;
		}
	}
	return FALSE;
}

-(void) updateMarkersWithZooming
{
	for(PlaceMarker* marker in arrayOfLocations)
	{
		if(marker.location)
		{
			CGPoint newCenter = [self transformLatLngToPoint:marker.location.fLatitude :marker.location.fLongitude];
			[marker setCenter:newCenter];		
		}
		else
		{
			CGPoint newCenter = [self transformLatLngToPoint:marker.fLatitude :marker.fLongitude];
			[marker setCenter:newCenter];		
		}
		
	}
}

-(int) findRelevantZoom:(float) latDiff :(float) lngDiff
{
	return [cloudMadeMapView findRelevantZoom:latDiff :lngDiff];
}

-(void) setMapZoom:(int) zoom
{
	[cloudMadeMapView setMapZoom:zoom];
    [self updateMarkersWithZooming];	
}


-(void) updateMarkerByIdx:(int) nIdx :(Location*) loc 
{
   	PlaceMarker* marker = [arrayOfLocations objectAtIndex:nIdx];
    [marker setMarkerImage:[Utils getImage:loc.strURL]];	
	marker.location = loc;
}

-(void) setMarkerID:(int) nIdx :(int) locID
{
   	PlaceMarker* marker = [arrayOfLocations objectAtIndex:nIdx];
    //[marker setMarkerImage:[Utils getImage:loc.strURL]];	
	//marker.location = loc;
	marker.location.strID = [NSString stringWithFormat:@"%d",locID];
}

-(CGRect) getBoundBox:(CGSize) size 
{
	return [cloudMadeMapView getBoundBox:size];
}

-(int) getZoom
{
	return [cloudMadeMapView getZoom];
}

-(void) clearLocationsArray
{
	for(PlaceMarker* loc in arrayOfLocations)
	{
		[loc removeFromSuperview];
	}
	[arrayOfLocations removeAllObjects];	
}

-(void) placeMarkersOnMap:(NSArray*) locations withDelegate:(id<PlaceWasClicked>) delegate
{
	int count = 0;
	CGPoint diff;	
	int zoom;
	float minLat,minLng,maxLat,maxLng;
	// remove everything from map
	[self clearLocationsArray];
	
	if([locations count] == 0)
		return; 
	
	if(locations.count>1) // find relevant zoom if there are more than one location
	{
		int nCount = locations.count;
		minLat = ((Location*)([locations objectAtIndex:0])).fLatitude;
		minLng = ((Location*)([locations objectAtIndex:0])).fLongitude;		
		maxLat = minLat;
		maxLng = minLng;
		for(int i=1;i<nCount;++i)
		{
			Location* loc = [locations objectAtIndex:i];
			if(loc.fLatitude < minLat )
				minLat = loc.fLatitude;
			if(loc.fLongitude < minLng)
				minLng = loc.fLongitude;
			if(loc.fLatitude > maxLat )
				maxLat = loc.fLatitude;
			if(loc.fLongitude > maxLng)
				maxLng = loc.fLongitude;
		}
		
		diff.x = maxLat - minLat;
		diff.y = maxLng - minLng;
		
		zoom = [self findRelevantZoom:diff.x :diff.y]; 
	    [self setCenter:(maxLat + minLat)/2 :(minLng+maxLng)/2];				
	}
	else
	{
	    [self setCenter:  ((Location*)([locations objectAtIndex:0])).fLatitude  :((Location*)([locations objectAtIndex:0])).fLongitude];										
		zoom = [self getZoom];
	}
	
	for(Location* loc in locations)
	{
		if(loc)
		{
			if(!count)
			{
				++count ;
			}
			PlaceMarker* marker = (PlaceMarker*)[self markPlace:loc :delegate ]; 
			[marker setMarkerImage:[Utils getImage:loc.strURL]];			
			marker.location = loc;
		}
	}
	[self setMapZoom:zoom];		
}

-(void) deleteDelegate:(id) removingDelegate
{
	if(!arrayOfDelegates)
		return;
	[arrayOfDelegates removeObject:removingDelegate];
}

@end
