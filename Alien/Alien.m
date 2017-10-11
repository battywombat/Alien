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
    BOOL is_dir;
    if(![fm fileExistsAtPath: file isDirectory: &is_dir]) {
        return 1;
    }
    if (is_dir) {
        NSError *err;
        NSArray<NSString *> *files = [fm contentsOfDirectoryAtPath:file error: &err];
        for(id path in files) {
            [fm fileExistsAtPath: path isDirectory:&is_dir];
            if (!is_dir && [self createFileInterface: path]) {
                return 1;
            }
        }
        return 0;
    } else {
        return [self createFileInterface: file];
    }

}

@end
