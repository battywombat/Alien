//
//  ClassDefinition.m
//  Alien
//
//  Created by Paul Warner on 10/6/17.
//  Copyright © 2017 Paul Warner. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ClassDeclaration.h"

@implementation ClassDeclaration

- (id)init:(NSString *)name withMethods:(NSArray *)methods andFields:(NSArray<NSArray *> *)fields {
    self = [super initWithName: name inNamespace: nil];
    _methods = methods;
    _fields = fields;
    _stub = false;
    return self;
}

- (id)init:(NSString *)name {
    self = [super initWithName: name inNamespace: nil];
    _stub = true;
    return self;
}

@end
