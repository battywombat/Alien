//
//  MethodDefinitionTests.m
//  Alien-Tests
//
//  Created by Paul Warner on 10/17/17.
//  Copyright © 2017 Paul Warner. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MethodDefinition.h"

@interface MethodDefinitionTests : XCTestCase

@end

@implementation MethodDefinitionTests

-(void)testHeaderNoArgs {
    MethodDefinition *d = [[MethodDefinition alloc] init];
    d.name = @"testname";
    d.type = [[Type alloc] initWithType: [TypeDeclaration voidType]];
    NSString *def = [d createNSHeader];
    XCTAssert([def isEqualTo: @"-(void)testname"]);
}

- (void)testHeaderOneArg {
    MethodDefinition *d = [[MethodDefinition alloc] init: @"testname"
                                           withArguments: @[ @[[[Type alloc] initWithType: [TypeDeclaration intType]], @"one"]]
                                                  ofType: NORMAL
                                         withAccessLevel: PUBLIC];
    NSString *def = [d createNSHeader];
    XCTAssert([def isEqualTo: @"-(void)testname: (int) one"]);
}

- (void)testHeaderTwoArgs {
    MethodDefinition *d = [[MethodDefinition alloc] init: @"testname"
                                           withArguments: @[ @[[[Type alloc] initWithType: [TypeDeclaration intType]], @"one"],
                                                             @[[[Type alloc] initWithType: [TypeDeclaration stringType]], @"two"]
                                                             ]
                                                  ofType: NORMAL                                         withAccessLevel: PUBLIC];
    NSString *def = [d createNSHeader];
    XCTAssert([def isEqualTo: @"-(void)testname: (int) one two: (NSString *) two"]);
}

- (void) testHeaderInit {
    MethodDefinition *d = [[MethodDefinition alloc] init: @"TestClass"
                                           withArguments: @[]
                                                  ofType: INIT
                                         withAccessLevel: PUBLIC];
    NSString *def = [d createNSHeader];
    XCTAssert([def isEqualTo: @"-(id)init"]);
}

- (void) testHeaderInitWithArgs {
    MethodDefinition *d = [[MethodDefinition alloc] init: @"TestClass"
                                           withArguments: @[
                                                            @[[[Type alloc] initWithType: [TypeDeclaration intType]], @"one"]
                                                            ]
                                                  ofType: INIT
                                         withAccessLevel: PUBLIC];
    NSString *def = [d createNSHeader];
    XCTAssert([def isEqualTo: @"-(id)init: (int) one"]);
}

- (void)testHeaderStatic {
    MethodDefinition *d = [[MethodDefinition alloc] init: @"TestClass"
                                           withArguments: @[
                                                            @[[[Type alloc] initWithType: [TypeDeclaration intType]], @"one"]
                                                            ]
                                                  ofType: NORMAL
                                         withAccessLevel: PUBLIC];
    d.isStatic = true;
    NSString *def = [d createNSHeader];
    XCTAssert([def isEqualTo: @"+(void)TestClass: (int) one"]);
}

@end
