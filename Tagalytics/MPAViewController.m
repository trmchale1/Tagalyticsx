//
//  MPAViewController.m
//  Tagalytics
//
//  Created by Tim McHale on 2/25/14.
//  Copyright (c) 2014 Tim McHale. All rights reserved.
//

#import "MPAViewController.h"
#import <Parse/Parse.h>
#import "MPATableTopUsers.h"


@interface MPAViewController ()
@property (weak, nonatomic) IBOutlet UILabel *userContLabel;
@property (weak, nonatomic) IBOutlet UILabel *todays_signups;
@property (weak, nonatomic) IBOutlet UILabel *todays_tags;
@property (weak, nonatomic) IBOutlet UILabel *todays_users;
@end

@implementation MPAViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSDate *today = [NSDate date];
    NSDate *yesterday = [today dateByAddingTimeInterval: -86400.0];
    
    self.dateUno = yesterday;
    self.dateDos = today;
    
    [self update:nil];
    
    
    UIDatePicker *datePicker = [[UIDatePicker alloc] init];
    [datePicker setDate:[NSDate date]];
    [datePicker addTarget:self action:@selector(updateTextField:) forControlEvents:UIControlEventValueChanged];
    
    UIDatePicker *datePickerDos = [[UIDatePicker alloc] init];
    [datePickerDos setDate:[NSDate date]];
    [datePickerDos addTarget:self action:@selector(updateTextFieldDos:) forControlEvents:UIControlEventValueChanged];
    
    [self.datePickerUno setInputView:datePicker];
    [self.datePickerDos setInputView:datePickerDos];
    

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
}

-(void)dismissKeyboard {
    [_datePickerUno resignFirstResponder];
    [_datePickerDos resignFirstResponder];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)updateTextField:(id)sender
{
    UIDatePicker *picker = (UIDatePicker*)self.datePickerUno.inputView;
    self.datePickerUno.text = [self formatDate:picker.date];
   
    self.dateUno = picker.date;
    
    NSLog(@"dateUno = %@", self.dateUno);
}

-(void)updateTextFieldDos:(id)sender
{
    UIDatePicker *pickerDos = (UIDatePicker*)self.datePickerDos.inputView;
    self.datePickerDos.text = [self formatDate:pickerDos.date];
    
    self.dateDos = pickerDos.date;
    NSLog(@"dateDos = %@", _dateDos);
}

- (NSString *)formatDate:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateFormat:@"MM'-'dd'-'yyyy"];
    NSString *formattedDate = [dateFormatter stringFromDate:date];

    return formattedDate;
}

- (IBAction)update:(id)sender {
    
    UIButton *button = nil;
    if([sender isKindOfClass:[UIButton class]]) {
        button = (UIButton *)sender;
    }
    
    
    button.backgroundColor = [UIColor purpleColor];
    
   // total_query is the total number of users signed up
    // today_query is the total # of users signed up today
    // seen_today_query is the # of users who opened the app today
    
    PFQuery *total_query = [PFUser query];
    PFQuery *today_query = [PFUser query];
    PFQuery *seen_today_query = [PFUser query];
    PFQuery *tags_today = [PFQuery queryWithClassName:@"NewMarcoPolo"];
    
    // now = todays date
//    
//    NSDate *now = [NSDate date];
////    
//    // an integer representing one 24 hr period in seconds
//    
//    NSTimeInterval secondsToday =  24 * 60 * 60;
//        

    
   // NSDate *yesterday = [NSDate dateWithTimeInterval:-secondsToday sinceDate:now];
    
    
        [today_query whereKey:@"createdAt" greaterThan:self.dateUno];
        
        [seen_today_query whereKey:@"seenAt" greaterThan:self.dateUno];
    
        [tags_today whereKey:@"createdAt" greaterThan:self.dateUno];
    
    
    
        [today_query whereKey:@"createdAt" lessThan:self.dateDos];
    
        [seen_today_query whereKey:@"seenAt" lessThan:self.dateDos];
    
        [tags_today whereKey:@"createdAt" lessThan:self.dateDos];
    

    // returns total # of user signups
    
    [total_query countObjectsInBackgroundWithBlock:^(int count, NSError *error) {
        if (!error) {
            self.userContLabel.text = [NSString stringWithFormat:@"%d", count];
        
        } else {
            NSLog(@"FAILED BRO");
        }
        button.backgroundColor = [UIColor clearColor];
        
    }];
    
    // returns the number of todays user signups
    
    [today_query countObjectsInBackgroundWithBlock:^(int count, NSError *error) {
        if (!error) {
            self.todays_signups.text = [NSString stringWithFormat:@"%d", count];
        } else {
            NSLog(@"FAILED BRO");
        }
        button.backgroundColor = [UIColor clearColor];
        }];

    [seen_today_query countObjectsInBackgroundWithBlock:^(int count, NSError *error) {
        if (!error) {
            self.todays_users.text = [NSString stringWithFormat:@"%d", count];
        //    NSLog(@"Today %d users used Tag", count);
        } else {
            NSLog(@"FAILED BRO");
        }
    }];
    
    [tags_today countObjectsInBackgroundWithBlock:^(int count, NSError *error) {
        if (!error) {
            self.todays_tags.text = [NSString stringWithFormat:@"%d", count];
        //    NSLog(@"%d new tags today", count);
        } else {
            NSLog(@"FAILED BRO");
        }
    }];

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    MPATableTopUsers *topUsersVc = (MPATableTopUsers *)segue.destinationViewController;
    topUsersVc.dateUno = self.dateUno;
    topUsersVc.dateDos = self.dateDos;

    
}



@end