//
//  ParkingSpot.m
//  Nemo-Master
//
//  Created by Curtis Li on 12/10/15.
//  Copyright © 2015 Junhan Huang. All rights reserved.
//

#import "ParkingSpot.h"
#define safeSet(d,k,v) if (v) d[k] = v;

@implementation ParkingSpot

- (id) init {
    self = [super init];
    return self;
}

- (instancetype) initWithDictionary:(NSDictionary*)dictionary
{
    self = [super init];
    if (self) {
        _name = dictionary[@"name"];
        _price = dictionary[@"price"];
        _latitude = dictionary[@"latitude"];
        _longitude = dictionary[@"longitude"];
        _zoom = dictionary[@"zoom"];
        __id = dictionary[@"_id"];
        _imageId = dictionary[@"imageId"];
        _create_date = dictionary[@"create_date"];
    }
    return self;
}

- (NSDictionary*) toDictionary
{
    NSMutableDictionary* jsonable = [NSMutableDictionary dictionary];
    safeSet(jsonable, @"name", self.name);
    safeSet(jsonable, @"price", self.price);
    safeSet(jsonable, @"latitude", self.latitude);
    safeSet(jsonable, @"longitude", self.longitude);
    safeSet(jsonable, @"zoom", self.zoom);
    safeSet(jsonable, @"_id", self._id);
    safeSet(jsonable, @"imageId", self.imageId);
    safeSet(jsonable, @"create_date", self.create_date);
    return jsonable;
}

@end
