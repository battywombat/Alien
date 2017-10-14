//
//  ParserState.h
//  Alien
//
//  Created by Paul Warner on 10/13/17.
//  Copyright © 2017 Paul Warner. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ClassDefinition.h"
#import "MethodDefinition.h"

@interface ParserState : NSObject

@property BOOL inClass;
@property BOOL stub;
@property enum AccessLevel currentAccessLevel;
@property NSMutableArray<ClassDefinition *> *defns;
@property NSMutableArray <MethodDefinition *> *methods;
@property NSString *className;

-(id) init;

@end