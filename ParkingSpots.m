//
//  ParkingSpots.m
//  Nemo-Master
//
//  Created by Curtis Li on 12/10/15.
//  Copyright © 2015 Junhan Huang. All rights reserved.
//

#import "ParkingSpots.h"
#import "ParkingSpot.h"
#import <UIKit/UIKit.h>

static NSString* const kBaseURL = @"http://nemo-server.herokuapp.com/";
static NSString* const kParkingSpots = @"parkingspots";
static NSString* const kImages = @"photos";

@interface ParkingSpots ()
@property (nonatomic, strong) NSMutableArray* objects;
@end

@implementation ParkingSpots

- (id)init
{
    self = [super init];
    if (self) {
        _objects = [NSMutableArray array];
    }
    return self;
}

- (NSArray*) filteredParkingSpots
{
    return [self objects];
}

- (void) addParkingSpot:(ParkingSpot*)parkingSpot
{
    [self.objects addObject:parkingSpot];
}

- (void)import
{
    NSURL* url = [NSURL URLWithString:[kBaseURL stringByAppendingPathComponent:kParkingSpots]];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"GET";
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:config];
    
    NSURLSessionDataTask* dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error == nil) {
            NSArray* responseArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
            [self parseAndAddParkingSpots:responseArray toArray:self.objects];
        }
    }];
    
    [dataTask resume];
}

- (void)parseAndAddParkingSpots:(NSArray*)parkingSpots toArray:(NSMutableArray*)destinationArray
{
    for (NSDictionary* item in parkingSpots) {
        ParkingSpot* location = [[ParkingSpot alloc] initWithDictionary:item];
        [destinationArray addObject:location];
    }
    
    if (self.delegate) {
        [self.delegate modelUpdated];
    }
}

- (void) saveNewImageFirst:(ParkingSpot*)parkingSpot
{
    NSURL* url = [NSURL URLWithString:[kBaseURL stringByAppendingPathComponent:kImages]];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    [request addValue:@"image/png" forHTTPHeaderField:@"Content-Type"];
    
    NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:config];
    
    NSData* bytes = UIImagePNGRepresentation(parkingSpot.image);
    NSURLSessionUploadTask* task = [session uploadTaskWithRequest:request fromData:bytes completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error == nil && [(NSHTTPURLResponse*)response statusCode] < 300) {
            NSDictionary* responseDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
            parkingSpot.imageId = responseDict[@"_id"];
            [self persist:parkingSpot];
        }
    }];
    [task resume];
}

- (void) persist:(ParkingSpot*)parkingSpot
{
    if (!parkingSpot || parkingSpot.name == nil || parkingSpot.name.length == 0) {
        return; //input safety check
    }
    
    // if there is an image, save it first
    if (parkingSpot.image != nil && parkingSpot.imageId == nil) {
        [self saveNewImageFirst:parkingSpot];
        return;
    }
    
    
    NSString* parkingSpots = [kBaseURL stringByAppendingPathComponent:kParkingSpots];
    
    BOOL exists = parkingSpot._id != nil;
    NSURL* url = exists ? [NSURL URLWithString:[parkingSpots stringByAppendingPathComponent:parkingSpot._id]] :
    [NSURL URLWithString:parkingSpots];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = exists ? @"PUT" : @"POST";
    
    NSData* data = [NSJSONSerialization dataWithJSONObject:[parkingSpot toDictionary] options:0 error:NULL];
    request.HTTPBody = data;
    
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:config];
    
    NSURLSessionDataTask* dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSArray* responseArray = @[[NSJSONSerialization JSONObjectWithData:data options:0 error:NULL]];
            [self parseAndAddParkingSpots:responseArray toArray:self.objects];
        }
    }];
    [dataTask resume];
}
@end
