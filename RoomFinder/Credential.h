//
//  Credential.h
//  RoomFinder
//

#import <Foundation/Foundation.h>

@interface Credential : NSObject

/**
 *  The username and password are used to save the credential you input to handle the challenge
 */
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *password;

/**
 *  Returns the singleton Instance of the Credential class.
 *  Method should be called when you need to access an instantiated Credential singleton.
 *  @return A shared Credential singleton object
 */
+(instancetype)clientInstance;
@end
