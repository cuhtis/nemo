//
//  CameraViewController.h
//  Nemo-Master
//
//  Created by Kimberly Stickels on 12/9/15.
//  Copyright (c) 2015 Junhan Huang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface CameraViewController : UIViewController{
    IBOutlet UIView *frameforCapture;
    IBOutlet UIImageView *imageView;
}
@property (strong, nonatomic) IBOutlet UIButton *retakeBut;
@property (strong, nonatomic) IBOutlet UIButton *snapBut;
@property (strong, nonatomic) IBOutlet UIButton *submitBut;

- (IBAction)takephoto:(id)sender;
- (IBAction)retakephoto:(id)sender;

@end
