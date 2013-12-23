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
- (void) skeemCall:(CLLocation*) userLoc{
    /*This section is deprecated, left for reference
    [locationManager startUpdatingLocation];
    //get current coordinates
    locationManager = [[CLLocationManager alloc] init];
    [locationManager setDelegate:self];
    //NOTE: this next line might make the locMan run too much
    [locationManager setDistanceFilter:kCLDistanceFilterNone];
    [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    
    // Build the url string to send to Google. NOTE: The kGOOGLE_API_KEY is a constant that should contain your own API key that you obtain from Google. See this link for more info: trophy room:32.797992, -96.801167
        // https://developers.google.com/maps/documentation/places/#Authentication
    NSString *url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/search/json?location=%f,%f&types=%@&sensor=true&rankby=%@&key=%@", locationManager.location.coordinate.latitude, locationManager.location.coordinate.longitude, @"bar", @"distance", kGOOGLE_API_KEY];
     */
    NSString *url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/search/json?location=%f,%f&types=%@&sensor=true&rankby=%@&key=%@", userLoc.coordinate.latitude, userLoc.coordinate.longitude, @"bar", @"distance", kGOOGLE_API_KEY];
    
    NSLog(@"Lat: %f, Long: %f", userLoc.coordinate.latitude, userLoc.coordinate.longitude);
    
    //Formulate the string as a URL object.
    NSURL *googleRequestURL=[NSURL URLWithString:url];
    
    // Retrieve the results of the URL.
    dispatch_async(kBgQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL: googleRequestURL];
        [self performSelectorOnMainThread:@selector(fetchedData:) withObject:[NSArray arrayWithObjects:data, userLoc, nil] waitUntilDone:YES];
    });
}

//this function is called when the Places request returns its results
-(void)fetchedData:(NSArray *)responseDataAndLoc {
    //separate array into location and NSData
    NSData* responseData = [responseDataAndLoc objectAtIndex:0];
    CLLocation* currentPlace = [responseDataAndLoc objectAtIndex:1];
    
    //parse out the json data
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData
                          
                          options:kNilOptions
                          error:&error];
    
    //The results from Google will be an array obtained from the NSDictionary object with the key "results".
    NSArray* places = [json objectForKey:@"results"];
    
    //check if any matches were returned
    if([places count] != 0){
    //get the latitude/longitude, id, and name of the place
    NSString *placeLatString = [[[[places objectAtIndex:0] objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lat"];
    double placeLat = [placeLatString doubleValue];
    NSString *placeLngString = [[[[places objectAtIndex:0] objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lng"];
    double placeLng = [placeLngString doubleValue];
    NSString *placeId = [[places objectAtIndex:0] objectForKey:@"id"];
    NSString *placeName = [[places objectAtIndex:0] objectForKey:@"name"];
    NSString *placeAddress = [[places objectAtIndex:0] objectForKey:@"vicinity"];
    
    //get coordinates of the place that was found and the user's current location
    CLLocation *placeLoc = [[CLLocation alloc] initWithLatitude:placeLat longitude:placeLng];
    
    //get distance to place from current location
    CLLocationDistance currToPlace = [currentPlace distanceFromLocation:placeLoc];
    
    //if the place is too far away (>40 meters) for the user to viably be there
    if(currToPlace > 100){
        //clear any previous Parse entries necessary (Person unless last entry, then Person and Place)
        NSLog(@"%@: %f", @"It's greater than 100 meters away", currToPlace);
        [self removeParseEntry];
    }
    else{
        //save the data locally first in core data
        //save the new post to Core Data first
        NSManagedObjectContext *context = [self managedObjectContext];
        
        
        NSManagedObject *placeEntry = [NSEntityDescription
                                       insertNewObjectForEntityForName:@"Place"
                                       inManagedObjectContext:context];
        [placeEntry setValue:placeName forKey:@"placeName"];
        [placeEntry setValue:[NSDate date] forKey:@"time"];
        [placeEntry setValue:[NSNumber numberWithDouble:[placeLatString doubleValue]]  forKey:@"geoLat"];
        [placeEntry setValue:[NSNumber numberWithDouble:[placeLngString doubleValue]]  forKey:@"geoLng"];
        NSError *error;
        if (![context save:&error]) {
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
        //get entries to check if there are too many
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription
                                       entityForName:@"Place" inManagedObjectContext:context];
        [fetchRequest setEntity:entity];
        NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
        
        //check if there are too many entries, delete the oldest ones if so
        while([fetchedObjects count] >= 50){
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"Place" inManagedObjectContext:managedObjectContext];
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"time" ascending:YES]; // ascending YES = start with earliest date
            NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
            NSError *error;
            NSFetchRequest *request = [[NSFetchRequest alloc] init];
            [request setEntity:entity];
            [request setSortDescriptors:sortDescriptors];
            [request setFetchLimit:1];
            
            NSArray *fetchResults = [managedObjectContext executeFetchRequest:request error:&error];
            
            //check just to make sure no error, then actually delete
            if ([fetchResults count]>0)
                [managedObjectContext deleteObject:[fetchResults objectAtIndex:0]];
        }
        
        
        //first make it so currentUser is never nil (or it will crash)
        [PFUser enableAutomaticUser];
        
        //check if user is in the table already
        // Create a query
        PFQuery *postQuery = [PFQuery queryWithClassName:@"Place"];
        
        // Follow relationship
        [postQuery whereKey:@"personId" equalTo:[PFUser currentUser]];
        
        //NSArray to get results
        NSArray *userQueryResults;
        
        @try{
        //the actual query action
            userQueryResults = [postQuery findObjects];
        }
        @catch (NSException *e) {
            NSLog(@"%@", e);
        }
        
        //check if user is already in system
        if([userQueryResults count] == 0){
            //user is not already in system. create Place entry
            [self inputParseEntryId:placeId name:placeName lat:placeLatString lng:placeLngString address:placeAddress];
        }
        else{
            //PFObject of entry from query
            PFObject *placeEntry = [userQueryResults objectAtIndex:0];
            //user is already in system. check if they're at the same place
            if([placeId isEqualToString:[placeEntry objectForKey:@"id"]]){
                //the user is at the same place they already were. log it and done
                NSLog(@"Equal!");
            }
            else{
                //user has changed locations
                for(PFObject *placeEntry in userQueryResults){
                    //loop through and delete all table entries for that user
                    [placeEntry deleteEventually];
                }
                
                //create new entry
                [self inputParseEntryId:placeId name:placeName lat:placeLatString lng:placeLngString address:placeAddress];
            }
        }
        
    }
    }//end [places count] != 0
    else{
        //user is not close enough to any bar, clear Parse entries
        NSLog(@"No bar found in places request.");
        [self removeParseEntry];
    }
    
}

//function to create and save a Parse object
-(void)inputParseEntryId:(NSString*)placeId name:(NSString*)placeName lat:(NSString*)placeLatString lng:(NSString*)placeLngString address:(NSString *)placeAddress{
    //add bar to Place table
    // Create Post
    PFObject *newPost = [PFObject objectWithClassName:@"Place"];
    
    // Set text content
    [newPost setObject:placeId forKey:@"id"];
    [newPost setObject:placeName forKey:@"name"];
    [newPost setObject:placeAddress forKey:@"placeAddress"];
    PFGeoPoint *geoPoint = [PFGeoPoint geoPointWithLatitude:[placeLatString doubleValue] longitude:[placeLngString doubleValue]];
    [newPost setObject:geoPoint forKey:@"geoPoint"];
    
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
    [newPost setObject:[NSString stringWithFormat:@"%li", (long)age] forKey:@"personAge"];
    
    // Save the new post
    [newPost saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            // Dismiss the NewPostViewController and show the BlogTableViewController
            NSLog(@"%@", @"Parse object saved successfully.");
            
        }
        else
            NSLog(@"%@", [error localizedDescription]);
    }];
}

/*/this function is called every 2 minutes when skeem button is enabled DEPRECATED
- (void) startAfterInterval:(NSTimer*)timer {
    //enable then disable the location manager so the application is not killed in the background
    [locationManager startUpdatingLocation];
    [locationManager stopUpdatingLocation];
    
    //if this is the first call of the cycle, execute database actions here
    if(self.timerSave == 10){
        [self skeemCall];
    }
    
    self.timerSave--;
    
    if(self.timerSave <= 0)
        self.timerSave = 10;
    
}
 */

//this function deletes the user's Parse entry from the table
-(void)removeParseEntry{
    //need to remove entry from Parse table
    //first make it so currentUser is never nil (or it will crash)
    [PFUser enableAutomaticUser];
    
    //check if user is in the table already
    // Create a query
    PFQuery *postQuery = [PFQuery queryWithClassName:@"Place"];
    
    // Follow relationship
    [postQuery whereKey:@"personId" equalTo:[PFUser currentUser]];
    
    //NSArray to get results
    NSArray *userQueryResults;
    
    @try{
        //the actual query action
        userQueryResults = [postQuery findObjects];
    }
    @catch (NSException *e) {
        NSLog(@"%@", e);
    }
    
    //check if user is already in system
    if([userQueryResults count] > 0){
        //PFObject of entry from query
        for(PFObject *placeEntry in userQueryResults){
            //loop through and delete all table entries for that user
            [placeEntry deleteEventually];
        }
    }
}

@end
