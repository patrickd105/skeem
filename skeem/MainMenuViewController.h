//
//  MainMenuViewController.h
//  skeem
//
//  Created by Patrick Dunshee on 9/24/13.
//  Copyright (c) 2013 Patrick Dunshee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainMenuViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIButton *viewMapButton;
@property (strong, nonatomic) IBOutlet UIButton *editInfoButton;

-(IBAction)doneSegue: (UIStoryboardSegue *) segue;

@end
