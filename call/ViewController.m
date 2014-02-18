//
//  ViewController.m
//  call
//
//  Created by Lokesh on 2/17/14.
//  Copyright (c) 2014 Mac User. All rights reserved.
//

#import "ViewController.h"
#import <Accounts/Accounts.h>
#import <Twitter/Twitter.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad


{
    [super viewDidLoad];
    [self getTwitterAccounts];
	// Do any additional setup after loading the view, typically from a nib.
}


-(void)getTwitterAccounts {
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    // Create an account type that ensures Twitter accounts are retrieved.
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    // let's request access and fetch the accounts
    [accountStore requestAccessToAccountsWithType:accountType
                            withCompletionHandler:^(BOOL granted, NSError *error) {
                                // check that the user granted us access and there were no errors (such as no accounts added on the users device)
                                if (granted && !error) {
                                    NSArray *accountsArray = [accountStore accountsWithAccountType:accountType];
                                    if ([accountsArray count] > 1) {
                                        // a user may have one or more accounts added to their device
                                        // you need to either show a prompt or a separate view to have a user select the account(s) you need to get the followers and friends for
                                    } else {
                                        if ([accountsArray count] > 0) {
                                         [self getTwitterFriendsForAccount:[accountsArray objectAtIndex:0]];
                                        }
                                        else{
                                            UIAlertView *error = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Please Login" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                                            [error show];
                                        ]
                                            
                                        }
                                        
                                    }
                                } else {
                                    // handle error (show alert with information that the user has not granted your app access, etc.)
                                }
                            }];
}

-(void)getTwitterFriendsForAccount:(ACAccount*)account {
    // In this case I am creating a dictionary for the account
    // Add the account screen name
    NSMutableDictionary *accountDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:account.username, @"screen_name", nil];
    // Add the user id (I needed it in my case, but it's not necessary for doing the requests)
    [accountDictionary setObject:[[[account dictionaryWithValuesForKeys:[NSArray arrayWithObject:@"properties"]] objectForKey:@"properties"] objectForKey:@"user_id"] forKey:@"user_id"];
    // Setup the URL, as you can see it's just Twitter's own API url scheme. In this case we want to receive it in JSON
    NSURL *followingURL = [NSURL URLWithString:@"https://api.twitter.com/1.1/followers/list.json"];
    // Pass in the parameters (basically '.ids.json?screen_name=[screen_name]')
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:account.username, @"screen_name", nil];
    // Setup the request
    TWRequest *twitterRequest = [[TWRequest alloc] initWithURL:followingURL
                                                    parameters:parameters
                                                 requestMethod:TWRequestMethodGET];
    // This is important! Set the account for the request so we can do an authenticated request. Without this you cannot get the followers for private accounts and Twitter may also return an error if you're doing too many requests
    [twitterRequest setAccount:account];
    // Perform the request for Twitter friends
    [twitterRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if (error) {
            // deal with any errors - keep in mind, though you may receive a valid response that contains an error, so you may want to look at the response and ensure no 'error:' key is present in the dictionary
        }
        NSError *jsonError = nil;
        // Convert the response into a dictionary
        NSDictionary *twitterFriends = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONWritingPrettyPrinted error:&jsonError];
        // Grab the Ids that Twitter returned and add them to the dictionary we created earlier
        
        
        
        NSMutableArray *getuser = [twitterFriends objectForKey:@"users"];
         NSLog(@"users:%@", [twitterFriends objectForKey:@"users"]);
        for (NSDictionary *getuserie in getuser) {
          
            [accountDictionary setObject:[getuserie objectForKey:@"screen_name"] forKey:@"id_name"];
            
            [accountDictionary setObject:[getuserie objectForKey:@"id"] forKey:@"id_str"];
            NSLog(@"%@", [getuserie objectForKey:@"screen_name"] );

        }
        
        // [accountDictionary setObject:[twitterFriends objectForKey:@"id"] forKey:@"id_str"];
        NSLog(@"%@", accountDictionary);

        
          }];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
