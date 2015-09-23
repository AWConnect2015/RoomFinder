//
//  ConfigProfile.m
//  RoomFinder
//

#import "ConfigProfile.h"

/**
 *  The Managed app configuration dictionary pushed down from an MDM server are stored in this key.
 */
static NSString *const kConfiguratonKey = @"com.apple.configuration.managed";

/**
 *  This application allows for a server url and copy/paste enable switch to be configured via MDM
 *  Application developers should document feedback dictionary keys, including data types and valid value ranges.
 */
static NSString *const kConfigurationServerURLKey = @"server";
static NSString *const kEnableCopyPasteAndCut = @"enableCopyPasteAndCut";

static ConfigProfile *clientInstance = nil;

@implementation ConfigProfile

+ (ConfigProfile *)clientInstance {
    static dispatch_once_t onceToken;
    static ConfigProfile *clientInstance = nil;
    
    dispatch_once(&onceToken, ^{
        clientInstance = [[self alloc] init];
    });
    
    return clientInstance;
}

- (void)setServerConfig {
    NSDictionary *serverConfig = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kConfiguratonKey];
    
    NSString *serverURLString = serverConfig[kConfigurationServerURLKey];
    if (serverURLString && [serverURLString isKindOfClass:[NSString class]]) {
        _serverURL = serverURLString;
    } else {
        _serverURL = @"";
    }
    
    if ([serverConfig[kEnableCopyPasteAndCut] isEqual: @(YES)]) {
        _enableCopyPasteAndCut = true;
    } else {
        _enableCopyPasteAndCut = false;
    }
}
@end
