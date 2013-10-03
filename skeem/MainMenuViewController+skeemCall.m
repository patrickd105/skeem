//
//  MainMenuViewController+skeemCall.m
//  skeem
//
//  Created by Patrick Dunshee on 9/30/13.
//  Copyright (c) 2013 Patrick Dunshee. All rights reserved.
//

#import "MainMenuViewController+skeemCall.h"

@implementation MainMenuViewController (skeemCall)

//the actual database modification function
- (void) skeemCall{
    //get current coordinates
    locationManager = [[CLLocationManager alloc] init];
    [locationManager setDelegate:self];
    //NOTE: this next line might make the locMan run too much
    [locationManager setDistanceFilter:kCLDistanceFilterNone];
    [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    
    // Build the url string to send to Google. NOTE: The kGOOGLE_API_KEY is a constant that should contain your own API key that you obtain from Google. See this link for more info:
        // https://developers.google.com/maps/documentation/places/#Authentication
    NSString *url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/search/json?location=%f,%f&types=%@&sensor=true&rankby=%@&key=%@", 32.798016, -96.80115, @"bar", @"distance", kGOOGLE_API_KEY];
    
    //Formulate the string as a URL object.
    NSURL *googleRequestURL=[NSURL URLWithString:url];
    
    // Retrieve the results of the URL.
    dispatch_async(kBgQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL: googleRequestURL];
        [self performSelectorOnMainThread:@selector(fetchedData:) withObject:data waitUntilDone:YES];
    });
    
    //get bar closest to those coordinates
    
    //check Parse to see if that bar is in there
    
    //if bar is in Parse, check if user is already in that bar
    
    //if user is not associated with that bar, delete old Person entry
    
    //check if bar has any people
    
    //if bar has no people, delete Place entry
    
    //if bar is in Parse, insert new Person entry
    
    //if bar is not in Parse, create new Place entry then new Person entry
}

//this function is called when the Places request returns its results
-(void)fetchedData:(NSData *)responseData {
    //parse out the json data
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData
                          
                          options:kNilOptions
                          error:&error];
    
    //The results from Google will be an array obtained from the NSDictionary object with the key "results".
    NSArray* places = [json objectForKey:@"results"];
    
    //get the latitude/longitude, id, and name of the place
    NSString *placeLatString = [[[[places objectAtIndex:0] objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lat"];
    double placeLat = [placeLatString doubleValue];
    NSString *placeLngString = [[[[places objectAtIndex:0] objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lng"];
    double placeLng = [placeLngString doubleValue];
    NSString *placeId = [[places objectAtIndex:0] objectForKey:@"id"];
    NSString *placeName = [[places objectAtIndex:0] objectForKey:@"name"];
    
    //get coordinates of the place that was found and the user's current location
    CLLocation *placeLoc = [[CLLocation alloc] initWithLatitude:placeLat longitude:placeLng];
    CLLocation *currentPlace = [[CLLocation alloc] initWithLatitude:32.798016 longitude:-96.80115];
    
    //get distance to place from current location
    CLLocationDistance currToPlace = [currentPlace distanceFromLocation:placeLoc];
    
    //if the place is too far away (>40 meters) for the user to viably be there
    if(currToPlace > 50){
        //clear any previous Parse entries necessary (Person unless last entry, then Person and Place)
        NSLog(@"%@: %f", @"It's greater than 50 meters away", currToPlace);
    }
    else{
        //first make it so currentUser is never nil (or it will crash)
        [PFUser enableAutomaticUser];
        
        //check if user is in the table already
        // Create a query
        PFQuery *postQuery = [PFQuery queryWithClassName:@"Place"];
        
        // Follow relationship
        [postQuery whereKey:@"personId" equalTo:[PFUser currentUser]];
        
        //NSArray to get results
        NSArray *userQueryResults;
        
        //the actual query
        userQueryResults = [postQuery findObjects];
        
        NSLog(@"%@", [userQueryResults description]);
        
        //add bar to Place table
        // Create Post
        PFObject *newPost = [PFObject objectWithClassName:@"Place"];
        
        // Set text content
        [newPost setObject:placeId forKey:@"id"];
        [newPost setObject:placeName forKey:@"name"];
        [newPost setObject:placeLatString forKey:@"geoLat"];
        [newPost setObject:placeLngString forKey:@"getLng"];
        
        
        // Create relationship
        [newPost setObject:[PFUser currentUser] forKey:@"personId"];
        //get then input user sex
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [newPost setObject:[defaults objectForKey:@"userSex"] forKey:@"personSex"];
        //get then input user age
        NSDate *userDOB = [defaults objectForKey:@"userDOB"];
        NSDate* now = [NSDate date];
        NSDateComponents* ageComponents = [[NSCalendar currentCalendar]
                                           components:NSYearCalendarUnit
                                           fromDate:userDOB
                                           toDate:now
                                           options:0];
        NSInteger age = [ageComponents year];
        [newPost setObject:[NSString stringWithFormat:@"%i", age] forKey:@"personDOB"];
        
        // Save the new post
        [newPost saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                // Dismiss the NewPostViewController and show the BlogTableViewController
                NSLog(@"%@", @"Success! Now go check.");
            }
            else
                NSLog(@"%@", [error localizedDescription]);
        }];
    }
    
}

//this function is called every 2 minutes when skeem button is enabled
- (void) startAfterInterval:(NSTimer*)timer {
    
    //if this is the first call of the cycle, execute database actions here
    if(self.timerSave == 10){
        [self skeemCall];
    }
    
    self.timerSave--;
    
    if(self.timerSave <= 0)
        self.timerSave = 10;
    
}

@end
