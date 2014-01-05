//
//  MapPoint.h
//  skeem
//
//  Created by Patrick Dunshee on 10/30/13.
//  Copyright (c) 2013 Patrick Dunshee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MapPoint : NSObject <MKAnnotation>
{
    
    NSString *_name;
    NSString *_address;
    int numGuys;
    int numGirls;
    NSNumber *_averageAge;
    CLLocationCoordinate2D _coordinate;
    
}

@property (copy) NSString *name;
@property (copy) NSString *address;
@property (nonatomic) int numGuys;
@property (nonatomic) int numGirls;
@property (copy) NSNumber *averageAge;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;


- (id)initWithName:(NSString*)name address:(NSString*)address coordinate:(CLLocationCoordinate2D)coordinate numGuys:(int)numGuys numGirls:(int)numGirls averageAge:(NSNumber*)averageAge;

@end
