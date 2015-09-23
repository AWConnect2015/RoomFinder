//
//  RoomsTableViewController.m
//  RoomFinder
//

#import "RoomsTableViewController.h"
#import "LocationTableViewCell.h"
#import "Soap.h"

@interface RoomsTableViewController()<UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) NSMutableData *recievedData;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

static NSMutableArray *waitTime;
@implementation RoomsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.topViewController.title = @"Rooms";
    

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone systemTimeZone]];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];

    NSDate *startTime = [formatter dateFromString:_startTimeString];
    NSDate *currentTime = [formatter dateFromString:_currentTimeString];
    NSTimeInterval time = [currentTime timeIntervalSinceDate:startTime];
    
    waitTime = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [_emails count]; ++i) {
        int wait = 0;
        
        if ([[_recievedAvaliability objectAtIndex:i] hasPrefix:@"0"]) {
            wait = 0;
            [waitTime addObject:[NSString stringWithFormat:@"%d", wait]];
        } else if ([[_recievedAvaliability objectAtIndex:i] hasPrefix:@"20"] || [[_recievedAvaliability objectAtIndex:i] hasPrefix:@"10"]) {
            wait = 30 - time/60;
            [waitTime addObject:[NSString stringWithFormat:@"%d", wait]];
        } else if ([[_recievedAvaliability objectAtIndex:i] isEqualToString:@"220"] || [[_recievedAvaliability objectAtIndex:i] isEqualToString:@"110"]) {
            wait = 60 - time/60;
            [waitTime addObject:[NSString stringWithFormat:@"%d", wait]];
        } else {
            [_rooms removeObjectAtIndex:i];
            [_emails removeObjectAtIndex:i];
            [_recievedAvaliability removeObjectAtIndex:i];
            --i;
        }
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [_tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_rooms count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LocationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"avaliableRooms" forIndexPath:indexPath];
    [self configueCell:cell forIndexPath:indexPath];
    return cell;
}

- (void) configueCell:(LocationTableViewCell *)tableViewCell forIndexPath:(NSIndexPath *)indexPath {

    tableViewCell.location.text = [NSString stringWithFormat:@"%@", [_rooms objectAtIndex:indexPath.row]];

    tableViewCell.availableView.alpha = 1.0;
    tableViewCell.availableView.layer.cornerRadius = 7.5;
    
    if ([[waitTime objectAtIndex:indexPath.row] isEqualToString:@"0"]) {
        tableViewCell.avaliability.text = [NSString stringWithFormat:@"Available Now"];
        tableViewCell.availableView.backgroundColor = [UIColor greenColor];
    } else if ([[waitTime objectAtIndex:indexPath.row] compare:@"30" options:NSNumericSearch] == NSOrderedAscending ) {
        tableViewCell.avaliability.text = [NSString stringWithFormat:@"Available in %@ minutes", [waitTime objectAtIndex:indexPath.row]];
        tableViewCell.availableView.backgroundColor = [UIColor orangeColor];
    } else {
        tableViewCell.avaliability.text = [NSString stringWithFormat:@"Available in %@ minutes", [waitTime objectAtIndex:indexPath.row]];
        tableViewCell.availableView.backgroundColor = [UIColor redColor];
    }

}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Room...%@", [_rooms objectAtIndex:indexPath.row]);
}

@end
