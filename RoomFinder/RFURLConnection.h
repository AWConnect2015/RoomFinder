//
//  RFURLConnection.h
//  RoomFinder
//
//  Created by Jing Wang on 8/12/15.
//  Copyright (c) 2015 Jing Wang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RFURLConnection : NSObject
@property (nonatomic, strong) id delegate;

- (NSData *)sendSynchronousRequest:(NSURLRequest *)request completionBlock:(void(^)(NSData *data, NSURLResponse *response, NSError *error))block;

@end

