//
//  AppDelegate.h
//  Vegas

#import <UIKit/UIKit.h>
#import "KJDChatRoomViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (weak, nonatomic) KJDChatRoomViewController* chatRoomVCDelegate;

@end

