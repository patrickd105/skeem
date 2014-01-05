//
//  MapViewController.h
//  skeem
//
//  Created by Patrick Dunshee on 9/24/13.
//  Copyright (c) 2013 Patrick Dunshee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "MapPoint.h"
#import <Parse/Parse.h>

@interface MapViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate>
{
    CLLocationManager *locationManager;
    CLLocationCoordinate2D currentCentre;
    int currenDist;
    BOOL firstLaunch;
    NSMutableArray *placesList;
}

@property (strong, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *refreshButton;

@property (nonatomic, retain) NSMutableArray *placesList;

@end
