//
//  MBFilterManager.m
//  Mockingbird Library
//
//  Created by Evan Coyne Maloney on 7/30/14.
//  Copyright (c) 2014 Gilt Groupe. All rights reserved.
//

#import <RaptureXML@Gilt/RXMLElement.h>
#import <MBDataEnvironment/MBEnvironment.h>

#import "MBFilterManager.h"
#import "MBDataFilter.h"
#import "MBEventHandling.h"

#define DEBUG_LOCAL         0
#define DEBUG_VERBOSE       0

/******************************************************************************/
#pragma mark Constants
/******************************************************************************/

NSString* const kMBMLTagDataFilter            = @"DataFilter";

/******************************************************************************/
#pragma mark -
#pragma mark MBVariableSpace implementation
/******************************************************************************/

@implementation MBFilterManager
{
    NSMutableDictionary* _namesToFilters;
}

/******************************************************************************/
#pragma mark Instance vendor
/******************************************************************************/

+ (instancetype) instance
{
    return (MBFilterManager*)[[MBEnvironment instance] environmentLoaderOfClass:self];
}

/******************************************************************************/
#pragma mark Object lifecycle
/******************************************************************************/

- (id) init
{
    self = [super init];
    if (self) {
        _namesToFilters = [NSMutableDictionary new];
    }
    return self;
}

/******************************************************************************/
#pragma mark Managing the environment
/******************************************************************************/

- (NSArray*) acceptedTagNames
{
    return @[kMBMLTagDataFilter];
}

- (BOOL) parseElement:(RXMLElement*)mbml forMatch:(NSString*)match
{
    verboseDebugTrace();

    NSString* tagName = mbml.tag;
    if ([tagName isEqualToString:kMBMLTagDataFilter]) {
        MBDataFilter* filter = [MBDataFilter dataModelFromXML:mbml];
        if ([filter validateDataModel]) {
            _namesToFilters[filter.name] = filter;
        }
        else {
            errorLog(@"The following %@ did not validate and will be ignored: %@", tagName, mbml.xml);
            return NO;
        }
    }
    else {
        return NO;
    }
    return YES;
}

/******************************************************************************/
#pragma mark Accessing data filters
/******************************************************************************/

- (NSArray*) filterNames
{
    verboseDebugTrace();
    
    return [_namesToFilters allKeys];
}

- (MBDataFilter*) filterWithName:(NSString*)name
{
    verboseDebugTrace();
    
    return _namesToFilters[name];
}

@end
