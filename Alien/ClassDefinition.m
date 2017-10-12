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


- (void)throwException : (NSString *) message {
    @throw [NSException exceptionWithName: @"ParseError"
                                   reason: message
                                 userInfo: nil];
}

-(id)initWithTokens: (CPPTokenizer *) tokens
{
    self = [super init];
    NSString *currentToken;
    _methods = [[NSMutableArray alloc] init];
    _className = [tokens nextToken];
    NSString *superClassName;
    currentToken = [tokens nextToken];
    if ([currentToken isEqualTo: @":"]) {
        superClassName = [tokens nextToken];
    }
    else if ([currentToken isEqualTo: @";"]) {
        _stub = true;
        return self;
    }
    else {
        superClassName = @"NSObject";
    }
    _stub = false;
    currentToken = [tokens nextToken];
    if (![currentToken isEqualTo: @"{"]) {
        [self throwException: @"Incomplete class definition"];
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
                [self throwException: @"expected ':'"];
            }
        }
        else if ([currentToken isEqualTo: @"private"] || [currentToken isEqualTo: @"protected"]) {
            if ([currentToken isEqualTo: @":"]) {
                public = false;
            }
            else {
                [self throwException: @"Expected ':'"];
            }
        }
        
        else if ([currentToken isEqualTo: _className]) {
            
        }
        else if ([currentToken isEqualTo: [@"~" stringByAppendingString: _className]]) {
            
        }
        else if (![currentToken isEqualTo: @"\n"]) {
            [tokens rewind];
            MethodDefinition *newMethod = [MethodDefinition parseMethod: tokens];
            [_methods addObject: newMethod];
        }
    }
    
    return self;
}

@end
