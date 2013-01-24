#import "UIAlertViewAutoDismiss.h"
#import <objc/runtime.h>

@interface UIAlertViewAutoDismiss () <UIAlertViewDelegate> {
    id<UIAlertViewDelegate> __unsafe_unretained privateDelegate;
}
@end

@implementation UIAlertViewAutoDismiss

//- (id)initWithTitle:(NSString *)title
//            message:(NSString *)message
//           delegate:(id)delegate
//  cancelButtonTitle:(NSString *)cancelButtonTitle
//  otherButtonTitles:(NSString *)otherButtonTitles, ...
//{
//    self = [super initWithTitle:title
//                        message:message
//                       delegate:self
//              cancelButtonTitle:cancelButtonTitle
//              otherButtonTitles:nil, nil];
//    
//    if (self) {
//        va_list args;
//        va_start(args, otherButtonTitles);
//        for (NSString *anOtherButtonTitle = otherButtonTitles; anOtherButtonTitle != nil; anOtherButtonTitle = va_arg(args, NSString *)) {
//            [self addButtonWithTitle:anOtherButtonTitle];
//        }
//        privateDelegate = delegate;
//    }
//    return self;
//}

- (void)dealloc
{
//    privateDelegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
}

//- (void)setDelegate:(id)delegate
//{
//    [super setDelegate:delegate];
//    privateDelegate = delegate;
//}
//
//- (id)delegate
//{
//    return privateDelegate;
//}

- (void)show
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    [super show];
}

- (void)applicationDidEnterBackground:(NSNotification *)notification
{
    [super dismissWithClickedButtonIndex:[self cancelButtonIndex] animated:NO];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
}
//
//#pragma mark - UIAlertViewDelegate
//
//// The code below avoids to re-implement all protocol methods to forward to the real delegate.
//
//- (id)forwardingTargetForSelector:(SEL)aSelector
//{
//    struct objc_method_description hasMethod = protocol_getMethodDescription(@protocol(UIAlertViewDelegate), aSelector, NO, YES);
//    if (hasMethod.name != NULL) {
//        // The method is that of the UIAlertViewDelegate.
//        
//        if (aSelector == @selector(alertView:didDismissWithButtonIndex:) ||
//            aSelector == @selector(alertView:clickedButtonAtIndex:))
//        {
//            [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                            name:UIApplicationDidEnterBackgroundNotification
//                                                          object:nil];
//        }
//        return privateDelegate;
//    }
//    else {
//        return [super forwardingTargetForSelector:aSelector];
//    }
//}

@end