//
//  HMCache.h
//  PxePlayerApi
//
//  Created by Satyanarayana on 14/07/13.
//  Copyright (c) 2013 Pearson. All rights reserved.
//


@interface HMCache : NSObject

/**
 This method would be called to remove all the cached files from local file system and resets the all User defaults 
 @see NSUserDefaults
 */
+(void)resetCache;

/**
 This method would be called to store data on the local cache with key for identity of the cached file
 @param NSData , data which need to be stored
 @param NSString , key which required to identify the cached data in the local file system
 */
+(void)setObject:(NSData*)data forKey:(NSString*)key;

/**
 This method would be called to retrieve the cached data from the local file system
 @param NSString, key which required to to identify the cached data
 */
+(id)objectForKey:(NSString*)key;

/**
 Remove the particular cached data from the file system using key
 @param NSString, key which need to be identify the cached data to be deleted
 */
+(void)removeObject:(NSString*)key;

/**
 This method would be called to delete expired cached data
 */
+(void)clearOldFiles;

/**
 This method would be called to to create sub directory in to the HM cache directory
 @param NSString , dirName which need to be assigned as a directory name
 @return NSString, returns the created sub directory path
 */
+(NSString*) createCacheSubDirectory:(NSString*)dirName;

/**
 This method would be called to to create sub directory in to the HM cache directory
 @param NSString , dirName which need to be assigned as a directory name
 @return NSString, returns the created directory path
 */
+(NSString*) createDirectory:(NSString*)dirName;

/**
 Removes the directory from the cache directory
 @param NSString , dirName is a name of the directory which required to identify the directory location
 */
+(BOOL) removeDirectory:(NSString*)dirName;

/**
 This method would be called to store data on the specified file path with key for identity of the cached file
 @param NSData , data which need to be stored
 @param NSString , key which required to identify the cached data in the local file system
 @param NSString , pathName which required to store the file in specifi location
 */
+(void)setObject:(NSData *)data forKey:(NSString *)key withNewPath:(NSString*)pathName;

/**
 This method would be called to retrieve the cached data from the specified file path in the local file system
 @param NSString, key which required to to identify the cached data
 @param NSString, path which required to to identify the cached path
 */
+ (NSData*) objectForKey:(NSString*)key withPath:(NSString*)path;

/**
 Remove the cached sub directory and it's contents
 @param NSString, dirName which need to be identify the locationo of the directory
 */
+(BOOL) removeCacheSubDirectory:(NSString*)dirName;

@end
