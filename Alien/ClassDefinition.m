//
//  ClassDefinition.m
//  Alien
//
//  Created by Paul Warner on 10/6/17.
//  Copyright © 2017 Paul Warner. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ClassDefinition.h"

@implementation ClassDefinition

-(id)init
{
    self = [super init];
    _methods = [[NSMutableArray alloc] init];
    return self;
}


+(id)parseClass: (CPPTokenizer *) tokens
{
    ClassDefinition *defn = [[ClassDefinition alloc] init];
    NSString *currentToken;
    defn->className = [tokens nextToken];
    NSString *superClassName;
    currentToken = [tokens nextToken];
    if ([currentToken isEqualTo: @":"]) {
        superClassName = [tokens nextToken];
    }
    else if ([currentToken isEqualTo: @";"]) {
        [defn setStub: true];
        return defn;
    }
    else {
        superClassName = @"NSObject";
    }
    [defn setStub: false];
    currentToken = [tokens nextToken];
    if (![currentToken isEqualTo: @"{"]) {
        return defn;
    }
    BOOL in_class = true;
    BOOL public = false;
    while (in_class) {
        currentToken = [tokens nextToken];
        if ([currentToken isEqualTo: @"public"]) {
            currentToken = [tokens nextToken];
            if ([currentToken isEqualTo: @":"]) {
                public = true;
            }
            else {
                return defn;
            }
        }
        else if ([currentToken isEqualTo: @"private"] || [currentToken isEqualTo: @"protected"]) {
            if ([currentToken isEqualTo: @":"]) {
                public = false;
            }
            else {
                return defn;
            }
        }
        
        else if ([currentToken isEqualTo: [defn className]]) {
            
        }
        else if ([currentToken isEqualTo: [@"~" stringByAppendingString: [defn className]]]) {
            
        }
        else if (![currentToken isEqualTo: @"\n"]) {
            [tokens rewind];
            MethodDefinition *newMethod = [MethodDefinition parseMethod: tokens];
            [[defn methods] addObject: newMethod];
        }
    }
    
    return defn;
}

@end
