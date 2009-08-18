//
//  Location.h
//  routeConcepts
//
//  Created by Fabian Girolstein on 24.07.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Class which describes user locations 
@interface Location : NSObject
{
	NSString* strName;  /**< location's name*/
	NSString* strDesc;  /**< location's description*/
	NSString* strTag;   /**< location's tags*/
	NSString* strID;    /**< location's ID (usualy hiddend from user) is used for delete and update location*/
	float fLatitude;    /**< location's latitude*/
	float fLongitude;   /**< location's longitude*/
	NSString* strURL;	/**< location's icon's file name*/
	NSString* strPhotoName;	 /**< location's photos name*/
	BOOL bStaticPlace;
}

@property (nonatomic,readwrite)	BOOL bStaticPlace;
@property (nonatomic,retain) NSString* strName;
@property (nonatomic,retain) NSString* strDesc;
@property (nonatomic,retain) NSString* strTag;
@property (nonatomic,retain) NSString* strID;
@property (nonatomic,readwrite) float fLatitude;
@property (nonatomic,readwrite) float fLongitude;
@property (nonatomic,retain) NSString* strURL;
@property (nonatomic,retain) NSString* strPhotoName;
/**
 Reset locations properties to default 
 */ 
-(void) reset;
+(Location*) initWithFeatures:(NSDictionary*) features;
@end
