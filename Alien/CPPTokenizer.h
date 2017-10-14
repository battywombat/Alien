//
//  CPPTokenizer.h
//  Alien
//
//  Created by Paul Warner on 10/2/17.
//  Copyright © 2017 Paul Warner. All rights reserved.
//

@interface CPPTokenizer : NSObject
{
    @private
    NSString *_data;
    NSUInteger _index;
    NSUInteger _prev;
    int _lineNum;
    int _colNum;
    BOOL _inLineComment;
    BOOL _inMultilineComment;
    BOOL _opWasLast;
}

-(id)initFromString: (NSString *) s;

-(id)initFromFile: (NSString *) fp;

-(NSString *)nextToken;

-(void)throwException: (NSUInteger) idx;

-(int)getSymLength: (NSString *)next;

-(int)getSymLengthInSet: (NSCharacterSet *)set exculding: (NSCharacterSet *)exclude;

-(int)getSymLengthExculdingSet: (NSCharacterSet *)set;

-(void)rewind;

-(void)reset;

-(void)skipUntil: (NSString *)end;

-(void)filter: (NSString *)from to: (NSString *) end;

@end
