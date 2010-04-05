//
//  Location.m
//  routeConcepts
//
//  Created by Fabian Girolstein on 24.07.09.
//  Copyright 2009-2010 __MyCompanyName__. All rights reserved.
//

#import "Location.h"
#import "Utils.h"
#import "HelperConstant.h"


#define __REVERSED__ORDER__		

@implementation Location

@synthesize strName;
@synthesize  strDesc;
@synthesize  strTag;
@synthesize  strID;
@synthesize strURL;
@synthesize fLatitude;
@synthesize fLongitude;
@synthesize strPhotoName;
@synthesize bStaticPlace;

-(void) reset
{
	strName = @"";
    strDesc = @"";
	strTag = @"";
	strID = @"";
	strPhotoName = @"";
	fLatitude = 0.0f;
	fLongitude = 0.0f;
	bStaticPlace = FALSE;
}
+(NSString*) setName:(NSDictionary*) features
{
	NSString* name = [[features objectForKey:@"properties"] objectForKey:@"name"];
	if(![name length])
	{
		name = [[features objectForKey:@"properties"] objectForKey:@"int_name"];
	}
	else
	{
		NSString* alt_name = [[features objectForKey:@"properties"] objectForKey:@"int_name"];
		if([alt_name length]>0)
		{
			name = [NSString stringWithFormat:@"%@ (%@)",name,alt_name];
		}
	}
	return name;
}

+(NSString*) setDescription:(NSDictionary*) features
{
	NSString* tags = nil;
	NSString* city = [[features objectForKey:@"location"] objectForKey:@"city"];
	NSString* postcode = [[features objectForKey:@"location"] objectForKey:@"postcode"];
	if(city)
	{
		if(postcode)
			tags = [NSString stringWithFormat:@"%@, %@",city,postcode];
		else
			tags = [NSString stringWithFormat:@"%@",city];
	}
	else
		if(postcode)
		{
			tags = [NSString stringWithFormat:@"%@",postcode];
		}
	return tags;
}

+(NSString*) setTags:(NSDictionary*) features
{
	NSString* tags = [[features objectForKey:@"location"] objectForKey:@"country"];
	return tags;
}

+(Location*) initWithFeatures:(NSDictionary*) features
{
	Location* loc = [[Location alloc] init];
	//loc.strName = [[features objectForKey:@"properties"] objectForKey:@"name"];
	
	loc.strName = [Location setName:features];	
	loc.strTag = [Location setTags:features];
	loc.strDesc = [Location setDescription:features];
	loc.strURL  = [NSString stringWithFormat:@"%s%s",IMAGE_URL,DEFAULT_IMAGE_NAME];
    loc.strPhotoName = [NSString stringWithFormat:@"%s%@",PHOTO_URL,DEFAULT_PHOTO_NAME]; 
	loc.bStaticPlace = TRUE;
	
	
	NSDictionary* centroid = [features objectForKey:@"centroid"];
	if( [[centroid objectForKey:@"type"] isEqualToString:@"POINT"])
	{
		NSArray* coordinates = [centroid objectForKey:@"coordinates"];
#ifndef __REVERSED__ORDER__		
		loc.fLongitude = [[coordinates objectAtIndex:0] doubleValue];
		loc.fLatitude = [[coordinates objectAtIndex:1] doubleValue];
#else		
		loc.fLongitude = [[coordinates objectAtIndex:1] doubleValue];
		loc.fLatitude = [[coordinates objectAtIndex:0] doubleValue];
#endif // __REVERSED__ORDER__				
	}
	return loc;
}
@end
