//
//  ViewController.h
//  skeem
//
//  Created by Patrick Dunshee on 9/23/13.
//  Copyright (c) 2013 Patrick Dunshee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UIPickerViewDataSource,UIPickerViewDelegate>


@property (strong, nonatomic) IBOutlet UIDatePicker *dobUIDatePickerView;
@property (strong, nonatomic) IBOutlet UIPickerView *sexUIPickerView;
@property (strong, nonatomic) NSArray *sexArray;
@property (strong, nonatomic) IBOutlet UIButton *doneUIButton;


@end
