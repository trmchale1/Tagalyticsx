//
//  MPATableTopUsers.m
//  Tagalytics
//
//  Created by Tim McHale on 3/3/14.
//  Copyright (c) 2014 Tim McHale. All rights reserved.
//

#import "MPATableTopUsers.h"
#import <Parse/Parse.h>
#import "MPAViewController.h"



@interface MPATableTopUsers ()
@end
NSArray *final_list_global;

@implementation MPATableTopUsers

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
   
        }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self getTopUsers];
    
    NSLog(@"dateUno = %@", _dateUno);

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
   
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
   return [self.final_list_global count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
 
    static NSString *CellIdentifier =@"Cell";
    UITableViewCell *cell = [tableView
                             dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.textLabel.text=[self.final_list_global objectAtIndex:indexPath.row];
    
    return cell;

}

- (void)getTopUsers {
    
    NSLog(@"Starting search for top users...");
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        PFQuery *userCountQuery = [PFUser query];
        NSError *userCountError = nil;
        NSInteger userCount = [userCountQuery countObjects:&userCountError];
        
        // userCount is an integer that holds the number of users
        
        if(userCountError != nil) {
            NSLog(@"Error trying to count %@", [userCountError.userInfo objectForKey:@"error"]);
            return;
        }
        
        // allUsers is iterated over by the loop, there probably isn't 1000
        // users, so lets just say that that all the users are in all users
        // held as objects (PFUSER, email, facebookID, fullname, phonenumber, pin,
        // profile image, seenAt, username)
        
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
        
        
        NSMutableArray *final_list = [[NSMutableArray array] init];
        
        // iterates over each user in allUsers
        
        // The key value in this loop is array tagObjects
        
        // tagObjects is equal to a parse query looking for sendingUser
        // these are counted, and held in dictionary best_users withKey being user
        for(PFUser *user in allUsers) {
            
            PFQuery *tagQuery = [PFQuery queryWithClassName:@"NewMarcoPolo"];
            [tagQuery whereKey:@"sendingUser" equalTo:user];
//            [tagQuery whereKey:@"createdAt" equalTo:@"%@", dateUno];
            [tagQuery setLimit:1000];
            NSError *tagCountError = nil;
            NSArray *tagObjects = [tagQuery findObjects:&tagCountError];
            
            if(tagCountError) {
                NSLog(@"Error trying to get users %@", [tagCountError.userInfo objectForKey:@"error"]);
                return;
            }
            
            [best_users setObject:[NSNumber numberWithInteger:tagObjects.count] forKey:user.objectId];
        }
        
        NSArray *sortedKeys = [best_users keysSortedByValueUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [obj2 compare:obj1];
        }];
        
        // Array sortedKeys sort the dictionary best_users
                
        for(int i = 0; i < 10; i++) {
            
            NSString *key = sortedKeys[i];
            for(PFUser *user in allUsers) {
                if([user.objectId isEqualToString:key]) {
                    
                    [final_list addObject:[user objectForKey:@"fullName"] ];
                    
                }
            }
            
        }
        
        self.final_list_global = final_list;
        [self.tableView reloadData];
        NSLog(@"Done with top user tracking!");
       
    });
    
}
@end