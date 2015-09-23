//
//  Soap.m
//  RoomFinder
//

#import "Soap.h"

@interface Soap()< NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDataDelegate>
@property (strong, nonatomic) NSString *server;
@end

static Soap *clientInstance = nil;

@implementation Soap

+ (instancetype) clientInstance {
    static dispatch_once_t onceToken;
    static Soap *clientInstance = nil;
    dispatch_once(&onceToken, ^{
        clientInstance = [[self alloc] init];
    });
    
    return clientInstance;
}

- (void)setServer:(NSString *)server {
    _server = server;
}

- (NSString *)getServer {
    return _server;
}
-(NSString *)getRoomList {
    NSString *myPathInfo = [[NSBundle mainBundle] pathForResource:@"getRoomList" ofType:@"txt"];
    NSString *soapMessage = [[NSString alloc] initWithContentsOfFile:myPathInfo encoding:NSUTF8StringEncoding error:nil];

    return soapMessage;
}

-(NSString *)getRooms: (NSString *)emailAddr {
    NSString *myPathInfo = [[NSBundle mainBundle] pathForResource:@"getRooms" ofType:@"txt"];
    NSString *messageFormat = [[NSString alloc] initWithContentsOfFile:myPathInfo encoding:NSUTF8StringEncoding error:nil];
    NSString *soapMessage = [NSString stringWithFormat:messageFormat, emailAddr];
    return soapMessage;
}

- (NSString *)getUserAvaliability:(NSArray *)emailArray startTime:(NSString *)startDate endTime:(NSString *)endDate duration:(NSInteger)duration {
    NSString *myPathInfo = [[NSBundle mainBundle] pathForResource:@"mailBoxData" ofType:@"txt"];
    NSString *messageFormat = [[NSString alloc] initWithContentsOfFile:myPathInfo encoding:NSUTF8StringEncoding error:nil];
    NSMutableString *mailBoxData = [[NSMutableString alloc] init];
    for (NSString *obj in emailArray) {
        [mailBoxData appendString:[NSString stringWithFormat:messageFormat, obj]];
    }
    
    myPathInfo = [[NSBundle mainBundle] pathForResource:@"getUserAvaliability" ofType:@"txt"];
    messageFormat = [[NSString alloc] initWithContentsOfFile:myPathInfo encoding:NSUTF8StringEncoding error:nil];
    NSString *soapMessage = [NSString stringWithFormat:messageFormat, mailBoxData, startDate, endDate, duration];
    return soapMessage;
}

@end