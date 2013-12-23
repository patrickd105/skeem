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
@synthesize percentGuys = _percentGuys;
@synthesize averageAge = _averageAge;

-(id)initWithName:(NSString*)name address:(NSString*)address coordinate:(CLLocationCoordinate2D)coordinate percentGuys:(double)percentGuys averageAge:(NSNumber *)averageAge {
    if ((self = [super init])) {
        _name = [name copy];
        _address = [address copy];
        _coordinate = coordinate;
        _percentGuys = percentGuys;
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
    //convert percentages to strings
    NSString *percentGuysString = [NSString stringWithFormat:@"%f", _percentGuys];
    
    NSArray *stringComponents = [NSArray arrayWithObjects:_address, percentGuysString, _averageAge, nil];
    return [stringComponents componentsJoinedByString:@", "];
}

@end
