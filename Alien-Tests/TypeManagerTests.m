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
#import "Type.h"

@interface TypeManagerTests : XCTestCase

@property TypeManager * types;

@end

@implementation TypeManagerTests

- (void)setUp {
    [super setUp];
    _types = [[TypeManager alloc] init];
    [_types startNewFile];
}

- (void)testBasic {
    CPPTokenizer *tokenizer = [[CPPTokenizer alloc] initFromString: @"int"];
    Type *ty = [_types parseType: tokenizer];
    XCTAssert([ty.typeDecl.name isEqualTo: @"int"]);
}

- (void)testPrefix {
    CPPTokenizer *tokenizer = [[CPPTokenizer alloc] initFromString: @"unsigned char"];
    Type *ty = [_types parseType: tokenizer];
    XCTAssert([ty.typeDecl.name isEqualTo: @"char"] && ty.qualifiers.count == 1 && [ty.qualifiers[0] isEqualTo: @"unsigned"]);
}

- (void)testNamespace {
    CPPTokenizer *tokens = [[CPPTokenizer alloc] initFromString: @"std::string"];
    Type *ty = [_types parseType: tokens];
    XCTAssert([ty.typeDecl.name isEqualTo: @"string"] && [ty.typeDecl.containingNamespace isEqualTo: @"std"]);
}

- (void)testUseNamespace {
    CPPTokenizer *tokens = [[CPPTokenizer alloc] initFromString: @"string"];
    [_types useNamespace: @"std"];
    Type *ty = [_types parseType: tokens];
    XCTAssert([ty.typeDecl.name isEqualTo: @"string"] && [ty.typeDecl.containingNamespace isEqualTo: @"std"]);
}

- (void)testGeneric {
    NSString *typeDesc = @"std::vector<std::string>";
    CPPTokenizer *tokens = [[CPPTokenizer alloc] initFromString: typeDesc];
    Type *ty = [_types parseType: tokens];;
    XCTAssert([ty.typeDecl.name isEqualTo: @"vector"]);
    XCTAssert([ty.typeParameters count] == 1 && [ty.typeParameters[0].typeDecl.name isEqualTo: @"string"]);
}

- (void)testMutlipleGeneric {
    NSString *typeDesc = @"std::map<std::string, int>";
    CPPTokenizer *tokens = [[CPPTokenizer alloc] initFromString: typeDesc];
    Type *ty = [_types parseType: tokens];
    XCTAssert([ty.typeDecl.name isEqualTo: @"map"]);
    XCTAssert(ty.typeParameters.count == 2 && [ty.typeParameters[0].typeDecl.name isEqualTo: @"string"] && [ty.typeParameters[1].typeDecl.name isEqualTo: @"int"]);
}

- (void)testNestedGeneric {
    NSString *typeDesc = @"std::vector<std::vector<int>>";
    CPPTokenizer *tokens = [[CPPTokenizer alloc] initFromString: typeDesc];
    Type *ty = [_types parseType: tokens];
    XCTAssert([ty.typeDecl.name isEqualTo: @"vector"] && [ty.typeDecl.containingNamespace isEqualTo: @"std"] && ty.typeParameters.count == 1);
    XCTAssert([ty.typeParameters[0].typeDecl.name isEqualTo: @"vector"] && [ty.typeParameters[0].typeParameters[0].typeDecl.name isEqualTo: @"int"]);
}

- (void)testPointer {
    CPPTokenizer *tokenizer = [[CPPTokenizer alloc] initFromString: @"int *"];
    Type *ty = [_types parseType: tokenizer];
    XCTAssert([ty.typeDecl.name isEqualTo: @"int"] && ty.indirectionCount == 1);
}

- (void)testReference {
    CPPTokenizer *tokenizer = [[CPPTokenizer alloc] initFromString: @"int&"];
    Type *ty = [_types parseType: tokenizer];
    XCTAssert([ty.typeDecl.name isEqualTo: @"int"] && ty.isReference);
}

- (void)testConstPtr {
    CPPTokenizer *tokenizer = [[CPPTokenizer alloc] initFromString: @"char * const"];
    Type *ty = [_types parseType: tokenizer];
    XCTAssert([ty.typeDecl.name isEqualTo: @"char"] && ty.indirectionCount == 1 && ty.qualifiers.count == 0 && ty.constPtr);
}

- (void)testConst {
    CPPTokenizer *tokenizer = [[CPPTokenizer alloc] initFromString: @"const char *"];
    Type *ty = [_types parseType: tokenizer];
    XCTAssert([ty.typeDecl.name isEqualTo: @"char"] && ty.indirectionCount == 1 && ty.qualifiers.count == 1 && [ty.qualifiers[0] isEqualTo: @"const"]);
}

- (void)testGenericPtr {
    CPPTokenizer *tokenizer = [[CPPTokenizer alloc] initFromString: @"std::vector<int *>"];
    Type *ty = [_types parseType: tokenizer];
    XCTAssert([ty.typeDecl.name isEqualTo: @"vector"]);
    XCTAssert(ty.typeParameters.count == 1 && [ty.typeParameters[0].typeDecl.name isEqualTo: @"int"]);
}

- (void)testGenericPtrTwoArgs {
    CPPTokenizer *tokenizer = [[CPPTokenizer alloc] initFromString: @"std::map<int *, int *>"];
    Type *ty = [_types parseType: tokenizer];
    XCTAssert([ty.typeDecl.name isEqualTo: @"map"]);
    XCTAssert(ty.typeParameters.count == 2 && [ty.typeParameters[0].typeDecl.name isEqualTo: @"int"]);
}

- (void)testVoid {
    CPPTokenizer *tokenizer = [[CPPTokenizer alloc] initFromString: @"void abc"];
    Type *ty = [_types parseType: tokenizer];
    XCTAssert([ty.typeDecl.name isEqualTo: @"void"]);
    XCTAssert([[tokenizer nextToken] isEqualTo: @"abc"]);
}

- (void)testInvalidQualifier {
    CPPTokenizer *tokenizer = [[CPPTokenizer alloc] initFromString: @"char * unsigned"];
    Type *ty = [_types parseType: tokenizer];
    XCTAssert(ty == nil);
}

- (void)testInvalidName {
    CPPTokenizer *tokenizer = [[CPPTokenizer alloc] initFromString: @"invalid"];
    Type *ty = [_types parseType: tokenizer];
    XCTAssert(ty == nil);
}

- (void)testInvalidNamespace {
    CPPTokenizer *tokenizer = [[CPPTokenizer alloc] initFromString: @"fake::invalid"];
    Type *ty = [_types parseType: tokenizer];
    XCTAssert(ty == nil);
}

- (void)testInvalidNamespaceContents {
    CPPTokenizer *tokenizer = [[CPPTokenizer alloc] initFromString: @"std::invalid"];
    Type *ty = [_types parseType: tokenizer];
    XCTAssert(ty == nil);
}

- (void)testInvalidSymbolNotSkipped {
    CPPTokenizer *tokenizer = [[CPPTokenizer alloc] initFromString: @"("];
    Type *ty = [_types parseType: tokenizer];
    XCTAssert(ty == nil);
    XCTAssert([[tokenizer nextToken] isEqualTo: @"("]);
}

- (void)testInvalidPointer {
    CPPTokenizer *tokenizer = [[CPPTokenizer alloc] initFromString: @"*char"];
    Type *ty = [_types parseType: tokenizer];
    XCTAssert(ty == nil);
}

- (void)testInvalidReference {
    CPPTokenizer *tokenizer = [[CPPTokenizer alloc] initFromString: @"&char"];
    Type *ty = [_types parseType: tokenizer];
    XCTAssert(ty == nil);
}

- (void)testEmptyString {
    CPPTokenizer *tokenizer = [[CPPTokenizer alloc] initFromString: @"("];
    Type *ty = [_types parseType: tokenizer];
    XCTAssert(ty == nil);
}

- (void)testTilde {
    CPPTokenizer *tokenizer = [[CPPTokenizer alloc] initFromString: @"~Tokenizer"];
    Type *ty = [_types parseType: tokenizer];
    XCTAssert(ty == nil);
}

@end
