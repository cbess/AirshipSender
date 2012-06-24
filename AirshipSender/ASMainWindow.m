//
//  ASMainWindow.m
//  AirshipSender
//
//  Created by Christopher Bess on 6/22/12.
//  Copyright (c) 2012 C. Bess. All rights reserved.
//

#import "ASMainWindow.h"
#import "ASPayload.h"

@interface ASMainWindow () <NSTextFieldDelegate>
@property (weak) IBOutlet NSTextField *aliasTextField;
@property (weak) IBOutlet NSTextField *deviceTokenTextField;
@property (weak) IBOutlet NSTextField *badgeTextField;
@property (weak) IBOutlet NSTextField *alertTextField;
@property (weak) IBOutlet NSTextField *soundTextField;
@property (strong) IBOutlet NSTextView *payloadTextView;
@property (weak) IBOutlet NSView *formFieldsView;
@property (weak) IBOutlet NSProgressIndicator *progressIndicator;
@property (weak) IBOutlet NSTextField *appKeyTextField;
@property (weak) IBOutlet NSTextField *masterSecretTextField;
@property (nonatomic, strong) ASPayload *payload;
@property (nonatomic, assign) BOOL formattedString;
@property (nonatomic, assign) BOOL isBroadcast;
@end

@implementation ASMainWindow
@synthesize aliasTextField;
@synthesize deviceTokenTextField;
@synthesize badgeTextField;
@synthesize alertTextField;
@synthesize soundTextField;
@synthesize payloadTextView;
@synthesize formFieldsView;
@synthesize progressIndicator;
@synthesize appKeyTextField;
@synthesize masterSecretTextField;
@synthesize payload;
@synthesize formattedString;
@synthesize isBroadcast;

- (void)awakeFromNib
{
    self.payload = [ASPayload new];
    self.payloadTextView.font = [NSFont fontWithName:@"Monaco" size:16];
    self.formattedString = YES;
    self.isBroadcast = NO;
}

- (void)buildPayload
{
    [self.payload reset];
    
    if (!self.isBroadcast)
    {
        if (self.deviceTokenTextField.stringValue.length)
            [self.payload.deviceTokens addObject:self.deviceTokenTextField.stringValue];
        if (self.deviceTokenTextField.stringValue.length)
            [self.payload.alias addObject:self.aliasTextField.stringValue];
    }
    self.payload.sound = self.soundTextField.stringValue;
    self.payload.alert = self.alertTextField.stringValue;
    self.payload.badge = [NSNumber numberWithInt:self.badgeTextField.intValue];
}

- (void)buildPayloadAndUpdateUI
{
    [self buildPayload];
    
    self.payloadTextView.string = self.formattedString ? [self.payload JSONFormattedString] : [self.payload JSONString];
}

#pragma mark - Events

- (IBAction)sendTypeChanged:(id)sender 
{
    self.isBroadcast = !self.isBroadcast;
    self.payload.sendType = (self.isBroadcast ? ASPayloadSendTypeBroadcast : ASPayloadSendTypeDevice);
    
    [self buildPayloadAndUpdateUI];
}

- (IBAction)formatButtonClicked:(id)sender
{
    self.formattedString = !self.formattedString;
    
    [self buildPayloadAndUpdateUI];
}

- (IBAction)sendItClicked:(id)sender 
{
    NSButton *button = sender;
    [button setEnabled:NO];
    [self.progressIndicator startAnimation:nil];
    
    // send request
    [self.payload sendPayloadWithCompletionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        // check response
        if (error)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSAlert *alert = [NSAlert alertWithError:error];
                [alert runModal];
            });
        }
        
        if (data)
        {
            // inform user
            NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            dispatch_async(dispatch_get_main_queue(), ^{
                NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"Response", nil) 
                                                 defaultButton:NSLocalizedString(@"OK", nil) 
                                               alternateButton:nil 
                                                   otherButton:nil 
                                     informativeTextWithFormat:dataString];
                [alert runModal];
            });
        }
        
        // update UI
        [button setEnabled:YES];
        [self.progressIndicator stopAnimation:nil];
    }];
}

#pragma mark - NSTextFieldDelegate

- (void)controlTextDidChange:(NSNotification *)obj
{
    [self buildPayloadAndUpdateUI];
}

@end
