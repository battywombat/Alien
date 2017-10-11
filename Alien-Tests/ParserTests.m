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

@end

@implementation ParserTests

- (void)testDoesntParseLineComment {
    Parser *p = [[Parser alloc] init];
    [p parseString: @"// class Test {}; \n"];
    XCTAssert([[p defns] count] == 0, @"Should not have parsed class");
}

@end
