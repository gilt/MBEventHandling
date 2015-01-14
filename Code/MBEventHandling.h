//
//  MBEventHandling.h
//  Mockingbird Event Handling
//
//  Created by Evan Coyne Maloney on 3/18/14.
//  Copyright (c) 2014 Gilt Groupe. All rights reserved.
//

#ifndef __OBJC__

#error Mockingbird Event Handling requires Objective-C

#else

//
// NOTE: This header file is indended for external use. It should *not* be
//       included from within code in the Mockingbird Event Handling module.
//

// import headers from inherited modules
#import <MBDataEnvironment/MBDataEnvironment.h>

// import the public headers
#import <MBEventHandling/MBDataFilter.h>
#import <MBEventHandling/MBFilterDataAction.h>
#import <MBEventHandling/MBFilterManager.h>
#import <MBEventHandling/MBEventListener.h>
#import <MBEventHandling/MBListenerManager.h>
#import <MBEventHandling/EnvironmentActions.h>
#import <MBEventHandling/EventActions.h>
#import <MBEventHandling/ExpressionCacheActions.h>
#import <MBEventHandling/FileActions.h>
#import <MBEventHandling/FlowControlActions.h>
#import <MBEventHandling/ServiceActions.h>
#import <MBEventHandling/VariableActions.h>
#import <MBEventHandling/MBEventHandlingConstants.h>
#import <MBEventHandling/MBEventHandlingModule.h>

#endif
