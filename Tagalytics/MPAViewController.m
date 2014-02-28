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
@property (weak, nonatomic) IBOutlet UILabel *todays_signups;
@property (weak, nonatomic) IBOutlet UILabel *todays_tags;
@property (weak, nonatomic) IBOutlet UILabel *todays_users;
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
    
   // total_query is the total number of users signed up
    // today_query is the total # of users signed up today
    // seen_today_query is the # of users who opened the app today
    
    PFQuery *total_query = [PFUser query];
    PFQuery *today_query = [PFUser query];
    PFQuery *seen_today_query = [PFUser query];
    PFQuery *tags_today = [PFQuery queryWithClassName:@"NewMarcoPolo"];
    
    // now = todays date
    
    NSDate *now = [NSDate date];
    
    // an integer representing one 24 hr period in seconds
    
    NSTimeInterval secondsToday =  24 * 60 * 60;
        
    // yesterday = immediate time - 24hrs in seconds
    
    NSDate *yesterday = [NSDate dateWithTimeInterval:-secondsToday sinceDate:now];
    
    // print to console for programmer reference
    
   // NSLog(@"The value held in yesterday is %@", yesterday);
    
    // filter for today_query
    
    [today_query whereKey:@"createdAt" greaterThan:yesterday];
    
    [seen_today_query whereKey:@"seenAt" greaterThan:yesterday];
    
    [tags_today whereKey:@"createdAt" greaterThan:yesterday];
    
    
    
    // returns total # of user signups
    
    [total_query countObjectsInBackgroundWithBlock:^(int count, NSError *error) {
        if (!error) {
            self.userContLabel.text = [NSString stringWithFormat:@"%d", count];
         //   NSLog(@"There are currently %@ users on Tag.", self.userContLabel.text);
        } else {
            NSLog(@"FAILED BRO");
        }
        button.backgroundColor = [UIColor clearColor];
        
    }];
    
    // returns the number of todays user signups
    
    [today_query countObjectsInBackgroundWithBlock:^(int count, NSError *error) {
        if (!error) {
            self.todays_signups.text = [NSString stringWithFormat:@"%d", count];
          //  NSLog(@"Today we had %d signups", count);
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
    
    [self getTopUsers];

}

- (void)getTopUsers {
    
    NSLog(@"Starting search for top users...");
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        PFQuery *userCountQuery = [PFUser query];
        NSError *userCountError = nil;
        NSInteger userCount = [userCountQuery countObjects:&userCountError];
        
        NSLog(@"This is the value for userCount %ld", (long)userCount);
        
        if(userCountError != nil) {
            NSLog(@"Error trying to count %@", [userCountError.userInfo objectForKey:@"error"]);
            return;
        }
        
        NSMutableArray *allUsers = [NSMutableArray array];
        
        for(int i = 0; i < (userCount/1000 + 1); i++) {
            
            PFQuery *userQuery = [PFUser query];
            [userQuery setLimit:1000];
            [userQuery setSkip:(i * 1000)];
            
            NSError *userQueryError = nil;
            NSArray *userObjects = [userQuery findObjects:&userQueryError];
            
            if(userQueryError) {
                NSLog(@"Error trying to get users %@", [userQueryError.userInfo objectForKey:@"error"]);
                return;
            }
            
            [allUsers addObjectsFromArray:userObjects];
            
        }
        
        NSLog(@"All users have been fetched");
        
        
        NSMutableDictionary *best_users = [NSMutableDictionary dictionary];
        
    
        
        // iterates over each user in all users
        
        for(PFUser *user in allUsers) {
            
            PFQuery *tagQuery = [PFQuery queryWithClassName:@"NewMarcoPolo"];
            [tagQuery whereKey:@"sendingUser" equalTo:user];
            [tagQuery setLimit:1000];
            NSError *tagCountError = nil;
            NSArray *tagObjects = [tagQuery findObjects:&tagCountError];
            
            
            if(tagCountError) {
                NSLog(@"Error trying to get users %@", [tagCountError.userInfo objectForKey:@"error"]);
                return;
            }
            
            [best_users setObject:[NSNumber numberWithInteger:tagObjects.count] forKey:user.objectId];
            
           //NSLog(@"Number of tags for %@: %ld", [user objectForKey:@"fullName"], (long)tagObjects.count);
        
        }
        
        NSArray *sortedKeys = [best_users keysSortedByValueUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [obj2 compare:obj1];
        }];
                               
        NSLog(@"%@", sortedKeys);
        
        for(int i = 0; i < 10; i++) {
            
            NSString *key = sortedKeys[i];
            for(PFUser *user in allUsers) {
                if([user.objectId isEqualToString:key]) {
                    NSLog(@"User #%d: %@", i+1, [user objectForKey:@"fullName"]);
                }
            }
            
        }
               
        NSLog(@"Done with top user tracking!");
        
    });
    
}

@end