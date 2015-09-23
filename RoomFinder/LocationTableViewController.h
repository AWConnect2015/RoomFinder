//
//  LocationTableViewController.h
//  RoomFinder
//

#import <UIKit/UIKit.h>


@interface LocationTableViewController : UITableViewController

/**
 *  The locations object contains the list of the locations
 */
@property (nonatomic) NSArray *locations;

/**
 *  The emails object contains the list of the email address of all the locations
 */
@property (nonatomic) NSArray *emails;

@end
