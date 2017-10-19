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

- (void)testCppString {
    Type *t = [[Type alloc] init];
    t.typeDecl = [TypeDeclaration stringType];
    [[t typeForCpp] isEqualTo: @"std::string"];
}

- (void)testCppVector {
    Type *t = [[Type alloc] init];
    t.typeDecl = [TypeDeclaration vectorType];
    Type *subType = [[Type alloc] init];
    subType.typeDecl = [TypeDeclaration stringType];
    [t.typeParameters addObject: subType];
    [[t typeForCpp] isEqualTo: @"std::vector<std::string>"];
}

- (void)testEqualReflexive {
    Type *t = [[Type alloc] init];
    t.typeDecl = [TypeDeclaration mapType];
    XCTAssert([t isEqual: t]);
}

- (void)testEqualSymmetric {
    Type *t = [[Type alloc] init];
    t.typeDecl = [TypeDeclaration intType];
    t.indirectionCount = 1;
    t.constPtr = true;
    Type *t2 = [[Type alloc] init];
    t2.typeDecl = [TypeDeclaration intType];
    t2.indirectionCount = 1;
    t2.constPtr = true;
    XCTAssert([t isEqual: t2] && [t2 isEqual: t]);
}

- (void)testEqualTransitive {
    Type *t = [[Type alloc] init];
    t.typeDecl = [TypeDeclaration intType];
    t.indirectionCount = 1;
    t.constPtr = true;
    Type *t2 = [[Type alloc] init];
    t2.typeDecl = [TypeDeclaration intType];
    t2.indirectionCount = 1;
    t2.constPtr = true;
    Type *t3 = [[Type alloc] init];
    t3.typeDecl = [[TypeDeclaration alloc] initWithName: @"int" inNamespace: nil];
    t3.indirectionCount = 1;
    t3.constPtr = true;
    XCTAssert([t isEqual: t2] && [t2 isEqual: t3] && [t isEqual: t3]);
}

//- (void) testIntConverter {
//    Type *t = [[Type alloc] init];
//    t.typeDecl = [TypeDeclaration intType];
//    NSString *conv = [t convertToCpp: @"arg1" dest: @"arg2"];
//    XCTAssert([conv isEqualTo: @"int arg1 = arg2;"]);
//}
//
//- (void) testStringConverter {
//    Type *t = [[Type alloc] init];
//    t.typeDecl = [TypeDeclaration stringType];
//    NSString *conv = [t convertToCpp: @"arg1" dest: @"arg2"];
//    XCTAssert([conv isEqualTo: @"std::string arg1 = [arg2 UTF8String];"]);
//}

@end
