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

@property (nonatomic, copy) NSString *name;         //automatically added / Can be manually changed
@property (nonatomic, copy) NSString *_id;          //ignore
@property (nonatomic, copy) NSNumber *price;        //ask customer
@property (nonatomic, copy) NSNumber *longitude;    //ask robin
@property (nonatomic, copy) NSNumber *latitude;     //ask robin
@property (nonatomic, copy) NSNumber *zoom;         //ask robin
@property (nonatomic, copy) NSNumber *is_taken;     //default NO

@property (nonatomic, strong) UIImage* image;//get put in
@property (nonatomic, copy) NSString* imageId; //ignore

- (instancetype) initWithDictionary:(NSDictionary*)dictionary;
- (NSDictionary*) toDictionary;

@end
