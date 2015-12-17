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
#import "Cloudinary/Cloudinary.h"


static NSString* const kBaseURL = @"http://nemo-server.herokuapp.com/";
static NSString* const kParkingSpots = @"parkingspots";
static NSString* const kFiles = @"files";

@interface ParkingSpots () <CLUploaderDelegate>
@property (nonatomic, strong) NSMutableArray* objects;
@property (nonatomic, strong) CLCloudinary *cloudinary;
@property (nonatomic, strong) CLUploader* uploader;
@end

@implementation ParkingSpots 

- (id)init
{
    NSLog(@"ParkingSpots: init");
    self = [super init];
    if (self) {
        _objects = [NSMutableArray array];
        _cloudinary = [[CLCloudinary alloc] initWithUrl: @"cloudinary://265243673751934:nk-B3zZLuFLdadYLOdTOKVWCGLY@heuthqgbj"];
        _uploader = [[CLUploader alloc] init:_cloudinary delegate:self];
    }
    return self;
}

- (NSArray*) filteredParkingSpots
{
    NSLog(@"filteredParkingSpots");
    return [self objects];
}

- (void) addParkingSpot:(ParkingSpot*)parkingSpot
{   NSLog(@"addedParkingSpots");
    [self.objects addObject:parkingSpot];
}

- (void)loadImage:(ParkingSpot *)parkingSpot
{
    NSLog(@"loadImage");
    CLTransformation *transformation = [CLTransformation transformation];
    [transformation setParams: @{@"width": @200,
                                 @"height": @179,
                                 @"angle": @90,
                                 @"crop": @"thumb"}];
    NSURL *url = [NSURL URLWithString:[self.cloudinary url:[NSString stringWithFormat:@"%@.png", parkingSpot.imageId] options:@{@"transformation": transformation}]];
    
    NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:config];
    
    NSURLSessionDownloadTask* task = [session downloadTaskWithURL:url completionHandler:^(NSURL *fileLocation, NSURLResponse *response, NSError *error) {
        if (!error) {
            NSData* imageData = [NSData dataWithContentsOfURL:fileLocation];
            UIImage* image = [UIImage imageWithData:imageData];
            if (!image) {
                NSLog(@"unable to build image");
            }
            parkingSpot.image = image;
            if (self.delegate) {
                NSLog(@"Built image, update delegate");
                [self.delegate modelUpdated];
            } else {
                NSLog(@"Built image, no delegate found");
            }
        }
    }];
    
    [task resume];
}

- (void)import
{
    NSLog(@"import");
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
{   NSLog(@"parseAndAddParkingSpots");
    for (NSDictionary* item in parkingSpots) {
        ParkingSpot* parkingSpot = [[ParkingSpot alloc] initWithDictionary:item];
        [destinationArray addObject:parkingSpot];
        
        if (parkingSpot.imageId) {
            [self loadImage:parkingSpot];
        }
    }
    
    if (self.delegate) {
        NSLog(@"Parsed, update model");
        [self.delegate modelUpdated];
        NSLog(@"Model updated");
    } else {
        NSLog(@"No delegate found");
    }
}

- (void) saveNewImageFirst:(ParkingSpot*)parkingSpot
{
    NSLog(@"saveNewImageFirst");
    NSURL* url = [NSURL URLWithString:[kBaseURL stringByAppendingPathComponent:kFiles]];
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
    NSLog(@"ParkingSpots: persist (%@)", parkingSpot.name);
    
    if (!parkingSpot || parkingSpot.name == nil || parkingSpot.name.length == 0) {
        return; //input safety check
    }
    
    //if there is an image, save it too
    if (parkingSpot.image != nil && parkingSpot.imageId == nil) {
        NSData* bytes = UIImagePNGRepresentation(parkingSpot.image);
        [self.uploader upload:bytes options:0 withCompletion:^(NSDictionary *successResult, NSString *errorResult, NSInteger code, id context){
            parkingSpot.imageId = [successResult valueForKey:@"public_id"];
            [self persist:parkingSpot];
        } andProgress:nil];
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
            NSLog(@"Update objects list");
            
            NSArray* responseArray = @[[NSJSONSerialization JSONObjectWithData:data options:0 error:NULL]];
            [self parseAndAddParkingSpots:responseArray toArray:self.objects];
        }
    }];
    [dataTask resume];
}
@end
