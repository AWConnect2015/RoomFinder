//
//  LocationTableViewController.m
//  RoomFinder
//

#import "LocationTableViewController.h"
#import "RoomsTableViewController.h"
#import "LocationTableViewCell.h"
#import "Credential.h"
#import "Soap.h"
#import "RFURLSession.h"
#import "HUDView.h"

@interface LocationTableViewController () <NSXMLParserDelegate>
@property (strong, nonatomic) NSMutableData *recievedData;
@property (strong, nonatomic) HUDView *loadingView;
@end

static NSXMLParser *XMLParser;
static NSMutableString *soapResults;
static NSInteger elementFound;
static NSMutableArray *recievedRooms;
static NSMutableArray *recievedEmails;
static NSMutableArray *recievedAvaliability;
static BOOL didSelectRow;

/**
 @enum parseXML
 @brief valid XML element type
 */
enum parseXML {
    foundelse = 0,
    foundName,
    foundEmail,
    foundAvaliability
};

@implementation LocationTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.topViewController.title = @"Locations";
    CGRect frame = [self.navigationController.navigationBar frame];
    frame.size.height = 34.0f;
    [self.navigationController.navigationBar setFrame:frame];
    didSelectRow = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_loadingView hide];
    _loadingView = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [_locations count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LocationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellOfLocations" forIndexPath:indexPath];
    [self configueCell:cell forIndexPath:indexPath];
    return cell;
}

- (void) configueCell:(LocationTableViewCell *)tableViewCell forIndexPath:(NSIndexPath *)indexPath {
    tableViewCell.location.text = [_locations objectAtIndex:indexPath.row];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (didSelectRow == NO) {
        [self sendRequestGetRooms:[_emails objectAtIndex:indexPath.row]];
        didSelectRow = YES;
        
        _loadingView = [[HUDView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width/1.8, self.view.frame.size.height/3.5)];
        [[_loadingView messageLabel] setText:@"Loading"];
        [_loadingView showFromViewController:self animated:YES centeredInView:YES];
    }
}

/**
 *  Send the soap request for getRooms
 *  Method should be called when you want to send the soap request to get the Rooms
 *  @param emailAddress the emailAddress will be the email of one location
 */
- (void)sendRequestGetRooms:(NSString *)emailAddress {
    Soap *soap = [Soap clientInstance];
    NSString *soapMessage = [soap getRooms:emailAddress];
    
    NSURL *url = [NSURL URLWithString:[soap getServer]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [request addValue:@"text/xml" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[soapMessage dataUsingEncoding:NSUTF8StringEncoding]];
    
    RFURLSession *session = [[RFURLSession alloc] init];
    [session sendSynchronousRequest:request completionBlock:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error == nil) {
            NSLog(@"no error");
            _recievedData = [[NSMutableData alloc] initWithData:data];
            
            elementFound = foundelse;
            recievedRooms = [[NSMutableArray alloc] init];
            recievedEmails = [[NSMutableArray alloc] init];
            recievedAvaliability = [[NSMutableArray alloc] init];
            XMLParser = [[NSXMLParser alloc] initWithData:_recievedData];
            [XMLParser setDelegate:self];
            [XMLParser setShouldResolveExternalEntities:YES];
            [XMLParser parse];
            
            [self sendRequestGetUserAvaliability];
        }
    }];
}

/**
 *  Send the soap request for getUserAvaliability
 *  Method should be called when you want to send the soap request to check the avaliabilities of several rooms
 */
- (void)sendRequestGetUserAvaliability{
    Soap *soap = [Soap clientInstance];
    NSDate *current = [NSDate date];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone systemTimeZone]];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *currentDateString = [formatter stringFromDate:current];
    
    [formatter setDateFormat:@"HH:mm:ss"];
    NSString *currentTimeString = [formatter stringFromDate:current];
    NSDate *currentTime = [formatter dateFromString:currentTimeString];
    
    [formatter setDateFormat:@"HH:00:00"];
    NSString *tmpString = [formatter stringFromDate:current];
    NSDate *tmp = [formatter dateFromString:tmpString];
    NSString *startTimeString = [[NSString alloc] init];
    if ([currentTime timeIntervalSinceDate:tmp] < 1800) {
        startTimeString = [formatter stringFromDate:currentTime];
    } else {
        [formatter setDateFormat:@"HH:30:00"];
        startTimeString = [formatter stringFromDate:currentTime];
    }
    
    [formatter setDateFormat:@"HH:mm:ss"];
    NSDate *start = [formatter dateFromString:startTimeString];
    NSDate *end = [[NSDate alloc] initWithTimeInterval:5400 sinceDate:start];
    NSString *endTimeString = [formatter stringFromDate:end];
    
    NSString *startTime = [NSString stringWithFormat:@"%@T%@", currentDateString, startTimeString];
    NSString *endTime = [NSString stringWithFormat:@"%@T%@", currentDateString, endTimeString];
    
    
    NSString *soapMessage = [soap getUserAvaliability:recievedEmails startTime:startTime endTime:endTime duration:30];
    
    NSURL *url = [NSURL URLWithString:[soap getServer]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [request addValue:@"text/xml" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[soapMessage dataUsingEncoding:NSUTF8StringEncoding]];
    
    RFURLSession *session = [[RFURLSession alloc] init];
    [session sendSynchronousRequest:request completionBlock:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error == nil) {
            _recievedData = [[NSMutableData alloc] initWithData:data];

            XMLParser = [[NSXMLParser alloc] initWithData:_recievedData];
            [XMLParser setDelegate:self];
            [XMLParser setShouldResolveExternalEntities:YES];
            [XMLParser parse];
            
            RoomsTableViewController *roomsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"roomsViewController"];
            roomsViewController.rooms = recievedRooms;
            roomsViewController.emails = recievedEmails;
            roomsViewController.recievedAvaliability = recievedAvaliability;
            roomsViewController.currentTimeString = [NSString stringWithFormat:@"%@ %@", currentDateString, currentTimeString];
            roomsViewController.startTimeString = [NSString stringWithFormat:@"%@ %@", currentDateString, startTimeString];
            
            [self showViewController:roomsViewController sender:nil];
        }

    }];
}


- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    if([elementName isEqualToString:@"t:Name"]) {
        elementFound = foundName;
    } else if([elementName isEqualToString:@"t:EmailAddress"]) {
        elementFound = foundEmail;
    } else if([elementName isEqualToString:@"MergedFreeBusy"]) {
        elementFound = foundAvaliability;
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {

    if (elementFound == foundName) {
        [recievedRooms addObject:string];
    } else if (elementFound == foundEmail) {
        [recievedEmails addObject:string];
    }else if (elementFound == foundAvaliability) {
        [recievedAvaliability addObject:string];
    }
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    elementFound = foundelse;
}

@end
