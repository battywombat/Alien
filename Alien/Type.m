//
//  TypeDefinition.m
//  Alien
//
//  Created by Paul Warner on 10/14/17.
//  Copyright © 2017 Paul Warner. All rights reserved.
//

#import "Type.h"

@implementation Type

- (id) init {
    return [self initWithType: nil];
}

- (id) initWithType:(TypeDeclaration *)type {
    self = [super init];
    _typeDecl = type;
    _isReference = false;
    _indirectionCount = 0;
    _typeParameters = [[NSMutableArray alloc] init];
    _qualifiers = [[NSMutableArray alloc] init];
    return self;
}

-(BOOL)addQualifier: (NSString *) qualifier {
    [_qualifiers addObject: qualifier];
    return true;
}

@end
