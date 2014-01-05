//
//  PlacesListViewController.h
//  skeem
//
//  Created by Patrick Dunshee on 1/5/14.
//  Copyright (c) 2014 Patrick Dunshee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlacesListViewController : UITableViewController <NSFetchedResultsControllerDelegate>
{
    NSMutableArray *placesList;
}

@property NSMutableArray *placesList;

@end
