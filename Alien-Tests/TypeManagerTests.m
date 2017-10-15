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
#import "TypeDefinition.h"

@interface TypeManagerTests : XCTestCase

@end

@implementation TypeManagerTests

- (void)setUp {
    [super setUp];
    [[TypeManager singleton] startNewFile];
}

- (void)testBasic {
    CPPTokenizer *tokenizer = [[CPPTokenizer alloc] initFromString: @"int"];
    TypeDefinition *ty = [[TypeManager singleton] parseType: tokenizer];
    XCTAssert([ty.name isEqualTo: @"int"]);
}

- (void)testPrefix {
    CPPTokenizer *tokenizer = [[CPPTokenizer alloc] initFromString: @"unsigned char"];
    TypeDefinition *ty = [[TypeManager singleton] parseType: tokenizer];
    XCTAssert([ty.name isEqualTo: @"char"] && ty.qualifiers.count == 1 && [ty.qualifiers[0] isEqualTo: @"unsigned"]);
}

- (void)testNamespace {
    CPPTokenizer *tokens = [[CPPTokenizer alloc] initFromString: @"std::string"];
    TypeDefinition *ty = [[TypeManager singleton] parseType: tokens];
    XCTAssert([ty.name isEqualTo: @"string"] && [ty.containingNamespace isEqualTo: @"std"]);
}

- (void)testUseNamespace {
    CPPTokenizer *tokens = [[CPPTokenizer alloc] initFromString: @"string"];
    [[TypeManager singleton] useNamespace: @"std"];
    TypeDefinition *ty = [[TypeManager singleton] parseType: tokens];
    XCTAssert([ty.name isEqualTo: @"string"] && [ty.containingNamespace isEqualTo: @"std"]);
}

- (void)testGeneric {
    NSString *typeDesc = @"std::vector<std::string>";
    CPPTokenizer *tokens = [[CPPTokenizer alloc] initFromString: typeDesc];
    TypeDefinition *ty = [[TypeManager singleton] parseType: tokens];;
    XCTAssert([ty.name isEqualTo: @"vector"]);
    XCTAssert([ty.typeParameters count] == 1 && [ty.typeParameters[0].name isEqualTo: @"string"]);
}

- (void)testMutlipleGeneric {
    NSString *typeDesc = @"std::map<std::string, int>";
    CPPTokenizer *tokens = [[CPPTokenizer alloc] initFromString: typeDesc];
    TypeDefinition *ty = [[TypeManager singleton] parseType: tokens];
    XCTAssert([ty.name isEqualTo: @"map"]);
    XCTAssert(ty.typeParameters.count == 2 && [ty.typeParameters[0].name isEqualTo: @"string"] && [ty.typeParameters[1].name isEqualTo: @"int"]);
}

- (void)testNestedGeneric {
    NSString *typeDesc = @"std::vector<std::vector<int>>";
    CPPTokenizer *tokens = [[CPPTokenizer alloc] initFromString: typeDesc];
    TypeDefinition *ty = [[TypeManager singleton] parseType: tokens];
    XCTAssert([ty.name isEqualTo: @"vector"] && [ty.containingNamespace isEqualTo: @"std"] && ty.typeParameters.count == 1);
    XCTAssert([ty.typeParameters[0].name isEqualTo: @"vector"] && [ty.typeParameters[0].typeParameters[0].name isEqualTo: @"int"]);
}



@end
