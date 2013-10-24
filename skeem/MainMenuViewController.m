//
//  MainMenuViewController.m
//  skeem
//
//  Created by Patrick Dunshee on 9/24/13.
//  Copyright (c) 2013 Patrick Dunshee. All rights reserved.
//

#import "MainMenuViewController.h"
#import "ViewController.h"
#import "NewUserNavViewController.h"
#import "HistoryViewController.h"
#import <Parse/Parse.h>


@interface MainMenuViewController ()

@end

@implementation MainMenuViewController

@synthesize fetchedResultsController, managedObjectContext;

//when the user hits the skeem button, to disable/enable skeem
- (IBAction)skeemButtonPressed:(id)sender {
    
    //if skeem is enabled (1) turn it off and vice versa
    if(self.skeemEnabled == 0)
        self.skeemEnabled = 1;
    else
        self.skeemEnabled = 0;
    
    UIApplication *app = [UIApplication sharedApplication];
    
    //if skeem is enabled, start repeating timed function to check location and update database
    if(self.skeemEnabled == 1){
        //set skeeminLabel to indicate you're skeemin
        self.skeeminLabel.text = @"You're skeemin!";
        bgTask = 0;
        bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
            //this block is called if the app is being killed in the background
            bgTask = UIBackgroundTaskInvalid;
            //if app is killed, remove Parse entry first
            [self performSelector:@selector(removeParseEntry)];
        }];
        self.skeemTimer = [NSTimer scheduledTimerWithTimeInterval:120.0 target:self selector:@selector(startAfterInterval:) userInfo:@"Test string" repeats:YES];
    }
    //if skeem is disabled, invalidate and set skeemTimer to nil
    else{
        //set skeeminLabel to indicate you're not skeemin
        self.skeeminLabel.text = @"You're not skeemin...";
        [self.skeemTimer invalidate];
        self.skeemTimer = nil;
        
        [self performSelector:@selector(removeParseEntry)];
        
        [app endBackgroundTask:bgTask];
    }
    
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"mainHistorySegue"])
    {
        // Pass the managedObjectContext so destination can use Core Data
        UINavigationController *navController = [segue destinationViewController];
        id object1 = (id) navController.topViewController;
        [object1 setManagedObjectContext:self.managedObjectContext];
    }
}

//this is the unwind segue from ViewController (New User screen)
-(IBAction)doneSegue: (UIStoryboardSegue *) segue{
    
}

//user pressed view history button
- (IBAction)viewHistoryButtonPressed:(id)sender {
    //perform segue to history view
    [self performSegueWithIdentifier:@"mainHistorySegue" sender:self];
}

//user pressed view map button
- (IBAction)viewMapButtonPressed:(id)sender {
    //segue to the map view
    [self performSegueWithIdentifier: @"mainMapSegue" sender: self];
}

//user pressed edit information button
- (IBAction)editInfoButtonPressed:(id)sender{
    //segue to the edit information view
    [self performSegueWithIdentifier: @"mainEditSegue" sender: self];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        //if skeemEnabled has not been initialized yet, initialize to zero
        if(!self.skeemEnabled){
            self.skeemEnabled = 0;
        }
        //if uninitialized, set timerSave to 10 (10*2min=20min)
        if(!self.timerSave){
            self.timerSave = 10;
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    //set skeem label to indicate skeem state
    if(self.skeemEnabled == 0)
        self.skeeminLabel.text = @"You're not skeemin...";
    else
        self.skeeminLabel.text = @"You're skeemin!";
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    //get saved user info (dob and sex)
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *userSex = [defaults objectForKey:@"userSex"];
    NSDate *userDOB = [defaults objectForKey:@"userDOB"];
    
    //check that both are instantiated. If not, go to new user screen
    if(!userSex || !userDOB){
        //not instantiated go to new user screen
        [self performSegueWithIdentifier:@"mainNewSegue" sender: self];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
