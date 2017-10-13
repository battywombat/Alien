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

-(id)initWithTokens: (CPPTokenizer *) tokens
{
    self = [super init];

    
    return self;
}

- (id)init:(NSString *)name withMethods:(NSArray *)methods {
    self = [super init];
    _className = name;
    _methods = methods;
    _stub = false;
    return self;
}

- (id)init:(NSString *)name {
    self = [super init];
    _className = name;
    _stub = true;
    return self;
}

@end
