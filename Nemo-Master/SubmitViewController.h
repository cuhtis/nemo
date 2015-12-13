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
@property (strong, nonatomic) IBOutlet NSString *EncodedImage;

- (UIImage *)decodeBase64ToImage:(NSString *)strEncodeData;

@end
