//
//  MainMenuViewController.h
//  skeem
//
//  Created by Patrick Dunshee on 9/24/13.
//  Copyright (c) 2013 Patrick Dunshee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <Parse/Parse.h>

#define kGOOGLE_API_KEY @"AIzaSyBSHGWEOM12TkRZ9Nd4MMvqoWwqZB3vhww"
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)


@interface MainMenuViewController : UIViewController <CLLocationManagerDelegate, NSFetchedResultsControllerDelegate>

{
    CLLocationManager *locationManager;
    __block UIBackgroundTaskIdentifier bgTask;
    
    NSFetchedResultsController *fetchedResultsController;
    NSManagedObjectContext *managedObjectContext;
}

@property (strong, nonatomic) IBOutlet UIButton *viewMapButton;
@property (strong, nonatomic) IBOutlet UIButton *editInfoButton;
@property (strong, nonatomic) IBOutlet UIButton *skeemButton;
@property (strong, nonatomic) IBOutlet UILabel *skeeminLabel;

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;


@property NSInteger skeemEnabled;
@property NSInteger timerSave;
@property NSTimer *skeemTimer;

-(IBAction)doneSegue: (UIStoryboardSegue *) segue;

@end
