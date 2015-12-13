//
//  ViewController.m
//  Nemo-Master
//
//  Created by Junhan Huang on 12/8/15.
//  Copyright © 2015 Junhan Huang. All rights reserved.
//

#import "ViewController.h"
#import "Helper.h"
#import "ParkingSpot.h"
#import "ParkingSpots.h"
#import "AppDelegate.h"

@interface ViewController () <ParkingSpotModelDelegate>

@end



@implementation ViewController {
    CLLocationManager *locationManager;
}
- (ParkingSpots *)parkingSpots {
    return [AppDelegate appDelegate].parkingSpots;
}
- (void)viewWillAppear:(BOOL)animated {
    [self.mapUIView addObserver:self forKeyPath:@"myLocation" options:0 context:nil];
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIImage *nemo = [UIImage imageNamed:@"Nemo"];
    UIImage *camera = [UIImage imageNamed:@"Camera"];
    [Helper customizeBarButton:self.fishButton image:nemo highlightedImage:nemo];
    [Helper customizeBarButton:self.cameraButton image:camera highlightedImage:camera];
    
    
    // Getting My Location
    //Instantiate a location object.
    locationManager = [[CLLocationManager alloc] init];
    [locationManager setDelegate:self];
    
    //Set some parameters for the location object.
    [locationManager setDistanceFilter:kCLDistanceFilterNone];
    [locationManager setDesiredAccuracy: kCLLocationAccuracyBest];
    [locationManager requestWhenInUseAuthorization];
    [locationManager startUpdatingLocation];
    NSLog(@"created locationManager");
    
    
    // Google Map View
    self.mapUIView.delegate = self;
    self.mapUIView.settings.myLocationButton = YES;
    self.mapUIView.settings.compassButton = YES;
    self.mapUIView.mapType = kGMSTypeNormal;
    
    
    self.mapUIView.padding = UIEdgeInsetsMake(self.topLayoutGuide.length + 10, 0, self.bottomLayoutGuide.length, 0);
    
    /* Setting Up Markers */
    for (ParkingSpot *ps in [self.parkingSpots filteredParkingSpots]) {
        GMSMarker *marker = [[GMSMarker alloc] init];
        marker.position = CLLocationCoordinate2DMake([[ps latitude] doubleValue], [[ps longitude] doubleValue]);
        marker.title = [ps name];
        marker.map = self.mapUIView;
    }
}

- (void)modelUpdated {
    
}

- (void)enableMyLocation
{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    if (status == kCLAuthorizationStatusNotDetermined)
        [self requestLocationAuthorization];
    else if (status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusRestricted)
        return; // we weren't allowed to show the user's location so don't enable
    else
        [self.mapUIView setMyLocationEnabled:YES];
}

// Ask the CLLocationManager for location authorization,
// and be sure to retain the manager somewhere on the class

- (void)requestLocationAuthorization
{
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    
    [locationManager requestAlwaysAuthorization];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status != kCLAuthorizationStatusNotDetermined) {
        [self performSelectorOnMainThread:@selector(enableMyLocation) withObject:nil waitUntilDone:[NSThread isMainThread]];
        
        locationManager.delegate = nil;
        locationManager = nil;
    }
}

#pragma - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

- (void)locationManager: (CLLocationManager *) manager didUpdateLocations:(nonnull NSArray<CLLocation *> *)locations {
    NSLog(@"didUpdateToLocation: %@", locations);
    CLLocation *currentLocation = [locations lastObject];
    
    if (currentLocation != nil) {
        CLLocationCoordinate2D target =
        CLLocationCoordinate2DMake(currentLocation.coordinate.latitude, currentLocation.coordinate.longitude);
        
        [self.mapUIView animateToLocation:target];
        [self.mapUIView animateToZoom:17];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if([keyPath isEqualToString:@"myLocation"]) {
        CLLocation *location = [object myLocation];
        //...
        NSLog(@"Location, %@,", location);
        
        CLLocationCoordinate2D target =
        CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude);
        
        [self.mapUIView animateToLocation:target];
        [self.mapUIView animateToZoom:17];
    }
}

- (void)dealloc {
    [self.mapUIView removeObserver:self forKeyPath:@"myLocation"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
