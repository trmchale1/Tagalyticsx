//
//  MPATableTopUsers.m
//  Tagalytics
//
//  Created by Tim McHale on 3/3/14.
//  Copyright (c) 2014 Tim McHale. All rights reserved.
//

#import "MPATableTopUsers.h"
#import <Parse/Parse.h>
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
        
        
        NSMutableArray *final_list = [[NSMutableArray array] init];
        
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
        
      //  NSLog(@"%@", sortedKeys);
        
        for(int i = 0; i < 10; i++) {
            
            NSString *key = sortedKeys[i];
            for(PFUser *user in allUsers) {
                if([user.objectId isEqualToString:key]) {
                    
                    
                    // Final print out statement
                    
                  // NSLog(@"User #%d: %@", i+1, [user objectForKey:@"fullName"]);
                    [final_list addObject:[user objectForKey:@"fullName"] ];
                    
                    
                    
                    NSLog(@"Hope this works %@", final_list);
                    
                }
            }
            
        }
        
        self.final_list_global = final_list;
        [self.tableView reloadData];
        NSLog(@"Done with top user tracking!");
       
    });
    
}
@end