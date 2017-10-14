//
//  Alien.m
//  Alien
//
//  Created by Paul Warner on 10/2/17.
//  Copyright © 2017 Paul Warner. All rights reserved.
//


#import "Alien.h"
#import "Parser.h"

@implementation Alien

-(int) createFileInterface: (NSString *) file
{
    Parser *parser = [[Parser alloc] init];
    [parser parseFile: file];
    return 0;
}

-(int) createInterface: (NSString *) file
{
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL isDir;
    if(![fm fileExistsAtPath: file isDirectory: &isDir]) {
        return 1;
    }
    if (isDir) {
        NSError *err;
        NSArray<NSString *> *files = [fm contentsOfDirectoryAtPath:file error: &err];
        for(id path in files) {
            [fm fileExistsAtPath: path isDirectory:&isDir];
            if (!isDir && [self createFileInterface: path]) {
                return 1;
            }
        }
        return 0;
    } else {
        return [self createFileInterface: file];
    }

}

@end
