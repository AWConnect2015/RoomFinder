//
//  Soap.h
//  RoomFinder
//

#import <Foundation/Foundation.h>

@interface Soap : NSObject

/**
 *  Returns the singleton Instance of the Soap class.
 *  Method should be called when you need to access an instantiated Soap singleton.
 *  @return A shared Soap singleton object
 */
+ (instancetype) clientInstance;

/**
 *  getRoomList
 *  Method should be called if you want to get the body of soap message for getRoomList.
 *
 *  @return The body of Soap message for getRoomList
 */
- (NSString *)getRoomList;

/**
 *  getRooms
 *  Method should be called if you want to get the body of soap message for getRooms
 *
 *  @param emailAddr the email address for the location
 *
 *  @return The body of Soap message for getRooms
 */
- (NSString *)getRooms:(NSString *)emailAddr;

/**
 *  getUserAvaliability
 *  Method should be called if you want to get the body of soap message for getUserAvaliability
 *
 *  @param emailArray The list of emails you want to check if they are avaliable
 *  @param startDate  start time
 *  @param endDate    end time
 *  @param duration   seperate the time between start and end time by duration
 *
 *  @return The body of Soap message for getUserAvaliability
 */
- (NSString *)getUserAvaliability:(NSArray *)emailArray startTime:(NSString *)startDate endTime:(NSString *)endDate duration:(NSInteger)duration;

/**
 *  setServer
 *  Method should be called when you want to set the URL of the request
 *  @param server server URL
 */
- (void)setServer:(NSString *)server;

/**
 *  getServer
 *
 *  @return server url
 */
- (NSString *)getServer;
@end
