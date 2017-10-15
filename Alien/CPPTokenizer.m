//
//  CPPTokenizer.m
//  Alien
//
//  Created by Paul Warner on 10/2/17.
//  Copyright © 2017 Paul Warner. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CPPTokenizer.h"

@implementation CPPTokenizer

-(id)initFromString: (NSString *) s
{
    _prev = -1;
    _data = s;
    _inLineComment = false;
    _inMultilineComment = false;
    return self;
}

-(id)initFromFile: (NSString *) fp
{
    return [self initFromString: [NSString stringWithContentsOfFile: fp usedEncoding: nil error: nil]];
}

-(NSString *)nextToken
{
    NSString *tok;
    int symlen;
    NSMutableCharacterSet *operators = [[NSMutableCharacterSet alloc] init];
    [operators addCharactersInString: @"()[];~%^{}."];
    NSMutableCharacterSet *symbols = [[NSMutableCharacterSet alloc] init];
    [symbols addCharactersInString: @"_"];
    [symbols formUnionWithCharacterSet: [NSCharacterSet alphanumericCharacterSet]];
    while (_index < _data.length && [[NSCharacterSet whitespaceCharacterSet] characterIsMember: [_data characterAtIndex: _index]]) {
        _index++;
    }
    if (_index == _data.length) {
        return nil;
    }
    if ([_data characterAtIndex: _index] == L'/') {
        symlen = [self getSymLength: @"/*"];
        if ([_data characterAtIndex: _index+1] == L'*') {
            _inMultilineComment = true;
        }
        else if ([_data characterAtIndex: _index+1] == L'/') {
            _inLineComment = true;
        }
    }
    else if ([_data characterAtIndex: _index] == L'*') {
        symlen = [self getSymLength: @"/"];
        if (symlen > 0) {
            _inMultilineComment = false;
        }
    }
    else if ([_data characterAtIndex: _index] == L'\n') {
        symlen = 1;
        _lineNum += 1;
        _colNum = 0;
        _inMultilineComment = false;
    }
    else if ([_data characterAtIndex: _index] == L'=') {
        symlen = [self getSymLength: @"="];
    }
    else if ([_data characterAtIndex: _index] == L'|') {
        symlen = [self getSymLength: @"|"];
    }
    else if ([_data characterAtIndex: _index] == L'+') {
        symlen = [self getSymLength: @"+"];
    }
    else if ([_data characterAtIndex: _index] == L'-') {
        symlen = [self getSymLength: @"-"];
    }
    else if ([_data characterAtIndex: _index] == L'!') {
        symlen = [self getSymLength: @"="];
    }
    else if ([_data characterAtIndex: _index] == L':') {
        symlen = [self getSymLength: @":"];
    }
    else if ([_data characterAtIndex: _index] == L'&') {
        symlen = [self getSymLength: @"&"];
    }
    else if ([_data characterAtIndex: _index] == L'<') {
        symlen = [self getSymLength: @"="];
    }
    else if ([_data characterAtIndex: _index] == L'>') {
        symlen = [self getSymLength: @"="];
    }
    else if ([operators characterIsMember: [_data characterAtIndex: _index]]) {
        symlen = 1;
    }
    else if ([_data characterAtIndex: _index] == L'"') {
        NSMutableCharacterSet *s = [[NSMutableCharacterSet alloc] init];
        [s addCharactersInString: @"\""];
        symlen = [self getSymLengthExculdingSet: s] + 1;
    }
    else if ([[NSCharacterSet letterCharacterSet] characterIsMember: [_data characterAtIndex: _index]] || [_data characterAtIndex: _index] == L'_') {
        symlen = [self getSymLengthInSet: symbols exculding: nil];
    }
    else if ([[NSCharacterSet decimalDigitCharacterSet] characterIsMember: [_data characterAtIndex: _index]]) {
        symlen = [self getSymLengthInSet: [NSCharacterSet decimalDigitCharacterSet] exculding: [NSCharacterSet letterCharacterSet]];
    }    else {
        symlen = 1;
    }
    tok = [_data substringWithRange: NSMakeRange(_index, symlen)];
    _prev = _index;
    _index += symlen;
    _colNum += _index;
    return tok;
}

-(void)throwException: (NSUInteger) i
{
    NSException *exception = [NSException
                              exceptionWithName: @"InvalidSyntaxException"
                              reason: [NSString stringWithFormat: @"invalid symbol %c at line: %d col %d", [_data characterAtIndex: i], _lineNum, _colNum]
                              userInfo: nil];
    @throw exception;
}

-(int)getSymLength: (NSString *)next
{
    NSMutableCharacterSet *set = [[NSMutableCharacterSet alloc] init];
    [set addCharactersInString: next];
    return _index < _data.length - 1 && [set characterIsMember: [_data characterAtIndex: _index+1]] ? 2 : 1;
}

-(int)getSymLengthInSet: (NSCharacterSet *)set exculding: (NSCharacterSet *)exclude
{
    int len = 1;
    while (_index+len < _data.length && [set characterIsMember: [_data characterAtIndex: _index+len]]) {
        len++;
    }
    if (exclude != nil && _index+len < _data.length && [exclude characterIsMember: [_data characterAtIndex: _index+len]]) {
        [self throwException: _index+len];
    }
    return len;
}

-(int)getSymLengthExculdingSet: (NSCharacterSet *)set
{
    int len = 1;
    while (_index+len < _data.length && ![set characterIsMember: [_data characterAtIndex: _index+len]]) {
        len++;
    }
    return len;
}

-(void)rewind
{
    if (_prev != -1) {
        _index = _prev;
    }
}

-(void)skipUntil: (NSString *)end
{
    NSString *s;
    while (![ s = [self nextToken] isEqualTo: end] && s != nil)
        ;
}

- (void)filter:(NSString *)from to:(NSString *)end {
    NSUInteger oldIdx = _index, start, finish;
    [self reset];
    NSString *t1, *t2;
    while ((t1 = [self nextToken]) != nil) {
        if ([t1 isEqualTo: from]) {
            start = _index - t1.length;
            while ((t2 = [self nextToken]) != nil && ![t2 isEqualTo: end])
                ;
            finish = _index;
            _data = [_data stringByReplacingCharactersInRange: NSMakeRange(start, finish - start) withString: @""];
            if (finish < oldIdx) {
                oldIdx -= finish - start;
            }
            _index = start;
        }
    }
    _index = oldIdx;
}

- (void)reset { 
    _index = 0;
}

- (void)removeAll:(NSString *)token { 
    NSString *currentToken;
    NSUInteger oldIndex = _index, start, finish;
    [self reset];
    while ((currentToken = [self nextToken]) != nil) {
        if ([currentToken isEqualTo: token]) {
            start = _index - currentToken.length;
            finish = _index;
            _data = [_data stringByReplacingCharactersInRange: NSMakeRange(start, finish - start) withString: @""];
            if (finish < oldIndex) {
                oldIndex -= finish - start;
            }
            _index = start;
        }
    }
    _index = oldIndex;
}

@end
