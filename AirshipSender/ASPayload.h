//
//  ASPayload.h
//  AirshipSender
//
//  Created by Christopher Bess on 6/22/12.
//  Copyright (c) 2012 C. Bess. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ASPayload : NSObject
@property (nonatomic, copy) NSNumber *badge;
@property (nonatomic, strong) NSMutableArray *deviceTokens;
@property (nonatomic, strong) NSMutableArray *alias;
@property (nonatomic, copy) NSString *alert;
@property (nonatomic, copy) NSString *sound;

- (NSString *)JSONFormattedString;
- (NSString *)JSONString;
- (void)reset;
@end
