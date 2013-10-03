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
#import <Parse/Parse.h>


@interface MainMenuViewController ()

@end

@implementation MainMenuViewController



//when the user hits the skeem button, to disable/enable skeem
- (IBAction)skeemButtonPressed:(id)sender {
    
    //if skeem is enabled (1) turn it off and vice versa
    if(self.skeemEnabled == 0)
        self.skeemEnabled = 1;
    else
        self.skeemEnabled = 0;
    
    //if skeem is enabled, start repeating timed function to check location and update database
    if(self.skeemEnabled == 1){
        self.skeemTimer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(startAfterInterval:) userInfo:@"Test string" repeats:YES];
    }
    //if skeem is disabled, invalidate and set skeemTimer to nil
    else{
        [self.skeemTimer invalidate];
        self.skeemTimer = nil;
    }
    
    
}

//this is the unwind segue from ViewController (New User screen)
-(IBAction)doneSegue: (UIStoryboardSegue *) segue{
    
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
        //if uninitialized, set timerSave to 1200.0 (20 minutes)
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
