//
//  RFURLSession.h
//  RoomFinder
//

#import <Foundation/Foundation.h>

@interface RFURLSession : NSObject

/**
 @enum ErrorCode
 @brief The specific type of error.
 */
enum ErrorCode {
    RFLoginCanceled = 2000,
    RFInvalidCredential,
    RFNeedCredential
};

/**
 *  sendSynchronousRequest
 *
 *  Performs an synchronous load of the given request.
 *  When the request has completed or failed, the block will be executed.
 *
 *  @param request The request to load
 *  @param block   A block which receives the results of the resource load.
 *
 *  @return The recieved data
 */
- (NSData *)sendSynchronousRequest:(NSURLRequest *)request completionBlock:(void(^)(NSData *data, NSURLResponse *response, NSError *error))block;

@end
