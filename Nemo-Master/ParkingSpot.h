//
//  ParkingSpot.h
//  Nemo-Master
//
//  Created by Curtis Li on 12/10/15.
//  Copyright © 2015 Junhan Huang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@import GoogleMaps;

/* ParkingSpot is a object representing a single parking spot */
@interface ParkingSpot : NSObject

@property (nonatomic, copy) NSString *name;         // Street name
@property (nonatomic, copy) NSString *_id;          // Unique identifier
@property (nonatomic, copy) NSNumber *price;        // User-inputted price
@property (nonatomic, copy) NSNumber *longitude;    // GMS Longitudinal coordinate
@property (nonatomic, copy) NSNumber *latitude;     // GMS Latitudinal coordinate
@property (nonatomic, copy) NSNumber *zoom;         // GMS Zoom
@property (nonatomic, copy) NSNumber *is_taken;     // If it is claimed
@property (nonatomic, copy) NSString *create_date;  // Date created

@property (nonatomic, strong) GMSMarker *marker;    // Reference to GMS marker

@property (nonatomic, strong) UIImage* image;       // Photo of parking spot
@property (nonatomic, copy) NSString* imageId;      // Photo's unique identifier

// Initialize with a NSDictionary from a JSON string
- (instancetype) initWithDictionary:(NSDictionary*)dictionary;
// Represent the parking spot as a NSDictionary
- (NSDictionary*) toDictionary;

@end
