//
//  ViewController.m
//  RoomFinder
//

#import "ViewController.h"
#import "LocationTableViewController.h"
#import "ConfigProfile.h"
#import "Credential.h"
#import "Soap.h"
#import "RFURLSession.h"
#import "HUDView.h"
#import <AWSDK/AWCommandManager.h>


@interface ViewController () <UIAlertViewDelegate, NSXMLParserDelegate, NSURLSessionDataDelegate, NSURLSessionTaskDelegate>
@property (weak, nonatomic) IBOutlet UITextField *serverTextField;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (strong, nonatomic) NSString *server;
@property (strong, nonatomic) NSMutableData *recievedData;
@property (strong, nonatomic) HUDView *loadingView;
@end

static NSXMLParser *XMLParser;
static NSMutableString *soapResults;
static NSInteger elementFound;
static NSMutableArray *recievedLocations;
static NSMutableArray *recievedEmails;

/**
 @enum parseXML
 @brief valid XML element type
 */
enum parseXML {
    foundelse = 0,
    foundName,
    foundEmail
};

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapOnBackground:)];
    [self.view addGestureRecognizer:tapGestureRecognizer];
    [tapGestureRecognizer setDelegate:self];
    
    _nextButton.layer.cornerRadius = 5;

    _loadingView = [[HUDView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width/1.8, self.view.frame.size.height/3.5)];
    [[_loadingView messageLabel] setText:@"Loading"];
    [_loadingView showFromViewController:self animated:YES centeredInView:YES];
    
    [[ConfigProfile clientInstance] setServerConfig];
    if ([[[ConfigProfile clientInstance] serverURL] isEqualToString:@""]) {
        self.serverTextField.text = @"";
    } else {
        self.serverTextField.text = [[ConfigProfile clientInstance] serverURL];
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_nextButton setEnabled:YES];
    self.navigationController.navigationBarHidden = YES;
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:0.0 green:0.63 blue:0.87 alpha:1.0]];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
}

- (IBAction)next:(id)sender {
    [_nextButton setEnabled:NO];
    [self dismissKeyboard];
    if (![_server isEqualToString:[NSString stringWithFormat:@"%@/EWS/Exchange.asmx",_serverTextField.text ]]) {
        [[Credential clientInstance] setUsername:nil];
        [[Credential clientInstance] setPassword:nil];
        [self setServer:[NSString stringWithFormat:@"%@/EWS/Exchange.asmx",_serverTextField.text ]];
    }
    
    [self sendRequestGetRoomList];
}

/**
 *  Send the soap request for getRoomList
 *  Method should be called when you want to send the soap request to get the roomlist
 */
- (void)sendRequestGetRoomList {
    Soap *soap = [Soap clientInstance];
    
    [soap setServer:_server];
    NSString *soapMessage = [soap getRoomList];
    NSURL *url = [NSURL URLWithString:[soap getServer]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [request addValue:@"text/xml" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[soapMessage dataUsingEncoding:NSUTF8StringEncoding]];
    
    RFURLSession *session = [[RFURLSession alloc] init];
    [session sendSynchronousRequest:request completionBlock:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            [_nextButton setEnabled:YES];
            if (error.code == RFInvalidCredential) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                alert.alertViewStyle = UIAlertViewStyleDefault;
                [alert show];
            } else if (error.code == RFNeedCredential ) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
                alert.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
                alert.transform = CGAffineTransformMakeScale(1.0, 0.75);
                [alert show];
            }
        } else {
            _recievedData = [[NSMutableData alloc] init];
            [_recievedData appendData:data];
            
            elementFound = foundelse;
            recievedLocations = [[NSMutableArray alloc] init];
            recievedEmails = [[NSMutableArray alloc] init];
            XMLParser = [[NSXMLParser alloc] initWithData:_recievedData];
            [XMLParser setDelegate:self];
            [XMLParser setShouldResolveExternalEntities:YES];
            [XMLParser parse];
            
            LocationTableViewController *locViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"locationViewController"];
            locViewController.locations = recievedLocations;
            locViewController.emails = recievedEmails;
            [self showViewController:locViewController sender:nil];
        }
    }];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {

    if([elementName isEqualToString:@"t:Name"]) {
        elementFound = foundName;
    } else if([elementName isEqualToString:@"t:EmailAddress"]) {
        elementFound = foundEmail;
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if (elementFound == foundName) {
        [recievedLocations addObject:string];
    } else if (elementFound == foundEmail) {
        [recievedEmails addObject:string];
    }
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {

}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    elementFound = foundelse;
}

/**
 *  This method will be called when you tap on the backgroud.
 *
 *  @param gestureRecognizer gestureRecognizer
 */
-(void)tapOnBackground:(UIGestureRecognizer*)gestureRecognizer
{
    [self dismissKeyboard];
}

/**
 *  The method will be called when you wat to dismiss the keyboard
 */
- (void)dismissKeyboard
{
    [_serverTextField endEditing:YES];
}

/**
 *  This method will be called when the alertView dismissed.
 *  Credentials will be set according to your input in the alertView
 *
 *  @param alertView   the alertview
 *  @param buttonIndex button index of the alertview.
 */
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [[Credential clientInstance] setUsername:[alertView textFieldAtIndex:0].text];
        [[Credential clientInstance] setPassword:[alertView textFieldAtIndex:1].text];
        [self sendRequestGetRoomList];
    } else if (buttonIndex == 0){
        [[Credential clientInstance] setUsername:nil];
        [[Credential clientInstance] setPassword:nil];
    }
}

#pragma mark - AWSDK Custom Setting
- (void)RetrieveCustomSetting {
    AWCommandManager *commandManager = [AWCommandManager sharedManager];
    AWProfile *profile = [commandManager sdkProfile];
    
    if (profile == nil) {
        AWLogWarning(@"There's no SDK Profile currently installed.");
    } else {
        AWCustomPayload *customPayload = [profile customPayload];
        if (customPayload != nil) {
            NSString *customSettings = [customPayload settings];
            
            AWLogInfo(@"%@", customSettings);
            [_serverTextField setText:customSettings];
        }
    }
}

#pragma mark - AWSDK delegates

- (void)initialCheckDoneWithError:(NSError*) error {
    NSLog(@"Initial check done!");
    [self RetrieveCustomSetting];
    [_loadingView hide];
    _loadingView = nil;
}

- (void)receivedProfiles:(NSArray*)profiles {
    NSLog(@"Recieved profiles!");
}

- (void)wipe {
    NSLog(@"Wipe!");
}

- (void)lock {
    NSLog(@"lock");
}

- (void)unlock {
    NSLog(@"unlock");
}

- (void)stopNetworkActivity {}

- (void)resumeNetworkActivity {}

@end
