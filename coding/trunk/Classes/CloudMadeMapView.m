//
//  CloudMadeMapView.m
//  routeConcepts
//
//  Created by Fabian Girolstein on 24.07.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "CloudMadeView.h"
#import "CloudMadeMapView.h"
#import "HelperConstant.h"


@interface CloudMadeMapView (Private)
- (void) loadMap;
- (NSString*) performJavaScript:(NSString*)script;
- (float) getResolution;
- (void) fillArrayOfDistances;
@end


@implementation CloudMadeMapView

- (void) initializeMap:(struct MapSettings)mapsettings
{
	mapSettings = mapsettings;	
}

// initialization which is done by superclass
- (void) didMoveToSuperview 
{
	self.delegate = self;
    self.userInteractionEnabled = NO;
    self.scalesPageToFit = NO;
    self.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [self loadMap];
	[self sizeToFit];
}

- (void)dealloc {
	free(arrayOfDistances);	
	[super dealloc];
}

// loading of the map
// the server side expects URL like this url?apikey=APIKEY&stileID=STILEID&tileSize=TILESIZE&zoom=ZOOM&latitude=LATITUDE&longitude=LONGITUDE where
// APIKEY   - has to be obtained from cloudmade.com
// STILEID  - map style
// TILESIZE - size of the tile 256 or 64
// ZOOM     - zoom of the map 1...18
// TILESIZE, LONGITUDE  
- (void) loadMap
{
	NSString* urlStr = [NSString stringWithFormat:@"%s?apikey=%s&stileID=%d&tileSize=%d&zoom=%d&latitude=%f&longitude=%f&rootDomain=%s&subDomain=%s&width=%d&height=%d"
						,mapSettings.baseUrl,mapSettings.apiKey,mapSettings.styleID,mapSettings.tileSize,
						mapSettings.Zoom,mapSettings.Latitude ,mapSettings.Longitude,mapSettings.rootDomain,mapSettings.subDomain,mapSettings.width,mapSettings.height];
    [self loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]]];
}

// changes center of the map
- (void) setCenterWithPixel:(int)dx :(int)dy 
{
   NSString* script = 
	[NSString stringWithFormat:
	 @"var merc = map.getCenter().toMercator();"
	 "var res = map._getResolution();"
	 "var newCenter = new CM.LatLng(merc.lat() - res * %d,merc.lng() + res * %d).fromMercator();"
	 "map.panTo(newCenter);",dy,dx];
	
  //  NSLog(@"CENTER_DELTA_X: %d   CENTER_DELTA_Y: %d",dx,dy);
	
    [self performJavaScript:script];
}

// executes JavaScript
- (NSString*) performJavaScript:(NSString*)script
{
	NSString* response = [self stringByEvaluatingJavaScriptFromString:script];
    return response;
}

// zoomIn map  
- (void) zoomIn
{
    [self performJavaScript:@"map.zoomIn();"];
}

// zoomOut map
- (void) zoomOut
{
    [self performJavaScript:@"map.zoomOut();"];
}

// implementation of the UIWebViewDelegate protocol
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    //[self getBoundBox]; // only debug purposes
	static int nFirstTime = 0;
	if(!nFirstTime)
	{
		[self fillArrayOfDistances];
		nFirstTime++;
	}
}

// implementation of the UIWebViewDelegate protocol
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
}

- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation
{
	// Disable future updates to save power.
	[manager stopUpdatingLocation];
    //[self loadMap:newLocation.coordinate];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
}

- (void) setCenter:(float)lat:(float)lon
{
	NSString* script = [NSString stringWithFormat:@"moveCenter(%f,%f);",lat,lon]; 
	[self performJavaScript:script];
}

- (int) getZoom
{
	return [[self performJavaScript:@"map.getZoom();"]intValue];
}

- (void) changeMapStyle:(int)styleID :(const char*)rootUrl :(const char*)subDomains :(int)tileSize :(const char*)apiKey
{
	NSString* script = [NSString stringWithFormat:@"changeMapStyle(%d,\"%@\",\"%s\",%d,\"%s\");",styleID,rootUrl,subDomains,tileSize,apiKey];
	[self performJavaScript:script];
}

-(CGRect) getBoundBox:(CGSize) size 
{
    NSString* res = [self performJavaScript:[NSString stringWithFormat:@"getBorders(%f,%f);",size.width,size.height]]; 	//TODO remove hardcoded values !!!
	float fLeft,fTop,fRight,fBottom;
    const char* buf = [res cStringUsingEncoding:NSASCIIStringEncoding];
	sscanf(buf,"(%f, %f)",&fLeft,&fTop);
    res = [self performJavaScript:[NSString stringWithFormat:@"getBorders(%f,%f);",-size.width,-size.height]];	
    buf = [res cStringUsingEncoding:NSASCIIStringEncoding];
	sscanf(buf,"(%f, %f)",&fRight,&fBottom);
	CGRect rc = CGRectMake(fLeft, fTop,fRight,fBottom);
	return rc;
}

-(CGPoint) toMercator:(float) lat_ :(float) lng_
{
	float lng = lng_ * 20037508.34 / 180;
	float lat = log(tan((90 + lat_) * M_PI / 360)) / (M_PI / 180);
	lat = lat * 20037508.34 / 180;
	return CGPointMake(lat,lng);
}

-(CGPoint) fromMercator:(float) lat_ :(float) lng_
{
	float lng = lng_ * 180 / 20037508.34;
	float lat = lat_ * 180 / 20037508.34;
	lat = 180/M_PI * (2 * atan(exp(lat * M_PI / 180)) - M_PI / 2);
	return CGPointMake(lat, lng);
}


-(float) getResolution
{
	return [[self performJavaScript:@"map._getResolution();"]floatValue];
}


-(float) getResolution:(int) zoom
{
	return [[self performJavaScript:[NSString stringWithFormat:@"map._getResolution(%i);",zoom]]floatValue];
}



-(CGPoint) transformLatLngToPoint:(float) lat :(float) lng
{
    NSString* strCenter = [self performJavaScript:[NSString stringWithFormat:@"transformLatLngToPix(%f,%f);",lat,lng]];
	float fLatitude,fLongitude;
    const char* buf = [strCenter cStringUsingEncoding:NSASCIIStringEncoding];
	sscanf(buf,"(%f, %f)",&fLatitude,&fLongitude);
	CGPoint ptCenter = CGPointMake(fLatitude,fLongitude);
	return ptCenter;   
}

-(CGPoint) transformPointToLatLng:(float) x :(float) y
{
	NSString* script = 
	[NSString stringWithFormat:
	 @"point = new CM.LatLng(map.getCenter().toMercator().lat() - map._getResolution() * %f,map.getCenter().toMercator().lng() + map._getResolution() * %f).fromMercator();"
	 "point.toString();"
	 ,(y-208),(x-160)];
    NSString* strCenter = [self performJavaScript:script];
	float fLatitude,fLongitude;
    const char* buf = [strCenter cStringUsingEncoding:NSASCIIStringEncoding];
	sscanf(buf,"(%f, %f)",&fLatitude,&fLongitude);
	CGPoint ptCenter = CGPointMake(fLatitude,fLongitude);
	return ptCenter;
 }


-(CGPoint) getMapCenter
{
	NSString* strCenter = [self performJavaScript:@"map.getCenter().toString()"];
	float fLatitude,fLongitude;
    const char* buf = [strCenter cStringUsingEncoding:NSASCIIStringEncoding];
	sscanf(buf,"(%f, %f)",&fLatitude,&fLongitude);
	CGPoint ptCenter = CGPointMake(fLatitude,fLongitude);
	return ptCenter;
}

-(void) fillArrayOfDistances
{
	arrayOfDistances = malloc(sizeof(CGPoint)*MAX_ZOOM_LEVEL);
	for(int i=0;i<MAX_ZOOM_LEVEL;++i)
	{
		float fRes = [self getResolution:i  ];
		CGPoint mapCenter = [self getMapCenter];
		mapCenter = [self toMercator:mapCenter.x :mapCenter.y];
		CGPoint left = [self fromMercator: mapCenter.x - fRes*140 :mapCenter.y - fRes*190 ];
		CGPoint right = [self fromMercator: mapCenter.x + fRes*140 :mapCenter.y + fRes*190 ];		
		CGPoint dist = CGPointMake(right.x - left.x,right.y - left.y);
		arrayOfDistances[i] = dist;
	}
}

-(int) findRelevantZoom:(float) latDiff :(float) lngDiff
{
	for(int i=MAX_ZOOM_LEVEL-1 ; i>=0 ; --i)
	{
		if( arrayOfDistances[i].x >= latDiff && arrayOfDistances[i].y >= lngDiff )
			return i;
	}
	return 0; 
}

- (void) setMapZoom:(int) zoom
{
	[self performJavaScript:[NSString stringWithFormat:@"map.setZoom(%i);",zoom]];		
}

- (void) manageRotation:(UIInterfaceOrientation) orientation
{
	NSString* result;
	// PORTRAIT
	if( UIInterfaceOrientationPortrait == orientation || UIInterfaceOrientationPortraitUpsideDown == orientation )
	{
		result = [self performJavaScript:@"resizeDiv(320,412);"];
	}
	// LANDSCAPE
	if(UIInterfaceOrientationLandscapeLeft == orientation || UIInterfaceOrientationLandscapeRight == orientation)
	{
		result = [self performJavaScript:@"resizeDiv(480,320);"];	
	}

}

@end
