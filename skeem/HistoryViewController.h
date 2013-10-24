//
//  HistoryViewController.h
//  skeem
//
//  Created by Patrick Dunshee on 10/24/13.
//  Copyright (c) 2013 Patrick Dunshee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HistoryViewController : UITableViewController <NSFetchedResultsControllerDelegate>{
    NSFetchedResultsController *fetchedResultsController;
    NSManagedObjectContext *managedObjectContext;
}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *backButton;

@property (nonatomic, strong) NSArray *historyArray;

@end
