//
//  ParserTests.m
//  Alien-Tests
//
//  Created by Paul Warner on 10/9/17.
//  Copyright © 2017 Paul Warner. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "Parser.h"

@interface ParserTests : XCTestCase

@property Parser *parser;

@end

static NSString *classdefn = @"class A {\n%@\n};";

@implementation ParserTests

- (void) setUp {
    [super setUp];
    _parser = [[Parser alloc] init];
}

- (void)testParseEmptyString {
    XCTAssertNoThrow([_parser parseString: @""]);
}

- (void)testDoesntParseLineComment {
    [_parser parseString: @"// class Test {}; \n"];
    XCTAssert([[_parser defns] count] == 0, @"Should not have parsed class");
}

- (void)testDefine {
    [_parser parseString: @"#define TEST 5"];
    XCTAssert([[_parser defines][@"TEST"] isEqualTo: @"5"], @"Define Not Parsed");
}

- (void)testEmptyDefine {
    [_parser parseString: @"#define TEST"];
    XCTAssert([[_parser defines][@"TEST"] isEqualTo: @""]);
}

- (void)testIfdefSkips {
    [_parser parseString: @"#ifdef TEST\n #define TEST #endif"];
    XCTAssert([_parser defines][@"TEST"] == nil);
}

- (void)testIfdefNotSkips {
    [_parser parseString: @"#define TEST 5\n#ifdef TEST\n #define TEST2 \n#endif"];
    XCTAssert([[_parser defines][@"TEST"] isEqualTo: @"5"] && [_parser.defines[@"TEST2"] isEqualTo: @""]);
}

- (void)testDefineTwice {
    XCTAssertThrows([_parser parseString: @"#define TEST 5\n#define TEST 3"]);
}

- (void)testInvalidInclude {
    XCTAssertThrows([_parser parseString: @"#include \"fake\"\n"]);
}

-(void)testDefineLastLine {
    XCTAssertNoThrow([_parser parseString: @"#define A 5"]);
}

- (void)testNestedDefine {
    [_parser parseString:
     @"#ifdef A\n"
     @"#ifndef B\n"
     @"#endif"
     @"#define C\n"
     @"#endif"];
    XCTAssert([_parser defines][@"C"] == nil);
}

- (void)testParseMethod {
    MethodDefinition *m;
    [_parser parseString: [NSString stringWithFormat: classdefn, @"std::string\n dothing();"]];
    m = _parser.defns[@"A"].methods[0];
    XCTAssert([m.returnType isEqualTo: @"std::string"]);
    XCTAssert(m.arguments.count == 0);
    XCTAssert([m.name isEqualTo: @"dothing"]);
}

- (void)testNestedClass {
    [_parser parseString: [NSString stringWithFormat: classdefn, @"class B {};"]];
    XCTAssert([_parser defns].count == 2);
}


@end
