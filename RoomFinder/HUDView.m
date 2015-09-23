//
//  HUDView.m
//  RoomFinder
//

#import "HUDView.h"

@implementation HUDView

@synthesize activityIndicatorView = _activityIndicatorView;
@synthesize messageLabel = _messageLabel;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self sizeToFit];
        
        [[self layer] setCornerRadius:10.0f];
        [self setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5]];
        [self setAutoresizingMask:(UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin)];
        
        _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [_activityIndicatorView setFrame: CGRectMake(11.0f, [self frame].size.height - 150.0f, [self frame].size.width - 20.0f, 60.0f)];
        [_activityIndicatorView startAnimating];
        
        _messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(11.0f, [self frame].size.height - 85.0f, [self frame].size.width - 20.0f, 60.0f)];
        [_messageLabel setTextColor:[UIColor whiteColor]];
        [_messageLabel setFont:[UIFont boldSystemFontOfSize:20.0f]];
        [_messageLabel setTextAlignment:NSTextAlignmentCenter];
        [_messageLabel setBackgroundColor:[UIColor clearColor]];
        [_messageLabel setNumberOfLines:0];
        [_messageLabel setAdjustsFontSizeToFitWidth:YES];
        
        [self addSubview:_activityIndicatorView];
        [self addSubview:_messageLabel];

    }
    
    return self;
}

- (void)showFromView:(UIView *)view {
    
    // This view needs to be centered on the screen, not the view
    [self setCenter:CGPointMake(view.bounds.size.width/2.0, view.bounds.size.height/2.0)];
    
    // Round it
    [self setFrame:CGRectMake(roundf(self.frame.origin.x), roundf(self.frame.origin.y), roundf(self.frame.size.width), roundf(self.frame.size.height))];
    
    [view addSubview:self];
    
}

- (void)showFromViewController:(UIViewController *)viewController animated:(BOOL)animated centeredInView:(BOOL)shouldCenter {
    
    // This view needs to be centered on the screen, not the view
    [self setCenter:[[viewController view] center]];
    
    if (!shouldCenter) {
        
        CGRect navigationBarFrame = [[[viewController navigationController] navigationBar] frame];
        [self setFrame:CGRectMake(roundf(self.frame.origin.x), roundf(self.frame.origin.y - navigationBarFrame.size.height), roundf([self frame].size.width), roundf([self frame].size.height))];
        
    } else {
        
        // Round it
        [self setFrame:CGRectMake(roundf(self.frame.origin.x), roundf(self.frame.origin.y), roundf(self.frame.size.width), roundf(self.frame.size.height))];
        
    }
    
    [[viewController view] addSubview:self];
}

- (void)showFromWindow:(UIWindow *)window animated:(BOOL)animated {
    [self setCenter:CGPointMake(window.center.x, window.center.y)];
    [self setFrame:CGRectMake(round(self.frame.origin.x), round(self.frame.origin.y), [self frame].size.width, [self frame].size.height)];
    
    [window addSubview:self];
}

- (void)hide {
   
    [self removeFromSuperview];
    
}

@end
