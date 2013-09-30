//
//  ViewController.m
//  skeem
//
//  Created by Patrick Dunshee on 9/23/13.
//  Copyright (c) 2013 Patrick Dunshee. All rights reserved.
//
//  This file is responsible for the new user window where they enter
//  date of birth and sex and they are both stored as NSUserDefaults

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

//run when "Done" button is hit, sets chosen values and exits back to main
-(IBAction)doneButtonClicked:(id) sender{
    //sets user defaults and saves them
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.userSex forKey:@"userSex"];
    [defaults setObject:self.userDOB forKey:@"userDOB"];
    [defaults synchronize];
    
    NSLog(@"%@", self.userSex);
    NSLog(@"%@", [self.userDOB description]);
    
    [self dismissViewControllerAnimated:TRUE completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    //set default values in case user does not change picker fields
    self.userSex = @"Male";
    self.userDOB = [self.dobUIDatePickerView date];
    
    self.sexArray = [[NSArray alloc] initWithObjects: @"Male", @"Female", nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent: (NSInteger)component{
    return 2;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [self.sexArray objectAtIndex: row];
}

//this method sets sex to local variable when it is selected
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.userSex = [self.sexArray objectAtIndex: row];
}

//this sets dob to local variable when date is changed
-(IBAction)selectDOB:(id) sender{
    self.userDOB = [self.dobUIDatePickerView date];
}

@end
