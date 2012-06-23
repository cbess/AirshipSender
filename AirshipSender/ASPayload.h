//
//  ASPayload.h
//  AirshipSender
//
//  Created by Christopher Bess on 6/22/12.
//  Copyright (c) 2012 C. Bess. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    ASPayloadSendTypeDevice,
    ASPayloadSendTypeBroadcast
} ASPayloadSendType;

typedef void(^ASPayloadSendCompletionBlock)(NSURLResponse *response, NSData *data, NSError *error);

@interface ASPayload : NSObject
@property (nonatomic, copy) NSNumber *badge;
@property (nonatomic, strong) NSMutableArray *deviceTokens;
@property (nonatomic, strong) NSMutableArray *alias;
@property (nonatomic, copy) NSString *alert;
@property (nonatomic, copy) NSString *sound;
@property (nonatomic, assign) ASPayloadSendType sendType;

- (NSString *)JSONFormattedString;
- (NSString *)JSONString;
- (void)reset;

/**
 * Sends the payload using the currently set sendType value.
 */
- (void)sendPayloadWithCompletionHandler:(ASPayloadSendCompletionBlock)handler;

/**
 * Sends the payload to the Urban Airship server for the specified type.
 */
- (void)sendPayloadForType:(ASPayloadSendType)sendType completionHandler:(ASPayloadSendCompletionBlock)handler;
@end
