//
//  HUDView.h
//  RoomFinder
//


#import <UIKit/UIKit.h>

@interface HUDView : UIView

/**
 *  The HUDView will include a UIActivityIndicatorView and a UILable to show the loading message
 */
@property (nonatomic, readonly) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, readonly) UILabel *messageLabel;

/**
 *  showFromView
 *  Method should be called when you want to add the HUDView as a subview of view.
 *  @param view the The HUDView will be shown on the top of view
 */
- (void)showFromView:(UIView *)view;

/**
 *  showFromViewController
 *
 *  @param viewController The HUDView will be shown based on viewController
 *  @param animated       YES/NO
 *  @param shouldCenter   The HUDView will be Centered in the view if YES
 */
- (void)showFromViewController:(UIViewController *)viewController animated:(BOOL)animated centeredInView:(BOOL)shouldCenter;

/**
 *  showFromWindow
 *
 *  @param window   The HUDView will be present in window
 *  @param animated YES/NO
 */
- (void)showFromWindow:(UIWindow *)window animated:(BOOL)animated;

/**
 *  hide
 *  Method should be called when you want to dismiss the HUDView
 */
- (void)hide;

@end
