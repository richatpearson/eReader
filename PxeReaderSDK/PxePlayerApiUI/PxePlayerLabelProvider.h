//
//  PxePlayerLabelProvider.h
//  PxeReader
//
//  Created by Tomack, Barry on 7/21/15.
//  Copyright (c) 2015 Pearson. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PxePlayerLabelProviderDelegate <NSObject>

@required

- (NSString *) provideLabelForPageWithPath:(NSString*)relativePath;

@end

@interface PxePlayerLabelProvider : NSObject

@property (nonatomic, weak) id <PxePlayerLabelProviderDelegate> delegate;

- (instancetype) initWithDelegate:(id <PxePlayerLabelProviderDelegate>)delegate;

- (NSString*) getLabelForPageWithPath:(NSString*)relativePath;

@end

