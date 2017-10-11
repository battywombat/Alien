//
//  TypeManagerTests.m
//  Alien-Tests
//
//  Created by Paul Warner on 10/9/17.
//  Copyright © 2017 Paul Warner. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "TypeManager.h"
#import "CPPTokenizer.h"

@interface TypeManagerTests : XCTestCase

@end

@implementation TypeManagerTests

- (void)setUp {
    [super setUp];
    [[TypeManager singleton] startNewFile];
}

- (void)testBasic {
    CPPTokenizer *tokenizer = [[CPPTokenizer alloc] initFromString: @"int"];
    NSString *ty = [[TypeManager singleton] parseType: tokenizer];
    XCTAssert([ty isEqualTo: @"int"]);
}

- (void)testPrefix {
    CPPTokenizer *tokenizer = [[CPPTokenizer alloc] initFromString: @"unsigned char"];
    NSString *ty = [[TypeManager singleton] parseType: tokenizer];
    XCTAssert([ty isEqualTo: @"unsigned char"]);
}

- (void)testNamespace {
    CPPTokenizer *tokens = [[CPPTokenizer alloc] initFromString: @"std::string"];
    NSString *ty = [[TypeManager singleton] parseType: tokens];
    XCTAssert([ty isEqualTo: @"std::string"]);
}

- (void)testUseNamespace {
    CPPTokenizer *tokens = [[CPPTokenizer alloc] initFromString: @"string"];
    [[TypeManager singleton] useNamespace: @"std"];
    NSString *ty = [[TypeManager singleton] parseType: tokens];
    XCTAssert([ty isEqualTo: @"string"]);
}



@end
