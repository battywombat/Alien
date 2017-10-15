//
//  Alien_Tests.m
//  Alien-Tests
//
//  Created by Paul Warner on 10/9/17.
//  Copyright © 2017 Paul Warner. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "CPPTokenizer.h"

@interface TokenizerTests : XCTestCase

-(void) testTokens: (CPPTokenizer *)tokenizer shouldEqual: (NSArray<NSString *> *)tokens;

@end

@implementation TokenizerTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testNumbersAndLetters {
    CPPTokenizer *tokenizer = [[CPPTokenizer alloc] initFromString: @"aaa4 25"];
    id tokens = @[ @"aaa4", @"25"];
    [self testTokens: tokenizer shouldEqual: tokens];
}

-(void)testNumbersBeforeLetters {
    
    CPPTokenizer *tokenizer = [[CPPTokenizer alloc] initFromString: @"123abc aaa4 25"];
    XCTAssertThrows([tokenizer nextToken], @"Invalid string should throw exception");
}

- (void)testVector {
    CPPTokenizer *tokenizer = [[CPPTokenizer alloc] initFromString: @"std::vector<std::string>"];
    NSArray<NSString *> *tokens = @[ @"std", @"::", @"vector", @"<", @"std", @"::", @"string", @">"];
    [self testTokens: tokenizer shouldEqual: tokens];
}

- (void)testLineComment {
    CPPTokenizer *tokenizer = [[CPPTokenizer alloc] initFromString: @"// one two three \n four five"];
    NSArray<NSString *> *tokens = @ [@"//", @"one", @"two", @"three", @"\n", @"four", @"five"];
    [self testTokens:tokenizer shouldEqual:tokens];
}

- (void)testMultilineComment {
    CPPTokenizer *tokenizer = [[CPPTokenizer alloc] initFromString: @"/* one two \n three */ four"];
    id tokens = @[@"/*", @"one", @"two", @"\n", @"three", @"*/", @"four"];
    [self testTokens: tokenizer shouldEqual: tokens];
}

-(void)testEmptyComment {
    CPPTokenizer *tokenizer = [[CPPTokenizer alloc] initFromString: @"/**/"];
    id tokens = @[@"/*", @"*/"];
    [self testTokens: tokenizer shouldEqual: tokens];
}

- (void)testDivisionAndLineComment {
    CPPTokenizer *tokenizer = [[CPPTokenizer alloc] initFromString: @"// a / b \na / b"];
    id tokens = @[ @"//", @"a", @"/", @"b", @"\n", @"a", @"/", @"b"];
    [self testTokens: tokenizer shouldEqual: tokens];
}

-(void)testSkipUntil {
    CPPTokenizer *tokenizer = [[CPPTokenizer alloc] initFromString: @"// b \n c"];
    id tokens = @[ @"c" ];
    [tokenizer skipUntil: @"\n"];
    [self testTokens: tokenizer shouldEqual: tokens];
}

-(void)testSkipUntilStops {
    CPPTokenizer *tokenizer = [[CPPTokenizer alloc] initFromString: @"// a b c d"];
    XCTAssertNoThrow([tokenizer skipUntil: @"\n"], @"skipUntil not stopping when token missing");
}

-(void)testSkipUntilSkipsFirst {
    CPPTokenizer *tokenizer = [[CPPTokenizer alloc] initFromString: @"// b \n c"];
    id tokens = @[ @"b", @"\n", @"c" ];
    [tokenizer skipUntil: @"//"];
    [self testTokens: tokenizer shouldEqual: tokens];
}

-(void)testSkipUntilEmpty {
    CPPTokenizer *tokenizer = [[CPPTokenizer alloc] initFromString: @""];
    XCTAssert([tokenizer nextToken] == nil, @"Should not create another token somehow.");
}

-(void) testFilter {
    CPPTokenizer *tokenizer = [[CPPTokenizer alloc] initFromString: @"a b /* c */ d"];
    [tokenizer filter: @"/*" to: @"*/"];
    [self testTokens: tokenizer shouldEqual: @[@"a", @"b", @"d"]];
}

-(void) testFilterDuringIteration {
    CPPTokenizer *tokenizer = [[CPPTokenizer alloc] initFromString: @"a b /* c */ d"];
    [tokenizer nextToken];
    [tokenizer filter: @"/*" to: @"*/"];
    [self testTokens: tokenizer shouldEqual: @[@"b", @"d"]];
}

- (void)testTokenizeGeneric {
    CPPTokenizer *tokenizer = [[CPPTokenizer alloc] initFromString: @"std::vector<std::string>"];
    [self testTokens: tokenizer shouldEqual: @[@"std", @"::", @"vector", @"<", @"std", @"::", @"string", @">"]];
}

-(void) testTokens: (CPPTokenizer *)tokenizer shouldEqual: (NSArray<NSString *> *)tokens {
    NSString *actualToken;
    for (id token in tokens) {
        actualToken = [tokenizer nextToken];
        XCTAssert([token isEqualTo: actualToken], @"%@ != %@", token, actualToken);
    }
}

@end
