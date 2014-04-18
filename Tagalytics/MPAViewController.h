//
//  MPAViewController.h
//  Tagalytics
//
//  Created by Tim McHale on 2/25/14.
//  Copyright (c) 2014 Tim McHale. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MPAViewController : UIViewController <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *datePickerUno;
@property (weak, nonatomic) IBOutlet UITextField *datePickerDos;

@property (strong, nonatomic) NSDate *dateUno;
@property (strong, nonatomic) NSDate *dateDos;



- (IBAction)update:(id)sender;

@end
