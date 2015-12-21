//
//  ParkingSpots.m
//  Nemo-Master
//
//  Created by Curtis Li on 12/10/15.
//  Copyright © 2015 Junhan Huang. All rights reserved.
//

#import "GlobalHead.h"
#import "ParkingSpots.h"
#import "ParkingSpot.h"
#import <UIKit/UIKit.h>
#import "Cloudinary/Cloudinary.h"

// Server path strings
static NSString* const kBaseURL = @"http://nemo-server.herokuapp.com/";
static NSString* const kParkingSpots = @"parkingspots";

@interface ParkingSpots () <CLUploaderDelegate>

@property (nonatomic, strong) NSMutableArray* objects;  // Local array of ParkingSpot objects
@property (nonatomic, strong) CLCloudinary *cloudinary; // Cloudinary access (for images)
@property (nonatomic, strong) CLUploader* uploader;     // Cloudinary uploader

@end


@implementation ParkingSpots 


- (id)init
{
#ifdef DEBUG_NEMO
    NSLog(@"ParkingSpots: init");
#endif
    
    // Super init
    self = [super init];
    
    // No init error
    if (self) {
        // Initialize local array of parking spots
        _objects = [NSMutableArray array];
        
        // Connect to remote Cloudinary image storage
        _cloudinary = [[CLCloudinary alloc] initWithUrl: @"cloudinary://265243673751934:nk-B3zZLuFLdadYLOdTOKVWCGLY@heuthqgbj"];
        
        // Intialize Cloudinary uploader
        _uploader = [[CLUploader alloc] init:_cloudinary delegate:self];
    }
    
    return self;
}

- (NSArray*) filteredParkingSpots
{
#ifdef DEBUG_NEMO
    NSLog(@"ParkingSpots: filteredParkingSpots");
#endif
    
    // Return the local array of parking spots
    return [self objects];
}

- (void) addParkingSpot:(ParkingSpot*)parkingSpot
{
#ifdef DEBUG_NEMO
    NSLog(@"ParkingSpots: addParkingSpot");
#endif
    
    // Add the parking spot to the local array of parking spots
    [self.objects addObject:parkingSpot];
}

- (void) removeParkingSpot:(ParkingSpot*)parkingSpot
{
#ifdef DEBUG_NEMO
    NSLog(@"ParkingSpots: deleteParkingSpot");
#endif
    
    // Remove the parking spot from the local array of parking spots
    [self.objects removeObject:parkingSpot];
}

- (void)loadImage:(ParkingSpot *)parkingSpot
{
#ifdef DEBUG_NEMO
    NSLog(@"ParkingSpots: loadImage (%@)", parkingSpot.name);
#endif
    
    // Setup Cloudinary image transformations
    CLTransformation *transformation = [CLTransformation transformation];
    [transformation setParams: @{@"width": @200,
                                 @"height": @179,
                                 @"angle": @90,
                                 @"crop": @"thumb"}];
    
    // Setup Cloudinary image URL
    // Cloudinary automatically generates a transformed image for download from a CDN
    NSURL *url = [NSURL URLWithString:[self.cloudinary url:[NSString stringWithFormat:@"%@.png", parkingSpot.imageId] options:@{@"transformation": transformation}]];
    
    // Default config settings
    NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:config];
    
    // Create the download task
    NSURLSessionDownloadTask* task = [session downloadTaskWithURL:url completionHandler:^(NSURL *fileLocation, NSURLResponse *response, NSError *error) {
        // Callback
        if (!error) {
            // Get UIImage from the URL
            NSData* imageData = [NSData dataWithContentsOfURL:fileLocation];
            UIImage* image = [UIImage imageWithData:imageData];
            
            // If there was an error in downloading the image
#ifdef DEBUG_NEMO
            if (!image) {
                NSLog(@"Unable to build image");
            }
#endif
            
            // Set the image of the parking spot to the downloaded image
            parkingSpot.image = image;
            
            if (self.delegate) {
#ifdef DEBUG_NEMO
                NSLog(@"Built image, update delegate");
#endif
                
                // Tell the delegate we updated the parking spots
                [self.delegate modelUpdated];
            } else {
#ifdef DEBUG_NEMO
                NSLog(@"Built image, no delegate found");
#endif
            }
        }
    }];
    
    // Start the download
    [task resume];
}

// Populate the local array from the database
- (void)import
{
#ifdef DEBUG_NEMO
    NSLog(@"ParkingSpots: Import");
#endif
    
    // Create URL request path
    NSURL* url = [NSURL URLWithString:[kBaseURL stringByAppendingPathComponent:kParkingSpots]];
    
    // Generate the GET request with JSON body type
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"GET";
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    // Default config
    NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:config];
    
    // Set up the data task and callback
    NSURLSessionDataTask* dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        // Callback function
        if (error == nil) {
            // Parse the returned data from JSON objects to NSDictionary
            NSArray* responseArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
            
            // Add the objects to the local array
            [self parseAndAddParkingSpots:responseArray toArray:self.objects];
        }
    }];
    
    // Start the data task / request
    [dataTask resume];
}

- (void)parseAndAddParkingSpots:(NSArray*)parkingSpots toArray:(NSMutableArray*)destinationArray
{
#ifdef DEBUG_NEMO
    NSLog(@"ParkingSpots: parseAndAddParkingSpots");
#endif
    
    // Loop through array of parking spots
    for (NSDictionary* item in parkingSpots) {
        
        // Initialize a new parking spot object for each dictionary and add it to the local array
        ParkingSpot* parkingSpot = [[ParkingSpot alloc] initWithDictionary:item];
        [destinationArray addObject:parkingSpot];
        
        // If the parking spot has an image, load it from Cloudinary
        if (parkingSpot.imageId) {
            [self loadImage:parkingSpot];
        }
    }
    
    // Tell the delegate we updated the parking spots
    if (self.delegate) {
#ifdef DEBUG_NEMO
        NSLog(@"Parsed, update model");
#endif
        [self.delegate modelUpdated];
    } else {
#ifdef DEBUG_NEMO
        NSLog(@"No delegate found");
#endif
    }
}

- (void) persist:(ParkingSpot*)parkingSpot
{
#ifdef DEBUG_NEMO
    NSLog(@"ParkingSpots: persist (%@)", parkingSpot.name);
#endif
    
    // Safety check
    if (!parkingSpot ||
        parkingSpot.name == nil ||
        parkingSpot.name.length == 0) {
        return;
    }
    
    //if there is an image, save it too
    if (parkingSpot.image != nil && parkingSpot.imageId == nil) {
        // Get image as a PNG
        NSData* bytes = UIImagePNGRepresentation(parkingSpot.image);
        
        // Use Cloudinary to upload the file
        [self.uploader upload:bytes options:0 withCompletion:^(NSDictionary *successResult, NSString *errorResult, NSInteger code, id context){
            // Callback, set parking spot's image ID and persist it
            parkingSpot.imageId = [successResult valueForKey:@"public_id"];
            [self persist:parkingSpot];
        } andProgress:nil];
        
        // Don't save the parking spot until image is saved
        return;
    }
    
    // Get the URL
    NSString* parkingSpots = [kBaseURL stringByAppendingPathComponent:kParkingSpots];
    BOOL exists = parkingSpot._id != nil;
    NSURL* url = exists ? [NSURL URLWithString:[parkingSpots stringByAppendingPathComponent:parkingSpot._id]] :
    [NSURL URLWithString:parkingSpots];
    
    // Request method depends on if creating a new parking spot or modifying it
    // POST = create, PUT = update
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = exists ? @"PUT" : @"POST";
    
    // Set the create date
    parkingSpot.create_date = [NSDate date].description;
    
    // Get the parking spot as a JSON object data
    NSData* data = [NSJSONSerialization dataWithJSONObject:[parkingSpot toDictionary] options:0 error:NULL];
    request.HTTPBody = data;
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    // Default config settings
    NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:config];
    
    // Setup the data task
    NSURLSessionDataTask* dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        // Callback
        if (!error) {
#ifdef DEBUG_NEMO
            NSLog(@"Update objects list");
#endif
            
            // Update the local array
            NSArray* responseArray = @[[NSJSONSerialization JSONObjectWithData:data options:0 error:NULL]];
            [self parseAndAddParkingSpots:responseArray toArray:self.objects];
        }
    }];
    
    // Start the data task/request
    [dataTask resume];
}
@end
