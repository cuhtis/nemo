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

- (void) modelUpdated {
    // DO NOTHING
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _SnapShot.image = _snappedImage;
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (ParkingSpots *)parkingSpots {
    return [AppDelegate appDelegate].parkingSpots;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)SubmitForm:(id)sender {
    ParkingSpot *parkingSpot = [[ParkingSpot alloc] init];
    [parkingSpot setImage:_snappedImage];
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    [parkingSpot setName:_NameField.text];
    [parkingSpot setPrice:[f numberFromString:_PriceField.text]];
    [parkingSpot setLongitude:[f numberFromString:_LongField.text]];
    [parkingSpot setLatitude:[f numberFromString:_LatField.text]];
    [self.parkingSpots addParkingSpot:parkingSpot];
    [self.parkingSpots persist:parkingSpot];
}
@end
