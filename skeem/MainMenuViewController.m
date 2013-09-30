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
    
    PFObject *testObject = [PFObject objectWithClassName:@"TestObject"];
    [testObject setObject:@"bar" forKey:@"foo"];
    [testObject save];
    
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
