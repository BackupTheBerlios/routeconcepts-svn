//
//  HelperConstant.h
//  routeConcepts
//
//  Created by Fabian Girolstein on 24.07.09.
//  Copyright 2009-2010 __MyCompanyName__. All rights reserved.
//

//#define BASEURL "http://data.giub.uni-bonn.de/openrouteservice/tmp/my_proxy.html"
#define BASEURL "http://172.16.30.33/~Fab/my_proxy.html"
#define APIKEY   "e391c3e06382502e94212387b6b7f4ef"
#define STILEID 2
#define ZOOM    15
#define TILE_SIZE 256
#define BUSEGPS   FALSE
#define LATITUDE  52.377538
#define LONGITUDE 4.895375
#define DEFAULT_TILESERVER  "tile.openstreetmap.org"     // rootDomain
#define SUBDOMAINS   "abc"
#define WIDTH	320
#define HEIGHT	480


#define MAX_ZOOM_LEVEL  18 

#define DROPPED_TOUCH_MOVED_EVENTS_RATIO  (0.8)
#define ZOOM_IN_TOUCH_SPACING_RATIO       (0.75)
#define ZOOM_OUT_TOUCH_SPACING_RATIO      (1.5)



#define TERM_OF_USE_PORTRAIT  CGPointMake(160,388)
#define MAP_FRAME_PORTRAIT    CGRectMake(0,0 ,320,412)
#define TERM_OF_USE_LANDSCAPE  CGPointMake(240,259)
#define MAP_FRAME_LANDSCAPE    CGRectMake(0,0 ,480,320)
#define DEFAULT_IMAGE_NAME "Pin.png"
#define DEFAULT_PHOTO_NAME @"noimage.png"

#define SAVE_PASSWORD @"save_password"
#define USER_NAME @"user_name"
#define USER_PASSWORD @"user_password"
#define EXPIRING_TIME @"expiring_time"
#define USER_TOKEN    @"token"

#define __PRODUCTION__
#define IPHONE_API_SAMPLES






#define AUTHORIZATION_BASE_URL @"http://authorization.cloudmade.com/authorize"
#define IMAGE_URL "http://cloudmade.com/images/iphone/markers/"
#define PHOTO_URL "http://cloudmade.com/images/iphone/photos/"
#define LOCATION_BASE_URL @"http://cloudmade.com/places/"

#define DEFAULT_TAG @"untagged"
#define DEFAULT_DESC @"no description"


#define NUMBER_OF_ICONS 5


//! Struct which describes token's properties
typedef struct _USER_CREDENTIAL_
{
	NSString* userToken;     /**< user token */
	NSDate*   expiringDate;  /**< token's expiring time */
} UserCredential;
//! Protocol which has to be adobted to get messages about marker changes
@protocol PlaceWasClicked
/**
  * Is called when marker was tapped
  * @param caller instance of PlaceMarker
 */
@optional
-(void) markerWasClicked:(id) caller;
/**
 * Is called when marker was moved
 * @param caller instance of PlaceMarker
 */
-(void) markerWasMoved:(id) caller;
@end

