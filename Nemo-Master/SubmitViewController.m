//
//  SubmitViewController.m
//  Nemo-Master
//
//  Created by Jonathan Chen on 12/11/15.
//  Copyright (c) 2015 Junhan Huang. All rights reserved.
//

#import "SubmitViewController.h"
#import "ParkingSpot.h"
#import "ParkingSpots.h"
#import "AppDelegate.h"

@interface SubmitViewController () <ParkingSpotModelDelegate>

@end

@implementation SubmitViewController
BOOL firstLocationUpdate_;
CLLocationManager *locationManager;
@synthesize scrollView;


- (void) modelUpdated {
}

- (void)viewWillDisappear:(BOOL)animated {
    [locationManager stopUpdatingLocation];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /* Get Current Location */
    locationManager = [[CLLocationManager alloc] init];
    [locationManager setDelegate:self];
    
    //Set some parameters for the location object.
    [locationManager setDistanceFilter:kCLDistanceFilterNone];
    [locationManager setDesiredAccuracy: kCLLocationAccuracyBest];
    [locationManager requestWhenInUseAuthorization];
    [locationManager startUpdatingLocation];
    
    firstLocationUpdate_ = YES;
    
    /* Submit Parking Entry */
    _SnapShot.image = _snappedImage;
    _SnapShot.hidden = YES;
        
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    CGPoint scrossPoint = CGPointMake(0, textField.frame.origin.y);
    [scrollView setContentOffset:scrossPoint animated:YES];
}

-(void) textFieldDidEndEditing:(UITextField *)textField{
    [scrollView setContentOffset:CGPointZero animated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    NSLog(@"Dealloc SubmitViewController");
}

- (ParkingSpots *)parkingSpots {
    return [AppDelegate appDelegate].parkingSpots;
}

- (void) dismissKeyboard {
    [_NameField resignFirstResponder];
    [_LatField resignFirstResponder];
    [_LongField resignFirstResponder];
    [_PriceField resignFirstResponder];
}

// Ask the CLLocationManager for location authorization,
// and be sure to retain the manager somewhere on the class

- (void)requestLocationAuthorization
{
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    
    [locationManager requestAlwaysAuthorization];
}

- (void)locationManager: (CLLocationManager *) manager didUpdateLocations:(nonnull NSArray<CLLocation *> *)locations {
    CLLocation *currentLocation = [locations lastObject];
    if (currentLocation != nil && firstLocationUpdate_) {
        _LatField.text = [NSString stringWithFormat:@"%f", currentLocation.coordinate.latitude];
        _LongField.text = [NSString stringWithFormat:@"%f", currentLocation.coordinate.longitude];
        
        [[GMSGeocoder geocoder] reverseGeocodeCoordinate:currentLocation.coordinate
                                       completionHandler:
         ^(GMSReverseGeocodeResponse *response, NSError *error){
             _NameField.text = response.firstResult.thoroughfare;
         }];
        _PriceField.text = @"0";
        firstLocationUpdate_ = NO;

    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
   
    
    
}

- (IBAction)SubmitForm:(id)sender {
    NSLog(@"SubmitForm");
    ParkingSpot *parkingSpot = [[ParkingSpot alloc] init];
    [parkingSpot setImage:_snappedImage];
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    [parkingSpot setName:_NameField.text];
    [parkingSpot setPrice:[f numberFromString:_PriceField.text]];
    [parkingSpot setLongitude:[f numberFromString:_LongField.text]];
    [parkingSpot setLatitude:[f numberFromString:_LatField.text]];
    [parkingSpot setCreate_date:[NSDate date].description];
    
    
    // Sets global marker variable to the marker just added
    if (![AppDelegate appDelegate].globalSpot) {
        [AppDelegate appDelegate].globalSpot = parkingSpot;
    }
    
    [self.parkingSpots persist:parkingSpot];
    
    
    
}
@end
