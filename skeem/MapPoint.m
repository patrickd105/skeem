//
//  MapPoint.m
//  skeem
//
//  Created by Patrick Dunshee on 10/30/13.
//  Copyright (c) 2013 Patrick Dunshee. All rights reserved.
//

#import "MapPoint.h"

@implementation MapPoint
@synthesize name = _name;
@synthesize address = _address;
@synthesize coordinate = _coordinate;
@synthesize numGuys = _numGuys;
@synthesize numGirls = _numGirls;
@synthesize averageAge = _averageAge;

-(id)initWithName:(NSString*)name address:(NSString*)address coordinate:(CLLocationCoordinate2D)coordinate numGuys:(int)numGuys numGirls:(int)numGirls averageAge:(NSNumber *)averageAge {
    if ((self = [super init])) {
        _name = [name copy];
        _address = [address copy];
        _coordinate = coordinate;
        _numGuys = numGuys;
        _numGirls = numGirls;
        _averageAge = averageAge;
        
    }
    return self;
}

-(NSString *)title {
    if ([_name isKindOfClass:[NSNull class]])
        return @"Unknown charge";
    else
        return _name;
}

-(NSString *)subtitle {
    //convert girl/guy numbers to strings
    NSString *numGuysString = [NSString stringWithFormat:@"%i", _numGuys];
    NSString *numGirlsString = [NSString stringWithFormat:@"%i", _numGirls];
    
    NSArray *stringComponents = [NSArray arrayWithObjects:_address, numGuysString, numGirlsString, _averageAge, nil];
    return [stringComponents componentsJoinedByString:@", "];
}

@end
