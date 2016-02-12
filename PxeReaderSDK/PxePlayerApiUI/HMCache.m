//
//  HMCache.m
//  PxePlayerApi
//
//  Created by Satyanarayana on 14/07/13.
//  Copyright (c) 2013 Pearson. All rights reserved.
//
#import <Foundation/Foundation.h>

#import "HMCache.h"

static NSTimeInterval cacheTime =  (double)604800;  // 7 days

@implementation HMCache

+ (void) resetCache {
	[[NSFileManager defaultManager] removeItemAtPath:[HMCache cacheDirectory] error:nil];
}

+ (NSString*) cacheDirectory
{
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cacheDirectory = paths[0];
    cacheDirectory = [cacheDirectory stringByAppendingPathComponent:@"HMCache"];

    return cacheDirectory;
}


+(NSString*) createCacheSubDirectory:(NSString*)dirName
{
    NSString *cacheDir = [[self cacheDirectory] stringByAppendingPathComponent:dirName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:cacheDir]) {
		[fileManager createDirectoryAtPath:cacheDir withIntermediateDirectories:YES attributes:nil error:nil];
	}
    
    return cacheDir;
}

+(NSString*) createDirectory:(NSString*)dirName
{

    
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *cacheDirectory = paths[0];
	cacheDirectory = [cacheDirectory stringByAppendingPathComponent:dirName];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:cacheDirectory])
    {
		if(![fileManager createDirectoryAtPath:cacheDirectory withIntermediateDirectories:YES attributes:nil error:nil]) {
            return @"NO";
        }
	}

    
	return cacheDirectory;
}

+(BOOL) removeDirectory:(NSString*)dirName
{
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *cacheDirectory = paths[0];
    cacheDirectory = [cacheDirectory stringByAppendingPathComponent:dirName];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    if ([fileManager fileExistsAtPath:cacheDirectory]) {
        [fileManager removeItemAtPath:cacheDirectory error:&error];
    }
    
    if(error) {
        return NO;
    }
    
    return YES;
}

+(BOOL) removeCacheSubDirectory:(NSString*)dirName
{
    NSString *cacheDir = [[self cacheDirectory] stringByAppendingPathComponent:dirName];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    if ([fileManager fileExistsAtPath:cacheDir]) {
        [fileManager removeItemAtPath:cacheDir error:&error];
    }
    
    if(error) {
        return NO;
    }
    
    return YES;
}

+(void)setObject:(NSData *)data forKey:(NSString *)key withNewPath:(NSString*)pathName
{
    NSString *fileName = [[self createCacheSubDirectory:pathName] stringByAppendingPathComponent:key];
	NSError *error;
	@try {
		[data writeToFile:fileName options:NSDataWritingAtomic error:&error];
	}
	@catch (NSException * e) {
		//TODO: error handling maybe
	}
}

+ (NSData*) objectForKey:(NSString*)key withPath:(NSString*)path
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString *filename = [[self createCacheSubDirectory:path] stringByAppendingPathComponent:key];
	
	if ([fileManager fileExistsAtPath:filename])
	{
        NSData *data = [NSData dataWithContentsOfFile:filename];
        return data;
	}
    
	return nil;
}

+ (NSData*) objectForKey:(NSString*)key
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString *filename = [self.cacheDirectory stringByAppendingPathComponent:key];
	
	if ([fileManager fileExistsAtPath:filename])
	{
        NSData *data = [NSData dataWithContentsOfFile:filename];
        return data;
	}
    
	return nil;
}

+ (void) setObject:(NSData*)data forKey:(NSString*)key
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString *filename = [self.cacheDirectory stringByAppendingPathComponent:key];
    
	BOOL isDir = YES;
	if (![fileManager fileExistsAtPath:self.cacheDirectory isDirectory:&isDir]) {
		[fileManager createDirectoryAtPath:self.cacheDirectory withIntermediateDirectories:NO attributes:nil error:nil];
	}
	
	NSError *error;
	@try {
		[data writeToFile:filename options:NSDataWritingAtomic error:&error];
	}
	@catch (NSException * e) {
		//TODO: error handling maybe
	}
}

+(void) removeObject:(NSString*)key
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *fileName = [self.cacheDirectory stringByAppendingPathComponent:key];
	if ([fileManager fileExistsAtPath:fileName]) {
        [fileManager removeItemAtPath:fileName error:nil];
    }
}

+(void)clearOldFiles
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
	NSArray *dirContents = [fileManager contentsOfDirectoryAtPath:self.cacheDirectory error:nil];
    
    for (NSString *fileName in dirContents)
    {
        if([fileManager fileExistsAtPath:fileName])
        {
            NSDate *modificationDate = [[fileManager attributesOfItemAtPath:fileName error:nil] objectForKey:NSFileModificationDate];
            if ([modificationDate timeIntervalSinceNow] > cacheTime){
                [fileManager removeItemAtPath:fileName error:nil];
            }
        }
    }
}

@end
