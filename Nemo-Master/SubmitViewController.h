//
//  SubmitViewController.h
//  Nemo-Master
//
//  Created by Jonathan Chen on 12/11/15.
//  Copyright (c) 2015 Junhan Huang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SubmitViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIImageView *SnapShot;
@property (strong, nonatomic) IBOutlet UIImage *snappedImage;
@property (strong, nonatomic) IBOutlet UITextField *NameField;
@property (strong, nonatomic) IBOutlet UITextField *LatField;
@property (strong, nonatomic) IBOutlet UITextField *LongField;
@property (strong, nonatomic) IBOutlet UITextField *PriceField;

- (IBAction)SubmitForm:(id)sender;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@end
