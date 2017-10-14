//
//  Stack.h
//  Alien
//
//  Created by Paul Warner on 10/13/17.
//  Copyright © 2017 Paul Warner. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Stack<T> : NSObject
{
    @private
    NSMutableArray *_data;
}

-(id)init;

-(void) push : (T) obj;

-(T) pop;

-(T) peek;

-(NSUInteger) count;

@end
