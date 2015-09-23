//
//  RFURLSession.m
//  RoomFinder
//

#import <UIKit/UIKit.h>
#import "RFURLSession.h"
#import "Credential.h"
#import <AWSDK/AWController.h>

@interface RFURLSession()<NSURLSessionDataDelegate> {
    void (^_completionBlock)(NSData *data, NSURLResponse *response, NSError *error);
}

@property (nonatomic) NSMutableData *recievedData;
@property (nonatomic) NSError *error;
@property (nonatomic) NSURLResponse *response;

@end

@implementation RFURLSession

- (NSData *)sendSynchronousRequest:(NSURLRequest *)request completionBlock:(void(^)(NSData *data, NSURLResponse *response, NSError *error))block {

    _completionBlock = block;
    
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *theSession = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [theSession dataTaskWithRequest:request completionHandler:_completionBlock];
    [task resume];

    return _recievedData;
}

/**
 *  URLSession:session:dataTask:data
 *
 *  NSURLSessionDataDelegate method
 *  Sent when data is available for the delegate to consume.
 *
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data{
    [_recievedData appendData:data];
}

/**
 *  URLSession:session:dataTask:didRecieveResponse
 *
 *  NSURLSessionDataDelegate method
 *  the task has received a response and no further messages will be
 *  received until the completion block is called.
 *
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    _recievedData = [[NSMutableData alloc] init];
    completionHandler(NSURLSessionResponseAllow);
}

/**
 *  URLSession:session:task:didRecieveChallenge
 *
 *  NSURLSessionDataDelegate method
 *  The task has received a request specific authentication challenge.
 *
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler
{
    NSError *error;
    if ( [[AWController clientInstance] canHandleProtectionSpace:challenge.protectionSpace withError:&error]) {
        
        if ([[AWController clientInstance] handleChallengeForURLSessionChallenge:challenge completionHandler:^(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential) {
            completionHandler(disposition, credential);
        }]) {
            NSLog(@"Challenge handled successfully");
        } else {
            NSLog(@"handleChallengeForURLSessionChallenge failed.");
            NSMutableDictionary *details = [NSMutableDictionary dictionary];
            [details setValue:@"Challenge handled Failed"  forKey:NSLocalizedDescriptionKey];
            NSError *error = [NSError errorWithDomain:@"Warning" code:RFInvalidCredential userInfo:details];
            _completionBlock(nil,nil,error);
        }
        
    } else {
            if ([challenge previousFailureCount] < 1) {
                NSURLCredential *newCredential;
                newCredential = [NSURLCredential credentialWithUser:[[Credential clientInstance] username]
                                                       password:[[Credential clientInstance] password]
                                                    persistence:NSURLCredentialPersistenceNone];
                completionHandler(NSURLSessionAuthChallengeUseCredential, newCredential);
            } else {
                NSMutableDictionary *details = [NSMutableDictionary dictionary];
                [details setValue:@"Invalid Credential!"  forKey:NSLocalizedDescriptionKey];
                if ([[Credential clientInstance] username] == nil && [[Credential clientInstance] password] == nil) {
                    NSError *error = [NSError errorWithDomain:@"Warning" code:RFNeedCredential userInfo:details];
                    _completionBlock(nil,nil,error);
                } else {
                    NSError *error = [NSError errorWithDomain:@"Warning" code:RFInvalidCredential userInfo:details];
                    _completionBlock(nil,nil,error);
                }
                completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
            }
    }
}

/**
 *  URLSession:session:task:error
 *
 *  NSURLSessionDataDelegate method
 *  Sent as the last message related to a specific task.  Error may be
 *  nil, which implies that no error occurred and this task is complete.
 *
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    if (error == nil) {
        NSLog(@"no error");
        _completionBlock(_recievedData, _response, error);
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:[error.userInfo objectForKey:@"NSLocalizedDescription"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        alert.alertViewStyle = UIAlertViewStyleDefault;
        [alert show];
        [[Credential clientInstance] setUsername:@""];
        [[Credential clientInstance] setPassword:@""];
    }
}


@end
