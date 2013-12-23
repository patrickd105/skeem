//
//  MainMenuViewController+skeemCall.h
//  skeem
//
//  Created by Patrick Dunshee on 9/30/13.
//  Copyright (c) 2013 Patrick Dunshee. All rights reserved.
//

#import "MainMenuViewController.h"

@interface MainMenuViewController (skeemCall)

-(void)skeemCall;
-(void)startAfterInterval:(NSTimer*)timer;
-(void)inputParseEntryId:(NSString*)placeId name:(NSString*)placeName lat:(NSString*)placeLatString lng:(NSString*)placeLngString address:(NSString*)placeAddress;
-(void)removeParseEntry;

@end
