//
//  LocationTableViewCell.h
//  RoomFinder
//

#import <UIKit/UIKit.h>

@interface LocationTableViewCell : UITableViewCell
/**
 *  avalibility UILable shows the avaliability time of each room in RoomsTableViewController
 */
@property (weak, nonatomic) IBOutlet UILabel *avaliability;

/**
 *  location UILable shows the name of each location in LocationTableViewController
 *  and shows the name of each room in RoomsTableViewController
 */
@property (weak, nonatomic) IBOutlet UILabel *location;

/**
 *  availableView UIView shows the avaliability status of each room in RoomsTableViewController
 *  Green:  available now
 *  Orange: available within 30 minutes
 *  Red:    available within 1 hour
 */
@property (weak, nonatomic) IBOutlet UIView *availableView;
@end
