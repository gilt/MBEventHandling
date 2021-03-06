//
//  VariableActions.m
//  Mockingbird Event Handling
//
//  Created by Evan Coyne Maloney on 6/27/13.
//  Copyright (c) 2013 Gilt Groupe. All rights reserved.
//

#import <MBDataEnvironment/MBDataEnvironment.h>

#import "VariableActions.h"
#import "MBEventHandlingConstants.h"

#define DEBUG_LOCAL     0
#define DEBUG_VERBOSE   0
#define DEBUG_VALUES    0   // if set, shows the actions & values as they're executed (only works when DEBUG is set)

/******************************************************************************/
#pragma mark -
#pragma mark MBVariableActionBase implementation
/******************************************************************************/

@implementation MBVariableActionBase

/******************************************************************************/
#pragma mark Data model enforcement
/******************************************************************************/

+ (nullable NSSet*) requiredAttributes
{
    return [NSSet setWithObject:kMBMLAttributeName];
}

/******************************************************************************/
#pragma mark Action implementation
/******************************************************************************/

- (void) executeForVariableNamed:(NSString*)varName
{
    MBErrorNotImplemented();
}

- (void) executeForEvent:(nullable NSNotification*)event
{
    MBLogVerboseTrace();

    NSString* name = [self evaluateAsString:kMBMLAttributeName];
    [self executeForVariableNamed:name];
}

@end

/******************************************************************************/
#pragma mark -
#pragma mark MBSetVariableActionBase implementation
/******************************************************************************/

@implementation MBSetVariableActionBase

/******************************************************************************/
#pragma mark Data model enforcement
/******************************************************************************/

+ (nullable NSSet*) supportedAttributes
{
    return [NSSet setWithObjects:kMBMLAttributeValue,
            kMBMLAttributeLiteral,
            kMBMLAttributeBoolean,
            nil];
}

- (BOOL) validateAttributes
{
    if (![super validateAttributes])
        return NO;

    if (!self.content) {
        MBAttributeValidator* valid = [MBAttributeValidator validatorForDataModel:self];
        [valid requireExactlyOneOf:@[kMBMLAttributeValue, kMBMLAttributeLiteral, kMBMLAttributeBoolean]];
        return [valid validate];
    }

    return YES;
}

- (BOOL) acceptsTextContent
{
    return YES;
}

/******************************************************************************/
#pragma mark Action implementation
/******************************************************************************/

- (id) variableValue
{
    MBLogVerboseTrace();

    id value = [self stringValueOfAttribute:kMBMLAttributeValue];
    if (value) {
        value = [MBExpression asObject:value];
    }
    else {
        if ([self hasAttribute:kMBMLAttributeBoolean]) {
            value = @([self evaluateAsBoolean:kMBMLAttributeBoolean]);
        }
        else {
            value = self[kMBMLAttributeLiteral];
            if (!value && self.content) {
                value = [[self.content description] evaluateAsObject];
            }
        }
    }
    return value;
}

- (void) executeForVariableNamed:(NSString*)varName value:(id)value
{
    MBErrorNotImplemented();
}

- (void) executeForVariableNamed:(NSString*)varName
{
    MBLogVerboseTrace();

    id value = [self variableValue];
    [self executeForVariableNamed:varName value:value];
}

@end

/******************************************************************************/
#pragma mark -
#pragma mark MBBooleanVariableValueActionBase implementation
/******************************************************************************/

@implementation MBBooleanVariableValueActionBase

/******************************************************************************/
#pragma mark Action implementation
/******************************************************************************/

- (id) variableValue
{
    MBLogVerboseTrace();

    BOOL value = NO;
    if ([self hasAttribute:kMBMLAttributeValue]) {
        value = [self evaluateAsBoolean:kMBMLAttributeValue];
    }
    else if ([self hasAttribute:kMBMLAttributeLiteral]) {
        value = [self booleanValueOfAttribute:kMBMLAttributeLiteral];
    }
    return [NSNumber numberWithBool:value];
}

@end

/******************************************************************************/
#pragma mark -
#pragma mark MBSetVarAction implementation
/******************************************************************************/

@implementation MBSetVarAction

/******************************************************************************/
#pragma mark Data model enforcement
/******************************************************************************/

+ (nullable NSSet*) supportedAttributes
{
    return [NSSet setWithObjects:kMBMLAttributeMapKey,
            kMBMLAttributeListIndex,
            nil];
}

/******************************************************************************/
#pragma mark Action implementation
/******************************************************************************/

- (void) executeForVariableNamed:(NSString*)varName value:(id)value
{
    MBLogDebugTrace();

    NSString* mapKeyRaw = [self stringValueOfAttribute:kMBMLAttributeMapKey];
    NSString* listIndexRaw = [self stringValueOfAttribute:kMBMLAttributeListIndex];
    if (mapKeyRaw) {
        NSString* mapKey = [MBExpression asString:mapKeyRaw];
        if (mapKey) {
            if (DEBUG_FLAG(DEBUG_VALUES)) MBLog(MBLogSeverityDebug, @"%@: %@.%@ = %@: \"%@\"", self.xmlTagName, varName, mapKey, [value class], value);
            
            [[MBVariableSpace instance] setMapVariable:varName mapKey:mapKey value:value];
        }
        else {
            MBLogError(@"<%@> requires the expression specified in the mapKey attribute to evaluate to a string value; the expression \"%@\" evaluates to nil", self.xmlTagName, mapKeyRaw);
        }
    }
    else if (listIndexRaw) {
        NSNumber* listIndex = [MBExpression asNumber:listIndexRaw];
        if (listIndex) {
            if (DEBUG_FLAG(DEBUG_VALUES)) MBLog(MBLogSeverityDebug, @"%@: %@[%@] = %@: \"%@\"", self.xmlTagName, varName, listIndex, [value class], value);

            [[MBVariableSpace instance] setListVariable:varName listIndex:[listIndex integerValue] value:value];
        }
        else {
            MBLogError(@"<%@> requires the expression specified in the listIndex attribute to evaluate to a numeric value; the expression \"%@\" evaluates to nil", self.xmlTagName, listIndexRaw);
        }
    }
    else {
        if (DEBUG_FLAG(DEBUG_VALUES)) MBLog(MBLogSeverityDebug, @"%@: %@ = %@: \"%@\"", self.xmlTagName, varName, [value class], value);

        [MBVariableSpace instance][varName] = value;
    }   
}

@end

/******************************************************************************/
#pragma mark -
#pragma mark MBSetTransientVarAction implementation
/******************************************************************************/

@implementation MBSetTransientVarAction

/******************************************************************************/
#pragma mark Action implementation
/******************************************************************************/

- (void) executeForVariableNamed:(NSString*)varName value:(id)value
{
    MBLogDebugTrace();

    if (DEBUG_FLAG(DEBUG_VALUES)) MBLog(MBLogSeverityDebug, @"%@: %@ = %@: \"%@\"", self.xmlTagName, varName, [value class], value);

    [MBScopedVariables currentVariableScope][varName] = value;
}

@end

/******************************************************************************/
#pragma mark -
#pragma mark MBSetTransientBooleanVarAction implementation
/******************************************************************************/

@implementation MBSetTransientBooleanVarAction

/******************************************************************************/
#pragma mark Action implementation
/******************************************************************************/

- (void) executeForVariableNamed:(NSString*)varName value:(id)value
{
    MBLogDebugTrace();

    if (DEBUG_FLAG(DEBUG_VALUES)) MBLog(MBLogSeverityDebug, @"%@: %@ = %@: \"%@\"", self.xmlTagName, varName, [value class], value);

    [MBScopedVariables currentVariableScope][varName] = value;
}

@end

/******************************************************************************/
#pragma mark -
#pragma mark MBUnsetVarAction implementation
/******************************************************************************/

@implementation MBUnsetVarAction

/******************************************************************************/
#pragma mark Action implementation
/******************************************************************************/

- (void) executeForVariableNamed:(NSString*)varName
{
    MBLogDebugTrace();

    if (DEBUG_FLAG(DEBUG_VALUES)) MBLog(MBLogSeverityDebug, @"%@: %@", self.xmlTagName, varName);

    [[MBVariableSpace instance] unsetVariable:varName];
}

@end

/******************************************************************************/
#pragma mark -
#pragma mark MBPushVarAction implementation
/******************************************************************************/

@implementation MBPushVarAction

/******************************************************************************/
#pragma mark Action implementation
/******************************************************************************/

- (void) executeForVariableNamed:(NSString*)varName value:(id)value
{
    MBLogDebugTrace();

    if (DEBUG_FLAG(DEBUG_VALUES)) MBLog(MBLogSeverityDebug, @"%@: %@ = %@: \"%@\"", self.xmlTagName, varName, [value class], value);

    [[MBVariableSpace instance] pushVariable:varName value:value];
}

@end

/******************************************************************************/
#pragma mark -
#pragma mark MBPopVarAction implementation
/******************************************************************************/

@implementation MBPopVarAction

/******************************************************************************/
#pragma mark Action implementation
/******************************************************************************/

- (void) executeForVariableNamed:(NSString*)varName
{
    MBLogDebugTrace();

    if (DEBUG_FLAG(DEBUG_VALUES)) MBLog(MBLogSeverityDebug, @"%@: %@", self.xmlTagName, varName);

    [[MBVariableSpace instance] popVariable:varName];
}

@end

/******************************************************************************/
#pragma mark -
#pragma mark MBSetBooleanVarAction implementation
/******************************************************************************/

@implementation MBSetBooleanVarAction

/******************************************************************************/
#pragma mark Action implementation
/******************************************************************************/

- (void) executeForVariableNamed:(NSString*)varName value:(id)value
{
    MBLogDebugTrace();

    if (DEBUG_FLAG(DEBUG_VALUES)) MBLog(MBLogSeverityDebug, @"%@: %@ = %@: \"%@\"", self.xmlTagName, varName, [value class], value);

    [MBVariableSpace instance][varName] = value;
}

@end

/******************************************************************************/
#pragma mark -
#pragma mark MBPushBooleanVarAction implementation
/******************************************************************************/

@implementation MBPushBooleanVarAction

/******************************************************************************/
#pragma mark Action implementation
/******************************************************************************/

- (void) executeForVariableNamed:(NSString*)varName value:(id)value
{
    MBLogDebugTrace();

    if (DEBUG_FLAG(DEBUG_VALUES)) MBLog(MBLogSeverityDebug, @"%@: %@ = %@: \"%@\"", self.xmlTagName, varName, [value class], value);

    [[MBVariableSpace instance] pushVariable:varName value:value];
}

@end
