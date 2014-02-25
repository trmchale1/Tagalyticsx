//
//  MPAViewController.m
//  Tagalytics
//
//  Created by Tim McHale on 2/25/14.
//  Copyright (c) 2014 Tim McHale. All rights reserved.
//

#import "MPAViewController.h"
#import <Parse/Parse.h>


@interface MPAViewController ()
@property (weak, nonatomic) IBOutlet UILabel *userContLabel;

@end

@implementation MPAViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self update:nil];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)update:(id)sender {
    
    UIButton *button = nil;
    if([sender isKindOfClass:[UIButton class]]) {
        button = (UIButton *)sender;
    }
    
    button.backgroundColor = [UIColor greenColor];
    
    PFQuery *query = [PFUser query];
    [query countObjectsInBackgroundWithBlock:^(int count, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"There are currently %d using Marco Polo.", count);
            
            NSString *prefix = @"The count is";
            self.userContLabel.text = [NSString stringWithFormat:@"%@ %d", prefix, count];
        } else {
            NSLog(@"FAILED");
        }
        
        button.backgroundColor = [UIColor clearColor];
        
    }];
}
@end
