//
//  TypeDeclarationTests.m
//  Alien-Tests
//
//  Created by Paul Warner on 10/18/17.
//  Copyright © 2017 Paul Warner. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TypeDeclaration.h"

@interface TypeDeclarationTests : XCTestCase

@end

@implementation TypeDeclarationTests

- (void)testEqualReflexive {
    TypeDeclaration *decl = [TypeDeclaration intType];
    XCTAssert([decl isEqual: decl]);
}

- (void)testEqualSymmetric {
    TypeDeclaration *decl1 = [TypeDeclaration stringType];
    TypeDeclaration *decl2 = [[TypeDeclaration alloc] initWithName: @"string" inNamespace: @"std"];
    XCTAssert([decl1 isEqual: decl2] && [decl2 isEqual: decl1]);
}


- (void)testEqualTransitive {
    TypeDeclaration *decl1 = [TypeDeclaration mapType];
    TypeDeclaration *decl2 = [[TypeDeclaration alloc] initWithName: @"map" inNamespace: @"std" withParams: 2];
    TypeDeclaration *decl3 = [[TypeDeclaration alloc] initWithName: @"map" inNamespace: @"std" withParams: 2];
    XCTAssert([decl1 isEqual: decl2] && [decl2 isEqual: decl3] && [decl1 isEqual: decl3]);
}


@end
