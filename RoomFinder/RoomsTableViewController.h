//
//  RoomsTableViewController.h
//  RoomFinder
//

#import <UIKit/UIKit.h>

@interface RoomsTableViewController : UIViewController

/**
 *  The rooms object contains the list of the rooms in one location
 */
@property (nonatomic) NSMutableArray *rooms;

/**
 *  The emails object contains the list of the email address of all the rooms
 */
@property (nonatomic) NSMutableArray *emails;

/**
 *  The recievedAvaliability object contains the list of the avaliability of all the rooms
 */
@property (nonatomic) NSMutableArray *recievedAvaliability;

/**
 *  currentTimeString
 *  Passed from LocationViewController
 */
@property (nonatomic) NSString *currentTimeString;

/**
 *  startTimeString
 *  Passed from LocationViewController
 */
@property (nonatomic) NSString *startTimeString;
@end
