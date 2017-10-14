//
//  Stack.m
//  Alien
//
//  Created by Paul Warner on 10/13/17.
//  Copyright © 2017 Paul Warner. All rights reserved.
//

#import "Stack.h"

@implementation Stack

- (void)push:(id)obj {
    [_data addObject: obj];
}

- (id)pop {
    id item = _data.lastObject;
    [_data removeLastObject];
    return item;
}

- (id)init {
    self = [super init];
    _data = [[NSMutableArray alloc] init];
    return self;
}

- (id)peek {
    return _data.lastObject;
}

- (NSUInteger)count { 
    return _data.count;
}

@end
