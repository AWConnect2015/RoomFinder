//
//  Credential.m
//  RoomFinder
//

#import "Credential.h"

static Credential *clientInstance = nil;

@implementation Credential
+(instancetype)clientInstance{
    static dispatch_once_t onceToken;
    static Credential *clientInstance = nil;
    dispatch_once( &onceToken, ^{
        clientInstance = [[self alloc] init];
    });
    
    return clientInstance;
}
@end
