//
//  TypeTests.m
//  Alien-Tests
//
//  Created by Paul Warner on 10/16/17.
//  Copyright © 2017 Paul Warner. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Type.h"
#import "TypeDeclaration.h"

@interface TypeTests : XCTestCase

@end

@implementation TypeTests

- (void) testInt {
    Type *t = [[Type alloc] init];
    t.typeDecl = [TypeDeclaration intType];
    XCTAssert([t.typeForNS isEqualTo: @"int"]);
}

- (void) testPtr {
    Type *t = [[Type alloc] init];
    t.typeDecl = [TypeDeclaration intType];
    t.indirectionCount = 1;
    XCTAssert([[t typeForNS] isEqualTo: @"int *"]);
}

- (void) testDoublePtr {
    Type *t = [[Type alloc] init];
    t.typeDecl = [TypeDeclaration intType];
    t.indirectionCount = 2;
    XCTAssert([[t typeForNS] isEqualTo: @"int **"]);
}

- (void) testModifier {
    Type *t = [[Type alloc] init];
    t.typeDecl = [TypeDeclaration intType];
    [[t qualifiers] addObject: @"unsigned"];
    XCTAssert([[t typeForNS] isEqualTo: @"unsigned int"]);
}

- (void) testConstPtr {
    Type *t = [[Type alloc] init];
    t.typeDecl = [TypeDeclaration intType];
    t.constPtr = true;
    t.indirectionCount = 1;
    XCTAssert([[t typeForNS] isEqualTo: @"int * const"]);
}

- (void)testSpecialCase {
    Type *t = [[Type alloc] init];
    t.typeDecl = [TypeDeclaration stringType];
    XCTAssert([[t typeForNS] isEqualTo: @"NSString *"]);
}

- (void)testSingleTypeParameter {
    Type *t = [[Type alloc] init];
    t.typeDecl = [TypeDeclaration vectorType];
    Type *subtype = [[Type alloc] init];
    subtype.typeDecl = [TypeDeclaration intType];
    [t.typeParameters addObject: subtype];
    XCTAssert([[t typeForNS] isEqualTo: @"NSMutableArray<int> *"]);
}

- (void)testSingleMutipleTypeParameter {
    Type *t = [[Type alloc] init];
    t.typeDecl = [TypeDeclaration mapType];
    Type *subtype1 = [[Type alloc] init];
    subtype1.typeDecl = [TypeDeclaration intType];
    [t.typeParameters addObject: subtype1];
    Type *subtype2 = [[Type alloc] initWithType: [TypeDeclaration stringType]];
    [t.typeParameters addObject: subtype2];
    XCTAssert([[t typeForNS] isEqualTo: @"NSMutableDictionary<int,NSString *> *"]);
}


@end
