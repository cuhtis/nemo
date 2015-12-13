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
@synthesize scrollView;


- (void) modelUpdated {
    // DO NOTHING
    NSLog(@"HI");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _SnapShot.image = _snappedImage;
    
    // Do any additional setup after loading the view.
    
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

- (ParkingSpots *)parkingSpots {
    return [AppDelegate appDelegate].parkingSpots;
}

- (void) dismissKeyboard {
    [_NameField resignFirstResponder];
    [_LatField resignFirstResponder];
    [_LongField resignFirstResponder];
    [_PriceField resignFirstResponder];
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
    NSLog(@"DONE");
}
@end
