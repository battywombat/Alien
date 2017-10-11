//
//  main.m
//  Alien
//
//  Created by Paul Warner on 10/2/17.
//  Copyright © 2017 Paul Warner. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Alien.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSArray *arguments = [[NSProcessInfo processInfo] arguments];
        Alien *alien = [[Alien alloc] init];
        for (int i = 1; i < [arguments count]; i++) {
            [alien createInterface: arguments[i]];
        }    }
    return 0;
}
