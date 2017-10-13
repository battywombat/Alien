//
//  CPPTokenizer.h
//  Alien
//
//  Created by Paul Warner on 10/2/17.
//  Copyright © 2017 Paul Warner. All rights reserved.
//

@interface CPPTokenizer : NSObject
{
    @private NSString *_data;
    
    @private NSUInteger _index;
    
    @private NSUInteger _prev;

    @private int _lineNum;

    @private int _colNum;

    @private BOOL _inLineComment;
    @private BOOL _inMultilineComment;
    @private BOOL _opWasLast;
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
