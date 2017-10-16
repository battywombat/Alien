//
//  ParserState.m
//  Alien
//
//  Created by Paul Warner on 10/13/17.
//  Copyright © 2017 Paul Warner. All rights reserved.
//

#import "ParserState.h"

@implementation ParserState

- (id)init {
    self = [super init];
    _inClass = false;
    _stub = false;
    _methods = [[NSMutableArray alloc] init];
    _className = nil;
    _currentAccessLevel = PRIVATE;
    _fields = [[NSMutableArray alloc] init];
    return self;
}

@end
