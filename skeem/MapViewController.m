//
//  MapViewController.m
//  skeem
//
//  Created by Patrick Dunshee on 9/24/13.
//  Copyright (c) 2013 Patrick Dunshee. All rights reserved.
//

#import "MapViewController.h"
#import <Parse/Parse.h>

@interface MapViewController ()

@end

@implementation MapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

//this happens when "Back" button is pressed, takes user back to main menu
- (IBAction)backButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:TRUE completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //Make this controller the delegate for the map view.
    self.mapView.delegate = self;
    
    // Ensure that you can view your own location in the map view.
    [self.mapView setShowsUserLocation:YES];
    
    //Instantiate a location object.
    locationManager = [[CLLocationManager alloc] init];
    
    //Make this controller the delegate for the location manager.
    [locationManager setDelegate:self];
    
    //Set some parameters for the location object.
    [locationManager setDistanceFilter:kCLDistanceFilterNone];
    [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    
    //set firstLaunch to YES, indicating this is the first time the map is being opened
    firstLaunch = YES;
    
    //the initial call to plot the points
    [self startPlotting];
}

//this method calls to the Parse database and starts making the points
-(void)startPlotting{
    //create the main query we'll be using
    PFQuery *mainMapQuery = [PFQuery queryWithClassName:@"Place"];
    
    //create PFGeoPoint with user's current MAP location
    PFGeoPoint *mapLocation = [PFGeoPoint geoPointWithLatitude:currentCentre.latitude longitude:currentCentre.longitude];
    //PFGeoPoint *mapLocation = [PFGeoPoint geoPointWithLatitude:32.797992 longitude:-96.801167];
    
    //now specify the query based on map position
    [mainMapQuery whereKey:@"geoPoint"
     nearGeoPoint:mapLocation
          withinKilometers:currenDist];
    
    //run the query, send to plotPositions
    [mainMapQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if(error)
        {
            NSLog(@"Error in geo query: %@", error);
        }
        else
        {
            NSLog(@"%@", objects);
            [self plotPositions:objects];
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//this method is called every time a new annotation is added
- (void)mapView:(MKMapView *)mv didAddAnnotationViews:(NSArray *)views {
    //Zoom back to the user location after adding a new set of annotations.
    //Get the center point of the visible map.
    CLLocationCoordinate2D centre = [mv centerCoordinate];
    MKCoordinateRegion region;
    //If this is the first launch of the app, then set the center point of the map to the user's location.
    if (firstLaunch) {
        region = MKCoordinateRegionMakeWithDistance(locationManager.location.coordinate,1000,1000);
        firstLaunch=NO;
    }else {
        //Set the center point to the visible region of the map and change the radius to match the search radius passed to the Google query string.
        region = MKCoordinateRegionMakeWithDistance(centre,currenDist,currenDist);
    }
    //Set the visible region of the map.
    [mv setRegion:region animated:YES];
}

//this method is called when the user changes the map position
-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    //Get the east and west points on the map so you can calculate the distance (zoom level) of the current map view.
    MKMapRect mRect = self.mapView.visibleMapRect;
    MKMapPoint eastMapPoint = MKMapPointMake(MKMapRectGetMinX(mRect), MKMapRectGetMidY(mRect));
    MKMapPoint westMapPoint = MKMapPointMake(MKMapRectGetMaxX(mRect), MKMapRectGetMidY(mRect));
    
    //Set your current distance instance variable.
    currenDist = MKMetersBetweenMapPoints(eastMapPoint, westMapPoint);
    
    //Set your current center point on the map instance variable.
    currentCentre = self.mapView.centerCoordinate;
    
}

//this method receives an array of Parse points and creates the corresponding map points
-(void)plotPositions:(NSArray *)data {
    // 1 - Remove any existing custom annotations but not the user location blue dot.
    for (id<MKAnnotation> annotation in self.mapView.annotations) {
        if ([annotation isKindOfClass:[MapPoint class]]) {
            [self.mapView removeAnnotation:annotation];
        }
    }
    
    //array to hold all place id's, then array for average ages, then for ratio guys/girls
    NSMutableArray *placeIds = [[NSMutableArray alloc] init];
    NSMutableArray *averageAges = [[NSMutableArray alloc] init];
    NSMutableArray *ratios = [[NSMutableArray alloc] init];
    NSMutableArray *geoPoints = [[NSMutableArray alloc] init];
    NSMutableArray *names = [[NSMutableArray alloc] init];
    NSMutableArray *addresses = [[NSMutableArray alloc] init];
    //loop through Parse places, fill arrays that were just allocated
    for(PFObject *newPFObject in data){
        NSString *placeId = [newPFObject objectForKey:@"id"];
        //check if placeIds array already contains the id
        if(![placeIds containsObject:placeId]){
            //placeIds does not contain id, add it
            [placeIds addObject:placeId];
            //add geopoint to array
            [geoPoints addObject:[newPFObject objectForKey:@"geoPoint"]];
            //add name to array
            [names addObject:[newPFObject objectForKey:@"name"]];
            //add address to array
            [addresses addObject:[newPFObject objectForKey:@"placeAddress"]];
            //create mutable array to hold ages, put in averageAges
            NSMutableArray *ages = [[NSMutableArray alloc] init];
            [ages addObject:[newPFObject objectForKey:@"personAge"]];
            [averageAges addObject:ages];
            //create mutable array to hold sexes, put in ratios
            NSMutableArray *sexes = [[NSMutableArray alloc] init];
            [sexes addObject:[newPFObject objectForKey:@"personSex"]];
            [ratios addObject:sexes];
        }
        else{
            //placeId is already in placeIds, get index of that placeId
            NSUInteger indexPlace = [placeIds indexOfObject:placeId];
            [[averageAges objectAtIndex:indexPlace] addObject:[newPFObject objectForKey:@"personAge"]];
            [[ratios objectAtIndex:indexPlace] addObject:[newPFObject objectForKey:@"personSex"]];
        }
    }//end loop through places array
    
    //loop through the placeIds array to actually make the markers
    for(int i = 0; i<[placeIds count]; i++){
        //set name and address
        NSString *name=[names objectAtIndex:i];
        NSString *address=[addresses objectAtIndex:i];
        //set geopoint
        CLLocationCoordinate2D placeCoord;
        placeCoord.latitude = [[geoPoints objectAtIndex:i] latitude];
        placeCoord.longitude = [[geoPoints objectAtIndex:i] longitude];
        
        //calculate ratio
        double percentGuys;
        double guys = 0;
        double girls = 0;
        for(int j = 0; j < [[ratios objectAtIndex:i] count]; j++){
            if ([[[ratios objectAtIndex:i] objectAtIndex:j] isEqualToString:@"Male"]) {
                guys++;
            }
            else{
                girls++;
            }
        }
        //total people
        double totPeople = guys + girls;
        
        //if totPeople is 0, then don't plot anything. this is a just in case thing so we don't divide by 0 and break the universe
        if(totPeople != 0){
            percentGuys = guys/totPeople;
        
        
            //calculate average age
            NSNumber *averageAge;
            NSNumber *totalAge = [[NSNumber alloc] initWithDouble:0];
            for(int j = 0; j < [[averageAges objectAtIndex:i] count]; j++){
                double tempNum = [totalAge doubleValue];
                tempNum = tempNum + [[[averageAges objectAtIndex:i] objectAtIndex:j] doubleValue];
                totalAge = [NSNumber numberWithDouble:tempNum];
            }
            averageAge = [NSNumber numberWithDouble:([totalAge doubleValue]/[[averageAges objectAtIndex:i] count])];
        
            NSLog(@"name: %@, lat: %f, long: %f, percentGuys: %f, averageAge: %@", name, placeCoord.latitude, placeCoord.longitude, percentGuys, averageAge);
        
            //Create and place a map point with the information just acquired
            MapPoint *placeObject = [[MapPoint alloc] initWithName:name address:address coordinate:placeCoord percentGuys:percentGuys averageAge:averageAge];
            [self.mapView addAnnotation:placeObject];
        }
    }
    /*
    // 2 - Loop through the array of places returned from the Google API.
    for (int i=0; i<[data count]; i++) {
        //Retrieve the NSDictionary object in each index of the array.
        NSDictionary* place = [data objectAtIndex:i];
        // 3 - There is a specific NSDictionary object that gives us the location info.
        NSDictionary *geo = [place objectForKey:@"geometry"];
        // Get the lat and long for the location.
        NSDictionary *loc = [geo objectForKey:@"location"];
        // 4 - Get your name and address info for adding to a pin.
        NSString *name=[place objectForKey:@"name"];
        NSString *vicinity=[place objectForKey:@"vicinity"];
        // Create a special variable to hold this coordinate info.
        CLLocationCoordinate2D placeCoord;
        // Set the lat and long.
        placeCoord.latitude=[[loc objectForKey:@"lat"] doubleValue];
        placeCoord.longitude=[[loc objectForKey:@"lng"] doubleValue];
        // 5 - Create a new annotation.
        MapPoint *placeObject = [[MapPoint alloc] initWithName:name address:vicinity coordinate:placeCoord];
        [self.mapView addAnnotation:placeObject];
    }*/
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    // Define your reuse identifier.
    static NSString *identifier = @"MapPoint";
    
    if ([annotation isKindOfClass:[MapPoint class]]) {
        MKPinAnnotationView *annotationView = (MKPinAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (annotationView == nil) {
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        } else {
            annotationView.annotation = annotation;
        }
        annotationView.enabled = YES;
        annotationView.canShowCallout = YES;
        annotationView.animatesDrop = YES;
        return annotationView;
    }
    return nil;
}

//this method is called whenever the refresh button is tapped, refreshes the annotations
- (IBAction)refreshButtonPressed:(id)sender {
    [self startPlotting];
}

@end
