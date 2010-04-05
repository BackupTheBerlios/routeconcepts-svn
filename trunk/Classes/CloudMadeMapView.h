//
//  CloudMadeMapView.h
//  routeConcepts
//
//  Created by Fabian Girolstein on 24.07.09.
//  Copyright 2009-2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

extern CGPoint gfRealMapCenter;

 //! Struct keeps map and user settings
struct MapSettings
{
	const char* baseUrl;
	const char* apiKey;		/**< key to access map. Has to  be obtained from http://cloudmade.com/developers */
	int styleID;			/**< map's stileID*/
	int tileSize;			/**< tile's size*/
	int Zoom;				/**< map's zoom*/
	BOOL bUseGPS;			/**< use GPS or not */
	float Latitude;			/**< latitude where map will be centered*/
	float Longitude;		/**< longitude where map will be centered*/
	const char* rootDomain; /**< URL for tile server */
	const char* subDomain;  /**< subdomains names */
	int width;
	int height;
};

//! View which delivers map to end user. Inherited from UIWebView. Implements UIWebViewDelegate protocol for handling errors and informational messages
@interface CloudMadeMapView : UIWebView <UIWebViewDelegate,CLLocationManagerDelegate> {
	CLLocationManager* locationManager;
	struct MapSettings mapSettings;
	CGPoint* arrayOfDistances;		
}
- (void) setCenterWithPixel:(int)dx :(int)dy;

/**
   * Initializes map by MapSettings structure
   * @param mapsettings Initialized map with given parameters \sa  MapSettings
 */
- (void) initializeMap:(struct MapSettings)mapsettings;

/**
  * Zooms out map
*/ 
- (void) zoomOut;

/**
  * Zooms in map
 */ 
- (void) zoomIn;

/**
 * Moves center of the map to given point 
 * @param lat Latitude
 * @param lon Longitude
*/
- (void) setCenter:(float)lat :(float)lon;

/**
 * Changes map style
 * @param styleID style's ID 
 * @param rootUrl URL for tiles
 * @param subDomains sub-domains for tiles server
 * @param tileSize tile's size
 * @param apiKey key for accessing map.
 */
- (void) changeMapStyle:(int)styleID :(const char*)rootUrl :(const char*)subDomains :(int)tileSize :(const char*)apiKey;

/**
 * Returns bound box of current screen
 * @return bound box in CGRect class 
 */
- (CGRect) getBoundBox:(CGSize) size;

/**
 * Transform latitude and longitude to screen coordinate
 * @param lat Latitude
 * @param lng Longitude
 * @return screen coordinates
 * \sa transformPointToLatLng
 */
- (CGPoint) transformLatLngToPoint:(float) lat :(float) lng;

/**
 * Transform screen coordinate to latitude and longitude
 * @param x X coordinate of the point
 * @param y Y coordinate of thr point
 * @return latitude and longitude
 * \sa transformLatLngToPoint
 */
- (CGPoint) transformPointToLatLng:(float) x :(float) y;

/**
 *  Returns center of the map 
 *  @return latitude and longitude 
 */
- (CGPoint) getMapCenter;  

/**
 * return map's resolution (is used for zoom calculation)
 */
- (float) getResolution:(int) zoom;

/**
 * Mercator's transformation (latitude and longitude)
 * @param lat_ latitude
 * @param lng_ longitude
 * @return tranformad point
 * \sa fromMercator
 */
- (CGPoint) toMercator:(float) lat_ :(float) lng_;

/**
 * Mercator's transformation (latitude and longitude)
 * @param lat_ latitude
 * @param lng_ longitude
 * @return tranformad point
 * \sa toMercator
 */
- (CGPoint) fromMercator:(float) lat_ :(float) lng_;

/**
 * Searches relevant zoom for given latitude and longitude
 * @param  latDiff latitude's length 
 * @param  lngDiff longitude's length  
 * @return zoom which should fit given conditions
 */
- (int) findRelevantZoom:(float) latDiff :(float) lngDiff;

/**
 * Sets map zoom
 * @param zoom map's zoom
 */
- (void) setMapZoom:(int) zoom;

/**
 * Handle device rotation's 
 * @param orientation current device's orientation
 */
- (void) manageRotation:(UIInterfaceOrientation) orientation;

- (int)getZoom;

@end
