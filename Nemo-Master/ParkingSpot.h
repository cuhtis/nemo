//
//  ParkingSpot.h
//  Nemo-Master
//
//  Created by Curtis Li on 12/10/15.
//  Copyright © 2015 Junhan Huang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ParkingSpot : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *_id;
@property (nonatomic, copy) NSNumber *price;
@property (nonatomic, copy) NSNumber *longitude;
@property (nonatomic, copy) NSNumber *latitude;
@property (nonatomic, copy) NSNumber *zoom;
@property (nonatomic, copy) NSNumber *is_taken;

@property (nonatomic, strong) UIImage* image;
@property (nonatomic, copy) NSString* imageId;

- (instancetype) initWithDictionary:(NSDictionary*)dictionary;
- (NSDictionary*) toDictionary;

@end
