//
//  RFURLConnection.m
//  RoomFinder
//
//  Created by Jing Wang on 8/12/15.
//  Copyright (c) 2015 Jing Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RFURLConnection.h"
#import "Credential.h"

@interface RFURLConnection()<NSURLConnectionDataDelegate>{
    
    void (^_completionBlock)(NSData *data, NSURLResponse *response, NSError *error);
}

@property (nonatomic) NSMutableData *recievedData;
@property (nonatomic) NSError *error;
@property (nonatomic) NSURLResponse *response;

@end

static BOOL getCredential;
static BOOL cancel;
static NSInteger maxAttempt;

@implementation RFURLConnection

- (NSData *)sendSynchronousRequest:(NSURLRequest *)request completionBlock:(void(^)(NSData *data, NSURLResponse *response, NSError *error))block{
    getCredential = NO;
    cancel = NO;
    maxAttempt = INT_MAX;
    _completionBlock = block;
    [NSURLConnection connectionWithRequest:request delegate:self];
    //CFRunLoopRun();
    return _recievedData;
}

#pragma mark - NSURLConnectionDelegate
- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    NSLog(@"didReceiveAuthenticationChallenge...%ld", (long)[challenge previousFailureCount]);
    if ([challenge previousFailureCount] == 0) {
        [[Credential clientInstance] setUsername:@""];
        [[Credential clientInstance] setPassword:@""];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        alert.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
        alert.transform = CGAffineTransformMakeScale(1.0, 0.75);
        [alert show];
    }
    
    if (getCredential) {
        maxAttempt = [challenge previousFailureCount] + 1;
        NSLog(@"max attempt...%ld", (long)maxAttempt);
        getCredential = NO;
    }
    if (!cancel) {
        if ([challenge previousFailureCount] < maxAttempt) {
            NSURLCredential *newCredential;
            newCredential = [NSURLCredential credentialWithUser:[[Credential clientInstance] username]
                                                       password:[[Credential clientInstance] password]
                                                    persistence:NSURLCredentialPersistenceNone];
            [[challenge sender] useCredential:newCredential forAuthenticationChallenge:challenge];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Invalid Credential!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            alert.alertViewStyle = UIAlertViewStyleDefault;
            [alert show];
        }
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"didReceiveResponse...");
    _response = response;
    _recievedData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    NSLog(@"didReceiveData...");
    [_recievedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"didFailWithError...");
    _error = error;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    alert.alertViewStyle = UIAlertViewStyleDefault;
    [alert show];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"connectionDidFinishLoading...");
    _completionBlock( _recievedData, _response, _error );
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    //NSLog(@"Alert View dismissed with button at index %ld",(long)buttonIndex);
    if (buttonIndex == 1) {
        [[Credential clientInstance] setUsername:[alertView textFieldAtIndex:0].text];
        [[Credential clientInstance] setPassword:[alertView textFieldAtIndex:1].text];
        getCredential = YES;
    } else if (buttonIndex == 0){
        [[Credential clientInstance] setUsername:@""];
        [[Credential clientInstance] setPassword:@""];
        cancel = YES;
    }
}

@end
