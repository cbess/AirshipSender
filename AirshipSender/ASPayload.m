//
//  ASPayload.m
//  AirshipSender
//
//  Created by Christopher Bess on 6/22/12.
//  Copyright (c) 2012 C. Bess. All rights reserved.
//

#import "ASPayload.h"

static NSString * const kSendTypeDeviceURLString = @"https://go.urbanairship.com/api/push/";
static NSString * const kSendTypeBroadcastURLString = @"https://go.urbanairship.com/api/push/broadcast/";

@implementation ASPayload
@synthesize deviceTokens = _deviceTokens;
@synthesize alert;
@synthesize alias = _alias;
@synthesize badge;
@synthesize sound;
@synthesize sendType = _sendType;

- (id)init
{
    self = [super init];
    if (self) 
    {
        self.sendType = ASPayloadSendTypeDevice;
    }
    return self;
}

#pragma mark - Properties

- (NSMutableArray *)deviceTokens
{
    if (_deviceTokens == nil)
        _deviceTokens = [NSMutableArray array];
    
    return _deviceTokens;
}

- (NSMutableArray *)alias
{
    if (_alias == nil)
        _alias = [NSMutableArray array];
    
    return _alias;
}

#pragma mark - JSON

- (NSDictionary *)JSONObject
{
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithCapacity:5];
    NSMutableDictionary *apsInfo = [NSMutableDictionary dictionaryWithCapacity:3];
    
    [info setObject:apsInfo forKey:@"aps"];
    
    if (self.sendType == ASPayloadSendTypeDevice)
    {
        // root
        if (self.deviceTokens.count)
            [info setObject:self.deviceTokens forKey:@"device_tokens"];
        
        if (self.alias.count)
            [info setObject:self.alias forKey:@"aliases"];
    }
    
    // aps
    if (self.badge.intValue)
        [apsInfo setObject:self.badge forKey:@"badge"];
    
    if (self.alert.length)
        [apsInfo setObject:self.alert forKey:@"alert"];
    
    if (self.sound.length)
        [apsInfo setObject:self.sound forKey:@"sound"];
    
    return info;
}

- (NSString *)JSONString
{
    NSDictionary *info = [self JSONObject];
    
    // build the json
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:info options:0 error:&error];
    
    if (error)
        return nil;
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}

- (NSString *)JSONFormattedString
{
    // build the json
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[self JSONObject] options:NSJSONWritingPrettyPrinted error:&error];
    
    if (error)
        return nil;
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}

#pragma mark - Misc

- (void)reset
{
    [self.deviceTokens removeAllObjects];
    [self.alias removeAllObjects];
    self.sound = nil;
    self.alert = nil;
    self.badge = nil;
}

#pragma mark - Network

- (void)sendPayloadWithCompletionHandler:(ASPayloadSendCompletionBlock)handler
{
    [self sendPayloadForType:self.sendType completionHandler:handler];
}

- (void)sendPayloadForType:(ASPayloadSendType)sendType completionHandler:(ASPayloadSendCompletionBlock)handler
{
    NSString *sendURLString = (sendType == ASPayloadSendTypeDevice ? kSendTypeDeviceURLString : kSendTypeBroadcastURLString);
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:sendURLString]];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
    
    NSString *jsonString = self.JSONString;
    
    [request setValue:[NSString stringWithFormat:@"%d", jsonString.length] forHTTPHeaderField:@"Content-length"];
    
    [request setHTTPBody:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    // send it!
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:handler];
}
@end
