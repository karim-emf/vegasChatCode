//
//  ViewController.h
//  Vegas

#import <UIKit/UIKit.h>
#import "KJDUser.h"
#import "KJDChatRoom.h"
#import "KJDChatRoomTableViewCell.h"
#import <QuartzCore/QuartzCore.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <MediaPlayer/MediaPlayer.h>
#import "KJDMapKitViewController.h"
#import <MapKit/MapKit.h>
#import <UIKit/UIKit.h>

@class KJDUser;


@interface KJDChatRoomViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property(strong,nonatomic)KJDUser *user;
@property(strong,nonatomic)NSString *firebaseRoomURL;
@property(strong,nonatomic)NSString *firebaseURL;
@property(weak,nonatomic)KJDChatRoom *chatRoom;
@property(strong,nonatomic)UITableViewCell *cell;
@property(strong,nonatomic)NSNumber* userCount;
@property(nonatomic)BOOL firstTimeInRoom;

-(void) sendMapImage:(UIImage*)map;
-(void)removeUserFromChatRoom;


@end

