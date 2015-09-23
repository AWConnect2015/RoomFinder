//
//  ConfigProfile.h
//  RoomFinder
//

#import <Foundation/Foundation.h>

/**
 *  Get the configuration profile from console.
 */
@interface ConfigProfile : NSObject

/**
 *  The serverURL object will contain the server url set as configuration on console by default.
 */
@property (nonatomic) NSString *serverURL;

/**
 *  The enableCopyPasteAndCut boolean will be set as configuration on console
 *  used as a flag to enable/disable the copy/paste/cut
 */
@property (nonatomic) bool enableCopyPasteAndCut;


/**
 *  Returns the singleton Instance of the ConfigProfile class.
 *  Method should be called when you need to access an instantiated ConfigProfile singleton.
 *  @return A shared ConfigProfile singleton object
 */
+ (ConfigProfile *)clientInstance;


/**
 *  Set the property serverURL and enableCopyPasteAndCut
 *  Method should be called when you want to get the configuration from servel and set the property
 */
- (void)setServerConfig;
@end
