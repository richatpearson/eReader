//
//  NTBook.m
//  NTApi
//
//  Created by Swamy Manju R on 02/07/13.
//  Copyright (c) 2013 Pearson. All rights reserved.
//


#import "PxePlayerBook.h"

@implementation PxePlayerBook

-(id)init
{
    self = [super init];
    if(self) {        
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [self init])
    {
        self.lastAccessTs = [decoder decodeObjectForKey:@"lastAccessTs"];
        self.subject = [decoder decodeObjectForKey:@"subject"];
        self.publisher = [decoder decodeObjectForKey:@"publisher"];
        self.creator = [decoder decodeObjectForKey:@"creator"];
        self.date = [decoder decodeObjectForKey:@"date"];
        self.language = [decoder decodeObjectForKey:@"language"];
        self.b_description = [decoder decodeObjectForKey:@"description"];
        self.pageURLS = [decoder decodeObjectForKey:@"pageUrls"];
        self.bookUUID = [decoder decodeObjectForKey:@"bookUUID"];
        self.title = [decoder decodeObjectForKey:@"title"];
        self.expirationDate = [decoder decodeObjectForKey:@"expirationDate"];
        self.author = [decoder decodeObjectForKey:@"author"];
        self.copyrightInfo = [decoder decodeObjectForKey:@"copyrightinfo"];
        self.thumbUrl = [decoder decodeObjectForKey:@"thumbUrl"];
        self.edition = [decoder decodeObjectForKey:@"edition"];
        self.indexId = [decoder decodeObjectForKey:@"indexId"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.lastAccessTs forKey:@"lastAccessTs"];
    [encoder encodeObject:self.subject forKey:@"subject"];
    [encoder encodeObject:self.publisher forKey:@"publisher"];
    [encoder encodeObject:self.creator forKey:@"creator"];
    [encoder encodeObject:self.date forKey:@"date"];
    [encoder encodeObject:self.language forKey:@"language"];
    [encoder encodeObject:self.b_description forKey:@"description"];
    [encoder encodeObject:self.pageURLS forKey:@"pageUrls"];
    [encoder encodeObject:self.bookUUID forKey:@"bookUUID"];
    [encoder encodeObject:self.title forKey:@"title"];
    [encoder encodeObject:self.expirationDate forKey:@"expirationDate"];
    [encoder encodeObject:self.author forKey:@"author"];
    [encoder encodeObject:self.copyrightInfo forKey:@"copyrightinfo"];
    [encoder encodeObject:self.thumbUrl forKey:@"thumbUrl"];
    [encoder encodeObject:self.edition forKey:@"edition"];
    [encoder encodeObject:self.indexId forKey:@"indexId"];
}

-(void)dealloc
{
    self.lastAccessTs   = nil;
    self.subject        = nil;
    self.publisher      = nil;
    self.creator        = nil;
    self.date           = nil;
    self.language       = nil;
    self.b_description  = nil;
    self.pageURLS       = nil;
    self.bookUUID       = nil;
    self.title          = nil;
    self.expirationDate = nil;
    self.author         = nil;
    self.copyrightInfo  = nil;
    self.thumbUrl       = nil;
    self.edition        = nil;
    self.indexId        = nil;
}

@end
